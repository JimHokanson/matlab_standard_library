function dir_names = listNonHiddenFolders(root_path,varargin)
%listNonHiddenFolders  Lists not hidden folders and omits .. & .
%
%   This function returns subfolders which are not hidden. It also omits
%   the . and .. directories.
%
%   folder_names = sl.dir.listNonHiddenFolders(root_path)
%
%   folders_and_files = sl.dir.listNonHiddenFolders(root_path,'keep_files',true)
%
%   paths = sl.dir.listNonHiddenFolders(root_path,'full_path',true)
%
%   Optional Inputs
%   ---------------
%   full_path : default false
%   keep_files : default false
%
%   See Also
%   --------
%   fileattrib

in.full_path = false;
in.keep_files = false;
in = sl.in.processVarargin(in,varargin);

d = dir(root_path);
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
       [~,stats] = fileattrib(fullfile(root_path,dir_names{I}));
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
if in.full_path
   dir_names = sl.dir.fullfileCA(root_path,dir_names); 
end


end

function flag = firstCharIsDot(name)
     flag = name(1) == '.';
end