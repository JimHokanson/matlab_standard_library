function dir_names = listNonHiddenFolders(rootPath,varargin)
%listNonHiddenFolders  Lists not hidden folders and omits .. & .
%
%   This function returns subfolders which are not hidden. It also omits
%   the . and .. directories.
%
%   dir_names = sl.dir.listNonHiddenFolders(rootPath)
%
%   TODO: document optional inputs
%
%   TODO: This only respects the hidden attribute and not whether or
%   not we are showing hidden files
%   
%   See Also:
%   fileattrib

in.keep_files = false;
in = sl.in.processVarargin(in,varargin);

d         = dir(rootPath);
if in.keep_files
    keep_mask = true(1,length(d));
else
    keep_mask = [d.isdir];
end

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