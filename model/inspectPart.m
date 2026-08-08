function [finalLabel, confidenceScore, evidenceOverlay, evidenceMetrics, baselineDecision, disagreement] = inspectPart(I, avgI, net, classNames)
%INSPECTPART Combine classical evidence from image processing with an AI
%classification decision to decide whether a toothbrush is defective.
%   [FINALLABEL, CONFIDENCESCORE, EVIDENCEOVERLAY, EVIDENCEMETRICS, ...
%    BASELINEDECISION, DISAGREEMENT] = INSPECTPART(I, AVGI, NET, CLASSNAMES)
%
%   I          - the image to inspect (file path or already-loaded matrix)
%   avgI       - the precomputed "average good" reference image (e.g.
%                ToothAveraged.png), used as-is - it's already denoised by
%                virtue of being an average of many images, so unlike I it
%                doesn't get the extra per-image smoothing step below
%   net        - trained dlnetwork (see trainToothbrushClassifier.m)
%   classNames - class names in the exact order the network was trained
%                with (categories(...) on the training labels - for this
%                dataset that's {'defective';'good'})
%
%   Returns:
%       finalLabel       - the AI classifier's label - the system's main
%                          decision
%       confidenceScore  - the AI classifier's confidence in that label
%       evidenceOverlay  - the evidence mask drawn over the image, for a
%                          human reviewer
%       evidenceMetrics  - struct from EXTRACTEVIDENCEMETRICS, for
%                          traceability
%       baselineDecision - true if the rule-based baseline (DECIDERULES)
%                          flags the part as defective, independent of AI
%       disagreement     - true if the AI and the rule-based baseline
%                          reached different conclusions
%
%   Fixes relative to the original version of this file:
%     - [FAIL; PASS] were undefined variables (guaranteed error on call).
%       This dataset's actual labels, from foldernames labeling on
%       MVTec's own folders, are 'good'/'defective' - not 'PASS'/'FAIL'.
%     - The "Image Standardization" step (grayscale, resize to 224x224,
%       im2double) existed in the Live Script but was missing here after
%       the refactor into a function - without it, abs(I - avgI) on raw
%       uint8 images silently saturates at 0 instead of going negative,
%       and mask (native resolution) vs. BW (forced to 224x224) would
%       mismatch in size.
%     - evidenceMetrics was declared as an output but never computed.
%     - mask - BW (arithmetic) produced signed -1/0/1 values instead of a
%       clean binary mask; changed to mask & BW (logical AND), keeping
%       only difference-flagged pixels that fall inside the bristle
%       region.
%     - imshow(...) debug calls removed - fine for one-off exploration,
%       but this function runs in a loop over the whole test set in
%       Task 4/5, where they'd pop a new figure window per image.
%
%   See also SEGMENTBRISTLE, EXTRACTEVIDENCEMETRICS, DECIDERULES,
%   CLASSIFYTOOTHBRUSH.

    arguments
        I
        avgI
        net (1,1) dlnetwork
        classNames
    end

    if ischar(I) || isstring(I)
        I = imread(I);
    end
    I = uint8(I);

    % ---- Preprocess ----
    % 2-D Gaussian smoothing. (The original used imgaussfilt3, the 3-D/
    % volumetric filter - on an RGB image that blurs across the R/G/B
    % planes as if they were depth slices, which corrupts color rather
    % than denoising. imgaussfilt is the 2-D version and filters each
    % channel independently, which is almost certainly what was meant.)
    Ismoothed = imgaussfilt(I, 4);

    % ---- Bristle region mask ----
    BW = segmentBristle(Ismoothed);
    BW = imresize(BW, [224 224]);
    BW = im2double(BW);

    % ---- Standardize both images identically before comparing ----
    currImg = rgb2gray(Ismoothed);
    currImg = imresize(currImg, [224 224]);
    currImg = im2double(currImg);

    avgImgStd = im2gray(avgI);
    avgImgStd = imresize(avgImgStd, [224 224]);
    avgImgStd = im2double(avgImgStd);

    % ---- Difference-from-average evidence mask ----
    difference = abs(currImg - avgImgStd);
    mask = difference > 0.12;
    mask = bwareaopen(mask, 20);

    % Keep only the differences that fall inside the bristle region.
    maskEvidence = mask & logical(BW);
    evidenceOverlay = labeloverlay(im2uint8(currImg), maskEvidence);

    % ---- Interpretable metrics (Task 2, Step 5) ----
    evidenceMetrics = extractEvidenceMetrics(maskEvidence);

    % ---- Rule-based baseline (Task 2, Step 6) ----
    baselineDecision = decideRules(evidenceMetrics);

    % ---- AI classification (Task 3) ----
    [finalLabel, confidenceScore] = classifyToothbrush(net, classNames, I);

    % ---- Disagreement flag ----
    aiSaysDefective = (finalLabel == "defective");
    disagreement = aiSaysDefective ~= baselineDecision;
end
