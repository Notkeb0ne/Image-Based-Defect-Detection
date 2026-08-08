%% Calibrate decideRules thresholds using known-good images
% The rule-based baseline just flagged 20 of 22 good toothbrushes as
% defective (90.9% false-positive rate) - the AreaThreshold=500 /
% ComponentThreshold=5 placeholders in decideRules.m are far too low for
% this dataset's actual scale. This runs the classical evidence pipeline
% (via inspectPart, ignoring its AI output) on a sample of known-good
% images and reports what a "no real defect" reading actually looks like,
% so real thresholds can be set above that noise floor.
%
% Independent of trainToothbrushClassifier.m - only evidenceMetrics is
% used here, not the AI prediction, so this can be run before or after
% retraining, with the existing toothbrushClassifier.mat.
%
% This is a NEW file - if it's not already in your project folder,
% create a new file there named exactly calibrateToothbrushThresholds.m
% and paste this in.

projectRoot = fileparts(mfilename('fullpath'));

load(fullfile(projectRoot, 'toothbrushClassifier.mat'), 'net', 'classNames');
avgI = imread(resolveToothAveragedPath(projectRoot));

labelTable = readLabelTable(fullfile(projectRoot, 'toothbrushLabels.csv'));
goodTable = labelTable(labelTable.label == 'good', :);

n = min(40, height(goodTable));   % a sample is enough to characterize the noise floor
fprintf('Evaluating evidence metrics on %d known-good images...\n', n);

maxAreas = zeros(n, 1);
numComps = zeros(n, 1);

for k = 1:n
    [~, ~, ~, evidenceMetrics] = inspectPart(goodTable.filepath(k), avgI, net, classNames);
    maxAreas(k) = evidenceMetrics.maxArea;
    numComps(k) = evidenceMetrics.numComponents;

    if mod(k, 10) == 0
        fprintf('  processed %d / %d\n', k, n);
    end
end

fprintf('\nmaxArea       - mean: %.1f   std: %.1f   max: %.1f\n', ...
    mean(maxAreas), std(maxAreas), max(maxAreas));
fprintf('numComponents - mean: %.1f   std: %.1f   max: %.1f\n\n', ...
    mean(numComps), std(numComps), max(numComps));

% Simple margin above the worst normal-image reading.
suggestedAreaThreshold = max(maxAreas) * 1.5;
suggestedComponentThreshold = ceil(max(numComps) * 1.5);

fprintf('Suggested AreaThreshold:      %.0f\n', suggestedAreaThreshold);
fprintf('Suggested ComponentThreshold: %d\n', suggestedComponentThreshold);
fprintf('\nShare these two numbers and I''ll update decideRules.m''s defaults ');
fprintf('to match - or pass them yourself as name-value overrides:\n');
fprintf('  decideRules(evidence, ''AreaThreshold'', X, ''ComponentThreshold'', Y)\n');
