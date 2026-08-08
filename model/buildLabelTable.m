function labelTable = buildLabelTable(datasetRoot, group1Folders, group1Label, group2Folders, group2Label)
%BUILDLABELTABLE Build a two-class label table from folders of images.
%   LABELTABLE = BUILDLABELTABLE(DATASETROOT, GROUP1FOLDERS, GROUP1LABEL, ...
%       GROUP2FOLDERS, GROUP2LABEL) scans each folder in GROUP1FOLDERS
%   (relative to DATASETROOT) and labels every image GROUP1LABEL, and
%   does the same for GROUP2FOLDERS labeling GROUP2LABEL. Returns a table
%   with columns:
%       filepath      - full path to each image
%       label         - categorical
%       originalClass - the source subfolder name, kept for traceability
%
%   Example:
%       t = buildLabelTable('Downloads/toothbrush', ...
%           {'train/good', 'test/good'}, 'good', ...
%           {'test/defective'}, 'defective');

    arguments
        datasetRoot (1,1) string
        group1Folders (1,:) cell
        group1Label (1,1) string
        group2Folders (1,:) cell
        group2Label (1,1) string
    end

    rows1 = scanFolders(datasetRoot, group1Folders, group1Label);
    rows2 = scanFolders(datasetRoot, group2Folders, group2Label);

    labelTable = [rows1; rows2];

    if isempty(labelTable) || ~ismember('label', labelTable.Properties.VariableNames)
        error('buildLabelTable:noImagesFound', ...
            ['No images were found in any of the specified folders under "%s".\n' ...
             'Current folder (pwd) is: %s\n\n' ...
             'datasetRoot is a relative path - it only resolves correctly if pwd ' ...
             'is the right starting point. Easiest fix: replace datasetRoot with ' ...
             'an absolute path instead, e.g.\n' ...
             '  datasetRoot = "C:\\Users\\you\\Downloads\\toothbrush";   %% Windows\n' ...
             '  datasetRoot = "/Users/you/Downloads/toothbrush";        %% Mac/Linux\n\n' ...
             'Also double check the images are lowercase .png - dir(''*.png'') is ' ...
             'case-sensitive on Mac/Linux.'], ...
            datasetRoot, pwd);
    end

    labelTable.label = categorical(labelTable.label);
end

% ------------------------------------------------------------------
% Local helper functions
% ------------------------------------------------------------------

function rows = scanFolders(datasetRoot, folderList, labelName)
    rows = table();
    for i = 1:numel(folderList)
        folderPath = fullfile(datasetRoot, folderList{i});
        files = dir(fullfile(folderPath, '*.png'));
        if isempty(files)
            warning('buildLabelTable:emptyFolder', ...
                'No images found in %s', folderPath);
            continue;
        end

        n = numel(files);
        filepath = fullfile({files.folder}', {files.name}');
        label = repmat({char(labelName)}, n, 1);
        originalClass = repmat({lastFolderName(folderList{i})}, n, 1);

        newRows = table(filepath, label, originalClass, ...
            'VariableNames', {'filepath', 'label', 'originalClass'});
        rows = [rows; newRows]; %#ok<AGROW>
    end
end

function name = lastFolderName(folderSpec)
    % 'test/defective' or 'train\good' -> 'defective' / 'good'
    parts = strsplit(folderSpec, {'/', '\'});
    name = parts{end};
end
