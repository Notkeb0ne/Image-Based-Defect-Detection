%% Task 5: Test and Evaluate System Robustness
% Re-runs the inspection system on the same held-out test set under
% simulated lighting, blur, and noise conditions (perturbed in memory -
% nothing is saved to disk), and compares accuracy / false-reject /
% false-accept rates across conditions against the unperturbed baseline
% from Task 4.

projectRoot = fileparts(mfilename('fullpath'));

load(fullfile(projectRoot, 'toothbrushClassifier.mat'), 'net', 'classNames');

avgImgPath = resolveToothAveragedPath(projectRoot);
avgI = imread(avgImgPath);

testTable = readLabelTable(fullfile(projectRoot, 'toothbrushLabels_test.csv'));

% ---- Define the perturbations to test ----
% imadjust(I,[],[outLow outHigh]) auto-detects the input range and
% compresses it into [outLow outHigh], which dims (low outHigh) or
% brightens (high outLow) the whole image.
conditions = struct( ...
    'Label', {'baseline', 'dim_lighting', 'bright_lighting', 'blur', 'noise'}, ...
    'PerturbFcn', { ...
        [], ...
        @(I) imadjust(I, [], [0 0.6]), ...
        @(I) imadjust(I, [], [0.4 1]), ...
        @(I) imgaussfilt(I, 2), ...
        @(I) imnoise(I, 'gaussian', 0, 0.01) ...
    });

allResults = cell(numel(conditions), 1);
for c = 1:numel(conditions)
    fprintf('\nEvaluating condition: %s\n', conditions(c).Label);
    allResults{c} = evaluateToothbrushSystem(testTable, avgI, net, classNames, ...
        'PerturbFcn', conditions(c).PerturbFcn, 'Label', conditions(c).Label, 'Verbose', true);
end

% ---- Comparison table across conditions ----
comparisonTable = table();
for c = 1:numel(allResults)
    r = allResults{c};
    newRow = table(string(r.condition), r.aiAccuracy, r.baselineAccuracy, ...
        r.aiFalseRejectRate, r.aiFalseAcceptRate, ...
        'VariableNames', {'Condition', 'AIAccuracy', 'BaselineAccuracy', 'AIFalseRejectRate', 'AIFalseAcceptRate'});
    comparisonTable = [comparisonTable; newRow]; %#ok<AGROW>
end

disp(comparisonTable);
writetable(comparisonTable, fullfile(projectRoot, 'toothbrushRobustnessComparison.csv'));

% ---- Visual comparison ----
conditionOrder = comparisonTable.Condition;   % preserve baseline-first ordering

figure('Name', 'Robustness comparison');
bar(categorical(comparisonTable.Condition, conditionOrder), ...
    [comparisonTable.AIAccuracy, comparisonTable.BaselineAccuracy]);
legend('AI classifier', 'Rule-based baseline', 'Location', 'southoutside');
ylabel('Accuracy');
title('Accuracy across simulated conditions');

figure('Name', 'False-reject rate across conditions');
bar(categorical(comparisonTable.Condition, conditionOrder), comparisonTable.AIFalseRejectRate);
ylabel('AI false-reject rate');
title('False-reject rate (good toothbrushes flagged defective) across conditions');

fprintf('\nSaved toothbrushRobustnessComparison.csv\n');
