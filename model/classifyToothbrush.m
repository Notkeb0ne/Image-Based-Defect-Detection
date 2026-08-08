function [aiLabel, aiScore] = classifyToothbrush(net, classNames, roiForNet)
%CLASSIFYTOOTHBRUSH Give a label and confidence score for one image.
%   [AILABEL, AISCORE] = CLASSIFYTOOTHBRUSH(NET, CLASSNAMES, ROIFORNET)
%   NET is the trained dlnetwork. CLASSNAMES is the class list in the
%   same order the network was trained with (e.g. categories(...) on the
%   training labels). ROIFORNET is the image to classify.
%
%   Renamed from classify.m: a function named classify.m shadows MATLAB's
%   own built-in classify function on your path - risky even though this
%   file only ever calls itself deliberately. Logic is otherwise your
%   original approach (dlarray formatting, predict, extractdata) - it was
%   already technically sound.
%
%   Fix: categories(...) returns a cell array. Indexing it with
%   classes(idx) (parentheses) returns a 1x1 cell, not the text itself,
%   which silently breaks later comparisons like aiLabel == "defective".
%   Converting classNames to a string array up front makes aiLabel come
%   out as a proper string scalar.
%
%   Second fix: im2single(img) doesn't just change the numeric type, it
%   RESCALES uint8 [0,255] down to [0,1] - but imagePretrainedNetwork's
%   resnet18 has its own normalization built into its first layers,
%   calibrated for raw [0,255] input (it divides by 255 itself). Running
%   im2single first meant the network was seeing values effectively
%   divided by 255 twice, leaving near-zero input reaching the actual
%   convolutional layers - consistent with the barely-above-0.5
%   confidence scores and non-discriminating predictions this was
%   producing. single(img) is a plain type cast (255 stays 255.0), not a
%   rescale - this matches the official imagePretrainedNetwork example
%   (X = single(im); scores = predict(net,X);).

    arguments
        net (1,1) dlnetwork
        classNames
        roiForNet
    end

    classNames = string(classNames);

    % Puts in correct format for predict
    img = imresize(roiForNet, [224 224]);
    img = single(img);
    img = dlarray(img, "SSCB");

    % Runs through net
    output = predict(net, img);

    % Confidence score and label
    scores = extractdata(output);
    [aiScore, idx] = max(scores, [], 1);   % explicit dim - safer if this
                                            % is ever adapted for batches
    aiLabel = classNames(idx);
end
