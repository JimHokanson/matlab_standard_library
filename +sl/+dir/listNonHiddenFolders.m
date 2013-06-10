function dir_names = listNonHiddenFolders(rootPath)
%listNonHiddenFolders Lists not hidden folders and omits .. & .
%
%   This function returns subfolders which are not hidden. It also omits
%   the . and .. directories.
%
%   dir_names = listNonHiddenFolders(rootPath)
%   
%   See Also:
%       fileattrib

d         = dir(rootPath);
keep_mask = [d.isdir];
dir_names = {d.name};

if ispc 
    %use fileattrib
    keep_mask(strcmp(dir_names,'.'))  = false;
    keep_mask(strcmp(dir_names,'..')) = false;
    for I = find(keep_mask)
       [~,stats]    = fileattrib(fullfile(rootPath,dir_names{I}));
       keep_mask(I) = ~stats.hidden;
    end
elseif ismac
    %Hidden on mac - starts with a dot
    isDot = cellfun(@firstCharIsDot,dir_names);
    keep_mask(isDot) = false;
else
    error('Unix not implemented yet')
end

dir_names = dir_names(keep_mask);


end

function flag = firstCharIsDot(name)
     flag = name(1) == '.';
end