function my_mex_files = locateMexFiles(root,extstr)
% LOCATEMEXFILES Recursively locate all mex files on the path.
%
% mex_files = locateMexFiles(*root,*extstr)
%
% Returns the full path to all mex files. Will throw a warning if there are
% mex files available for architectures other than yours
%
% INPUTS
% =========================================================================
%   root   - (char) root directory to use for recursive search default: MATLAB_SVN_ROOT
%   extstr - (char) specifies the archtecture to compare against, default: all ( i.e. 'mex' )
%       mexglx
%       mexa64
%       mexmaci
%       mexmaci64
%       mexw32
%       mexw64
%
% OUTPUTS
% =========================================================================
%   mex_files - (char) full path to existing mex files
%
% tags: mex support, file management

if nargin < 2
    extstr = 'mex';
    if nargin < 1
        root = MATLAB_SVN_ROOT;
    end
end
% get everything on the path, separated into cells
path_cell = regexp(path,pathsep,'split');


% get only those directories on the path that are children of the matlab repo
key       = [regexptranslate('escape',[root,filesep]),'.+'];
path_cell = regexp(path_cell,key,'match','once');
mask      = ~cellfun(@isempty,path_cell);
path_cell = path_cell(mask);

mex_files      = cellfun(@(x)dir(fullfile(x,['*.',extstr,'*'])),path_cell,'UniformOutput',false);
mex_files      = vertcat(mex_files{:});
mex_file_names = {mex_files.name};
mex_file_names = unique(regexp(mex_file_names,'[^.]+','match','once'));

what_struct  = cellfun(@what,path_cell,'UniformOutput',false);
% CAA so sometimes this breaks...
what_struct    = [what_struct{:}];
my_mex_files   = {what_struct.mex};
my_mex_files   = regexp(vertcat(my_mex_files{:}),'[^.]+(?=\.mex)','match','once')';
mask           = ~cellfun(@isempty,my_mex_files);
my_mex_files   = my_mex_files(mask);

missing_files = setxor(mex_file_names,my_mex_files);
if ~isempty(missing_files)
    fprintf(2,'Missing Files:\n  %s',cellArrayToString(missing_files,'\n  '));
end

my_mex_files = cellfun(@which,my_mex_files,'UniformOutput',false);
end