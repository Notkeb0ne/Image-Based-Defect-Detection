%% Task 1: Explore and Organize the Toothbrush Image Dataset
% Builds a good/defective label table for the MVTec AD "toothbrush"
% category, pooling train/good (extra normal examples the original
% script wasn't using) with the full test/ split (both classes),
% persists it to a CSV (loaded back via readtable, per the assignment),
% and creates a fixed, repeatable train/test split for Tasks 3-5 to reuse.
%
% Edit datasetRoot below if your dataset isn't in a "toothbrush" folder
% that's a sibling of this script's own folder.

projectRoot = fileparts(mfilename('fullpath'));
datasetRoot = fullfile(fileparts(projectRoot), 'toothbrush');

if ~isfolder(datasetRoot)
    error(['Cannot find "%s".\n' ...
           'This is derived from this script''s own folder (%s) - looking ' ...
           'one level up for a sibling "toothbrush" folder - not the current ' ...
           'folder. If your dataset is somewhere else, edit datasetRoot above ' ...
           'directly.'], ...
        datasetRoot, projectRoot);
end

goodFolders      = {'train/good', 'test/good'};
defectiveFolders = {'test/defective'};

% ---- Build and persist the label table ----
labelTable = buildLabelTable(datasetRoot, goodFolders, 'good', defectiveFolders, 'defective');
labelsCsv = fullfile(projectRoot, 'toothbrushLabels.csv');
writetable(labelTable, labelsCsv, 'Delimiter', ',');

% Re-load through readtable, per the assignment's requirement, via
% readLabelTable.m (handles the column naming edge case robustly and
% gives a clear diagnostic if 'label' still isn't found).
labelTable = readLabelTable(labelsCsv);

% ---- Build the datastore and attach labels ----
imds = imageDatastore(labelTable.filepath);
imds.Labels = labelTable.label;

% ---- Inspect the dataset ----
fprintf('Total images: %d\n\n', numel(imds.Files));
disp(countEachLabel(imds));

% Breakdown by original MVTec subfolder - shows how much of "good" came
% from train/ vs test/, and confirms defective only comes from test/.
disp(groupcounts(labelTable, {'label', 'originalClass'}));

% ---- Visual sanity check ----
goodIdx      = find(imds.Labels == 'good', 4);
defectiveIdx = find(imds.Labels == 'defective', 4);

figure('Name', 'Dataset sample - good');
montage(imds.Files(goodIdx));
title('Sample good images');

if ~isempty(defectiveIdx)
    figure('Name', 'Dataset sample - defective');
    montage(imds.Files(defectiveIdx));
    title('Sample defective images');
end

% ---- Fixed, repeatable train/test split ----
% Using 0.7 rather than the original 0.6 since pooling train/good in
% means there's more data overall now; adjust freely.
rng(42);   % fixed seed so this split is reproducible across sessions/tasks
[trainSet, testSet] = splitEachLabel(imds, 0.7, 'randomized');

fprintf('\nTrain set:\n');
disp(countEachLabel(trainSet));
fprintf('Test set:\n');
disp(countEachLabel(testSet));

% Persist the split so Tasks 3-5 always train/evaluate on the same images
trainTable = table(trainSet.Files, trainSet.Labels, 'VariableNames', {'filepath', 'label'});
testTable  = table(testSet.Files,  testSet.Labels,  'VariableNames', {'filepath', 'label'});
writetable(trainTable, fullfile(projectRoot, 'toothbrushLabels_train.csv'), 'Delimiter', ',');
writetable(testTable,  fullfile(projectRoot, 'toothbrushLabels_test.csv'), 'Delimiter', ',');

fprintf('\nSaved toothbrushLabels.csv, toothbrushLabels_train.csv, toothbrushLabels_test.csv\n');
