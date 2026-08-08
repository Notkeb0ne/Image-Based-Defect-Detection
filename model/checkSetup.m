%% Pre-flight check: run this first
% Verifies toolboxes, the ResNet-18 support package, dataset paths, and
% that all the custom functions are visible on the MATLAB path - before
% you sink time into a run that fails partway through with a less
% obvious error.

fprintf('--- Toolboxes ---\n');
requiredToolboxes = {'Image Processing Toolbox', 'Deep Learning Toolbox'};
v = ver;
installedNames = {v.Name};
for i = 1:numel(requiredToolboxes)
    if any(strcmp(installedNames, requiredToolboxes{i}))
        fprintf('  OK       %s\n', requiredToolboxes{i});
    else
        fprintf('  MISSING  %s\n', requiredToolboxes{i});
    end
end

fprintf('\n--- ResNet-18 support package ---\n');
try
    imagePretrainedNetwork("resnet18"); %#ok<NASGU>
    fprintf('  OK       resnet18 loads successfully\n');
catch ME
    fprintf('  MISSING or ERROR: %s\n', ME.message);
    fprintf('  -> Add-On Explorer: "Deep Learning Toolbox Model for ResNet-18 Network"\n');
end

fprintf('\n--- Dataset paths ---\n');
% Anchored to this script's own folder, matching how the pipeline scripts
% resolve paths - so this check reflects reality regardless of pwd.
projectRoot = fileparts(mfilename('fullpath'));
datasetRoot = fullfile(fileparts(projectRoot), 'toothbrush');
checkPaths = {
    fullfile(datasetRoot, 'train', 'good')
    fullfile(datasetRoot, 'test', 'good')
    fullfile(datasetRoot, 'test', 'defective')
    };
for i = 1:numel(checkPaths)
    if exist(checkPaths{i}, 'file') || exist(checkPaths{i}, 'dir')
        fprintf('  OK       %s\n', checkPaths{i});
    else
        fprintf('  MISSING  %s\n', checkPaths{i});
    end
end

try
    avgPath = resolveToothAveragedPath(projectRoot);
    fprintf('  OK       %s\n', avgPath);
catch ME
    fprintf('  MISSING  ToothAveraged.png (%s)\n', ME.message);
end

fprintf('\n--- Custom functions on the path ---\n');
requiredFunctions = {'segmentBristle', 'extractEvidenceMetrics', 'decideRules', ...
    'classifyToothbrush', 'inspectPart', 'buildLabelTable', 'readLabelTable', ...
    'evaluateToothbrushSystem', 'resolveToothAveragedPath'};
for i = 1:numel(requiredFunctions)
    if exist(requiredFunctions{i}, 'file') == 2
        fprintf('  OK       %s.m\n', requiredFunctions{i});
    else
        fprintf('  MISSING  %s.m  (not found on the MATLAB path)\n', requiredFunctions{i});
    end
end

fprintf('\nIf everything above says OK, run organizeToothbrushDataset next.\n');
