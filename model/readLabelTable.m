function labelTable = readLabelTable(csvPath)
%READLABELTABLE Robustly read a label CSV written by writetable(...).
%   LABELTABLE = READLABELTABLE(CSVPATH) reads CSVPATH with an explicit
%   comma delimiter and 'VariableNamingRule','preserve'. The explicit
%   delimiter matters here: readtable's automatic delimiter detection was
%   being thrown off by the file-path values (which contain both spaces
%   and slashes, e.g. from "/MATLAB Drive/toothbrush/..."), and treating
%   "/" as the field delimiter instead of ",", scrambling the header row
%   into path fragments ("MATLAB Drive", "toothbrush", "train", ...).
%   Being explicit removes the guesswork.
%
%   If a 'label' column still isn't found after that, this throws an
%   error listing the columns that were found and the raw first couple of
%   lines of the file, rather than the generic "Unrecognized table
%   variable name" error you'd get from trying to access it directly.

    arguments
        csvPath (1,1) string
    end

    if ~isfile(csvPath)
        error('readLabelTable:fileNotFound', ...
            'Cannot find %s from the current folder (%s).', csvPath, pwd);
    end

    labelTable = readtable(csvPath, 'Delimiter', ',', 'ReadVariableNames', true, ...
        'TextType', 'string', 'VariableNamingRule', 'preserve');

    if ~ismember('label', labelTable.Properties.VariableNames)
        rawText = fileread(csvPath);
        rawLines = strsplit(rawText, newline);
        rawPreview = strjoin(rawLines(1:min(2, numel(rawLines))), newline);

        error('readLabelTable:missingLabelColumn', ...
            ['%s was read back without a column named ''label''.\n' ...
             'Columns actually found: %s\n\n' ...
             'Raw first line(s) of the file:\n%s'], ...
            csvPath, strjoin(labelTable.Properties.VariableNames, ', '), rawPreview);
    end

    labelTable.label = categorical(labelTable.label);
end
