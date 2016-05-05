function cd(path_to_cd_to)
%x Runs cd with error support
%
%   sl.dir.cd(path_to_cd_to)
%
%   Checks if a directory exists first before changing path to the
%   directory. If the directory is missing a nice error display is
%   presented.

if ~exist(path_to_cd_to,'dir')
   error_msg = sl.error.getMissingFileErrorMsg(path_to_cd_to);
   error(error_msg)
end

cd(path_to_cd_to);

end