%% Task 4: Evaluate Inspection System Performance
% Loads the trained network from trainToothbrushClassifier.m and the
% fixed test set from organizeToothbrushDataset.m, runs the full hybrid
% inspection system (classical + AI, via inspectPart) over it, and
% reports a confusion matrix, yield/defect-rate summary, and a montage of
% images the AI classifier got wrong.

projectRoot = fileparts(mfilename('fullpath'));

load(fullfile(projectRoot, 'toothbrushClassifier.mat'), 'net', 'classNames');

avgImgPath = resolveToothAveragedPath(projectRoot);
avgI = imread(avgImgPath);

testTable = readLabelTable(fullfile(projectRoot, 'toothbrushLabels_test.csv'));

results = evaluateToothbrushSystem(testTable, avgI, net, classNames, ...
    'Label', 'baseline', 'Verbose', true);

% ---- Confusion matrices ----
figure('Name', 'AI classifier confusion matrix');
confusionchart(results.trueLabel, results.aiPredLabel, ...
    'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized');
title('AI classifier vs. ground truth');

figure('Name', 'Rule-based baseline confusion matrix');
confusionchart(results.trueLabel, results.baselinePredLabel, ...
    'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized');
title('Rule-based baseline vs. ground truth');

% ---- Summary metrics ----
fprintf('\n--- Summary ---\n');
fprintf('AI classifier accuracy:       %.1f%%\n', results.aiAccuracy * 100);
fprintf('Rule-based baseline accuracy: %.1f%%\n', results.baselineAccuracy * 100);
fprintf('AI/baseline agreement rate:   %.1f%%\n', results.agreementRate * 100);
fprintf('AI false-reject rate:         %.1f%%\n', results.aiFalseRejectRate * 100);
fprintf('AI false-accept rate:         %.1f%%\n', results.aiFalseAcceptRate * 100);

% ---- Yield / defect-rate summary table ----
observedDefectRate  = mean(results.trueLabel == 'defective');
aiFlaggedRate        = mean(results.aiPredLabel == 'defective');
baselineFlaggedRate  = mean(results.baselinePredLabel == 'defective');

yieldTable = table( ...
    ["Ground truth"; "AI classifier"; "Rule-based baseline"], ...
    [1 - observedDefectRate; 1 - aiFlaggedRate; 1 - baselineFlaggedRate], ...
    [observedDefectRate; aiFlaggedRate; baselineFlaggedRate], ...
    'VariableNames', {'Source', 'Yield', 'DefectRate'});
disp(yieldTable);

figure('Name', 'Yield vs defect rate');
bar(categorical(yieldTable.Source, yieldTable.Source), [yieldTable.Yield, yieldTable.DefectRate], 'stacked');
legend('Yield (good rate)', 'Defect rate', 'Location', 'southoutside');
title('Yield / defect rate: ground truth vs. system outputs');
ylabel('Proportion');

% ---- Montage of failure cases (AI got it wrong) ----
wrongIdx = find(results.aiPredLabel ~= results.trueLabel);
fprintf('\nAI classifier missed %d of %d test images.\n', numel(wrongIdx), height(testTable));

if ~isempty(wrongIdx)
    showN = min(9, numel(wrongIdx));
    figure('Name', 'Sample misclassifications');
    montage(cellstr(results.filepath(wrongIdx(1:showN))));
    title(sprintf('Sample misclassifications (showing %d of %d)', showN, numel(wrongIdx)));
end

% ---- Log full outcomes to disk for later reference ----
outcomeLog = table(results.filepath, results.trueLabel, results.aiPredLabel, ...
    results.baselinePredLabel, results.confidence, results.disagreement, ...
    'VariableNames', {'filepath', 'trueLabel', 'aiPredLabel', 'baselinePredLabel', 'confidence', 'disagreement'});
writetable(outcomeLog, fullfile(projectRoot, 'toothbrushInspectionOutcomes.csv'));
fprintf('\nSaved toothbrushInspectionOutcomes.csv\n');
