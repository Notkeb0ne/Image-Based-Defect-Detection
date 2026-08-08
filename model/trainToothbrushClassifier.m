%% Task 3: Train an AI Classifier (transfer learning on ResNet-18)
% Fine-tunes a pretrained ResNet-18 for good/defective classification
% using the train/test split saved by organizeToothbrushDataset.m.
%
% Split out from the original combined train+evaluate design so that
% Task 5 can re-run evaluation under simulated distortions without
% retraining the network each time, and so every re-run evaluates the
% exact same held-out test images (see runInspectionSuite.m / testRobustness.m).
%
% Requires: Deep Learning Toolbox, the "Deep Learning Toolbox Model for
% ResNet-18 Network" support package, and MATLAB R2024a or later (for
% imagePretrainedNetwork / trainnet).

projectRoot = fileparts(mfilename('fullpath'));

trainTable = readLabelTable(fullfile(projectRoot, 'toothbrushLabels_train.csv'));
testTable = readLabelTable(fullfile(projectRoot, 'toothbrushLabels_test.csv'));

imdsTrainAll = imageDatastore(trainTable.filepath);
imdsTrainAll.Labels = trainTable.label;

imdsTest = imageDatastore(testTable.filepath);
imdsTest.Labels = testTable.label;

% ---- Validation slice out of the training set ----
% imdsTest is left untouched - it's reserved for Task 4/5's evaluation,
% not for monitoring progress during training.
rng(42);
[imdsTrain, imdsVal] = splitEachLabel(imdsTrainAll, 0.80, 'randomized');

% ---- Balance the training set ----
% Last run's confusion matrix showed the network had collapsed to
% predicting "good" for every image (0 defective predictions out of 31) -
% classic majority-class collapse on an imbalanced training set. Oversample
% "defective" by simple duplication so the network can't get away with
% ignoring it.
counts = countEachLabel(imdsTrain);
goodCount = counts.Count(counts.Label == 'good');
defectiveCount = counts.Count(counts.Label == 'defective');
fprintf('Training set before balancing - good: %d  defective: %d\n', goodCount, defectiveCount);

originalFiles  = imdsTrain.Files;
originalLabels = imdsTrain.Labels;

if defectiveCount > 0 && defectiveCount < goodCount
    replicationFactor = floor(goodCount / defectiveCount) - 1;
    if replicationFactor > 0
        defectiveFiles = originalFiles(originalLabels == 'defective');
        extraFiles = repmat(defectiveFiles, replicationFactor, 1);
        extraLabels = repmat(categorical("defective"), numel(extraFiles), 1);

        imdsTrain = imageDatastore([originalFiles; extraFiles]);
        imdsTrain.Labels = [originalLabels; extraLabels];
    end
end

fprintf('Training set after balancing:\n');
disp(countEachLabel(imdsTrain));

classNames = categories(imdsTrainAll.Labels);
numClasses = numel(classNames);

% Mild geometric augmentation on the training set only - the ~61-image
% training pool (even after oversampling) is small for fine-tuning an
% 18-layer CNN, so this adds variety rather than the network seeing the
% same exact pixels every epoch. Validation/test stay unaugmented, since
% you want to measure performance on realistic, undistorted images.
augmenter = imageDataAugmenter( ...
    "RandXReflection", true, ...
    "RandRotation", [-10 10], ...
    "RandXTranslation", [-5 5], ...
    "RandYTranslation", [-5 5]);

brushImgTrain = augmentedImageDatastore([224 224], imdsTrain, "DataAugmentation", augmenter);
brushImgVal   = augmentedImageDatastore([224 224], imdsVal);
brushImgTest  = augmentedImageDatastore([224 224], imdsTest);

% ---- Load pretrained ResNet-18, adapted for our classes ----
net = imagePretrainedNetwork("resnet18", "NumClasses", numClasses);

% ---- Freeze early layers ----
% ~60 training images is too little to safely fine-tune all ~11M ResNet-18
% parameters - the wildly swinging validation accuracy across the last
% run (30/50/30/20/70/70/70/70/50/50, never settling) points at exactly
% this. Freeze everything through the end of stage 4 ('res4b_relu'),
% leaving stage 5 ('res5a'/'res5b') plus the new classification head
% trainable - cutting trainable capacity down to roughly what this much
% data can support, while keeping ResNet-18's pretrained low/mid-level
% feature extraction intact rather than fine-tuning (and potentially
% damaging) it. Verified against net.Layers/net.Learnables directly
% rather than assumed layer names.
freezeUpTo = "res4b_relu";
layerNames = string({net.Layers.Name});
freezeIdx = find(layerNames == freezeUpTo);
layersToFreeze = layerNames(1:freezeIdx);

for i = 1:height(net.Learnables)
    if ismember(net.Learnables.Layer(i), layersToFreeze)
        net = setLearnRateFactor(net, net.Learnables.Layer(i), net.Learnables.Parameter(i), 0);
    end
end
fprintf('Froze %d of %d layers (through %s); %d layers remain trainable.\n', ...
    freezeIdx, numel(layerNames), freezeUpTo, numel(layerNames) - freezeIdx);

% ---- Training options ----
% Kept your original solver (sgdm) and learning rate. ValidationPatience
% stops training automatically once validation loss stops improving -
% MaxEpochs raised slightly to give it more room to find a good stopping
% point rather than being capped early; it's a ceiling, not a target.
opts = trainingOptions("sgdm", ...
    "InitialLearnRate", 0.0001, ...
    "MaxEpochs", 15, ...
    "Metrics", "accuracy", ...
    "Shuffle", "every-epoch", ...
    "MiniBatchSize", 6, ...
    "ValidationData", brushImgVal, ...
    "ValidationFrequency", 5, ...
    "ValidationPatience", 5);

% ---- Train ----
net = trainnet(brushImgTrain, net, "crossentropy", opts);

% ---- Quick check on the held-out test set ----
scoresTest = minibatchpredict(net, brushImgTest);
predTest = scores2label(scoresTest, classNames);
testAccuracy = mean(predTest == imdsTest.Labels);
fprintf('\nHeld-out test accuracy: %.1f%%\n', testAccuracy * 100);

% This time, also check it's not just predicting one class - a repeat of
% the collapse would still show a plausible-looking accuracy number.
fprintf('Test set predictions - good: %d  defective: %d (out of %d)\n', ...
    sum(predTest == 'good'), sum(predTest == 'defective'), numel(predTest));

% ---- Save the trained network + class names together ----
% dlnetwork objects don't store class names themselves, so both are saved
% together here for classifyToothbrush.m / inspectPart.m to use later.
save(fullfile(projectRoot, 'toothbrushClassifier.mat'), 'net', 'classNames');
fprintf('Saved toothbrushClassifier.mat to %s\n', projectRoot);
