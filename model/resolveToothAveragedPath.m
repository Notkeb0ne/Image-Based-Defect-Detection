function avgImgPath = resolveToothAveragedPath(projectRoot)
%RESOLVETOOTHAVERAGEDPATH Find ToothAveraged.png wherever it currently is.
%   AVGIMGPATH = RESOLVETOOTHAVERAGEDPATH(PROJECTROOT) checks, in order:
%   directly inside the project folder, then as a sibling of the project
%   folder (one level up) - this file has moved between both locations
%   during setup, so both are checked rather than assuming one. Throws a
%   clear error listing both checked locations if neither has it.

    arguments
        projectRoot (1,1) string
    end

    candidates = [
        fullfile(projectRoot, 'ToothAveraged.png')
        fullfile(fileparts(projectRoot), 'ToothAveraged.png')
    ];

    for i = 1:numel(candidates)
        if isfile(candidates(i))
            avgImgPath = candidates(i);
            return;
        end
    end

    error('resolveToothAveragedPath:notFound', ...
        ['Cannot find ToothAveraged.png in either of these locations:\n' ...
         '  %s\n  %s\n' ...
         'Move it to one of these, or edit the candidate list in ' ...
         'resolveToothAveragedPath.m directly.'], candidates(1), candidates(2));
end
