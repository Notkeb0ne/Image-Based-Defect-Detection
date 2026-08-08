function createAverageToothbrushImage()

projectRoot = fileparts(mfilename('fullpath'));

trainTable = readLabelTable(fullfile(projectRoot, 'toothbrushLabels_train.csv'));

% Keep only good images
goodTable = trainTable(trainTable.label == "good", :);

sumImage = [];

for k = 1:height(goodTable)

    I = im2double(imread(goodTable.filepath{k}));

    if isempty(sumImage)
        sumImage = zeros(size(I));
    end

    sumImage = sumImage + I;

end

avgImage = sumImage / height(goodTable);

imwrite(avgImage, fullfile(projectRoot, 'ToothAveraged.png'));

fprintf("Created ToothAveraged.png using %d good images.\n", height(goodTable));

end