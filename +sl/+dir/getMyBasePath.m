function base_path = getMyBasePath(file_name,n_dirs_up)
%getMyPath  Returns base path of calling function
%
%   s = getMyBasePath(*file_name,*n_dirs_up)
%
%   
%
%   OUTPUTS
%   =======================================================================
%   base_path : path to cotaining folder of function that is calling
%       this function.
%
%   INPUTS
%   =======================================================================
%   file_name : (default ''), if empty, examines calling function,
%           otherwise it runs which() on the name to resolve the path
%
%           When called from a script or command line returns the current 
%           directory.
%
%   n_dirs_up : (default 0), if not 0, goes up the path by the specified #
%               of directories
%
%   NOTES
%   =======================================================================
%   Note this replaces:
%       fileparts(mfilename('fullpath')) 
%   which I find hard to remember ..
%
%   EXAMPLES:
%   =======================================================================
%   1) Typical usage case:
%
%       base_path = getMyBasePath();
%
%   2) Useful for executing in a script where you want the script path
%   
%       base_path = getMyBasePath('myScriptsName')
%
%   3) TODO: Provide example with n_dirs_up being used
%
%   IMPROVEMENTS
%   =================================
%   1) Provide specific examples ...
%
%
%   See Also:
%       sl.dir.filepartsx

if ~exist('n_dirs_up','var')
    n_dirs_up = 0;
end

%NOTE: the function mfilename() can't be used with evalin
%   (as of 2009b)

%We use the stack to get the path
if nargin == 0 || isempty(file_name)
    stack = dbstack('-completenames');
    if length(stack) == 1
        base_path = cd;
    else
        %NOTE: 1 refers to this function, 2 refers to the calling function
        base_path = fileparts(stack(2).file);
    end
else
    filePath = which(file_name);
    base_path = fileparts(filePath);
end

if n_dirs_up ~= 0
   base_path = sl.dir.filepartsx(base_path,n_dirs_up); 
end

end