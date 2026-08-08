function summary = evaluateToothbrushSystem(testTable, avgI, net, classNames, opts)
%EVALUATETOOTHBRUSHSYSTEM Run inspectPart over a labeled test table.
%   SUMMARY = EVALUATETOOTHBRUSHSYSTEM(TESTTABLE, AVGI, NET, CLASSNAMES)
%   runs inspectPart on every image in TESTTABLE (columns: filepath,
%   label) and returns a struct SUMMARY with the true/predicted labels,
%   confidence scores, disagreement flags, and headline accuracy/false-
%   reject/false-accept metrics for both the AI classifier and the
%   classical rule-based baseline.
%
%   SUMMARY = EVALUATETOOTHBRUSHSYSTEM(..., 'PerturbFcn', fcn) applies
%   FCN (a function handle taking one image and returning a perturbed
%   image) to each image before it reaches inspectPart - used to test
%   robustness to lighting/blur/noise in Task 5, without needing to save
%   perturbed copies of the dataset to disk.
%
%   SUMMARY = EVALUATETOOTHBRUSHSYSTEM(..., 'Label', name) tags the
%   returned struct with a condition name (default 'baseline').
%
%   SUMMARY = EVALUATETOOTHBRUSHSYSTEM(..., 'Verbose', true) prints
%   progress every 10 images.

    arguments
        testTable table
        avgI
        net (1,1) dlnetwork
        classNames
        opts.PerturbFcn = []
        opts.Label (1,1) string = "baseline"
        opts.Verbose (1,1) logical = false
    end

    n = height(testTable);
    trueLabel      = testTable.label;
    aiPredLabel    = strings(n, 1);
    baselinePred   = false(n, 1);
    disagreeFlag   = false(n, 1);
    confidenceVals = zeros(n, 1);

    for i = 1:n
        img = imread(testTable.filepath(i));
        if ~isempty(opts.PerturbFcn)
            img = opts.PerturbFcn(img);
        end

        [finalLabel, confidenceScore, ~, ~, baselineDecision, disagreement] = ...
            inspectPart(img, avgI, net, classNames);

        aiPredLabel(i)    = string(finalLabel);
        baselinePred(i)   = baselineDecision;
        disagreeFlag(i)   = disagreement;
        confidenceVals(i) = confidenceScore;

        if opts.Verbose && mod(i, 10) == 0
            fprintf('  [%s] processed %d / %d\n', opts.Label, i, n);
        end
    end

    aiPredLabel = categorical(aiPredLabel);
    baselinePredLabel = categorical(baselinePred, [false true], {'good', 'defective'});

    summary.condition         = opts.Label;
    summary.filepath          = testTable.filepath;
    summary.trueLabel         = trueLabel;
    summary.aiPredLabel       = aiPredLabel;
    summary.baselinePredLabel = baselinePredLabel;
    summary.confidence        = confidenceVals;
    summary.disagreement      = disagreeFlag;

    summary.aiAccuracy       = mean(aiPredLabel == trueLabel);
    summary.baselineAccuracy = mean(baselinePredLabel == trueLabel);
    summary.agreementRate    = mean(~disagreeFlag);

    % False-reject rate: truly good parts that got flagged defective
    isGood = trueLabel == 'good';
    summary.aiFalseRejectRate = mean(aiPredLabel(isGood) == 'defective');
    summary.baselineFalseRejectRate = mean(baselinePredLabel(isGood) == 'defective');

    % False-accept rate: truly defective parts that got flagged good
    isDefective = trueLabel == 'defective';
    summary.aiFalseAcceptRate = mean(aiPredLabel(isDefective) == 'good');
    summary.baselineFalseAcceptRate = mean(baselinePredLabel(isDefective) == 'good');
end
