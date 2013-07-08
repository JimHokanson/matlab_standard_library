function output = getDirectoryTree(root,varargin)
%getDirectoryTree Retrieve all subfolders of a root directory
%
%   output = sl.dir.getDirectoryTree(root,varargin)
%
%
%   INPUTS
%   =======================================================================
%   root
%   
%   OPTIONAL INPUTS
%   =======================================================================
%
% INPUTS
% =========================================================================
%   root         : (char) fullpath to directory
%   ignoreDir    : (cell) default: {'.','..','.svn','private'}, directories to
%                   ignore, if empty uses the default
%   bReturnAbsolutePath : (logical) default: true, whether directories are
%                         returned in absolute format or with just their
%                         name (not relative)
%   wildcard     : (char) default: ''
%   returnOption : (char, default 'dir')
%                   - 'dir'
%                   - 'files'
%
%
% OUTPUTS
% =========================================================================
%   output : (cellstr) all the files and/or subdirectories of the root.
%              Output is -NOT- sorted.
%
% EXAMPLES
% =========================================================================
%
%
% tags: directory, system utility


%FEX SUBMISSIONS
%==========================================================================
%http://www.mathworks.com/matlabcentral/fileexchange/16217-wildcardsearch
%http://www.mathworks.com/matlabcentral/fileexchange/16216-regexpdir
%http://www.mathworks.com/matlabcentral/fileexchange/32226-recursive-directory-listing-enhanced-rdir
%http://www.mathworks.com/matlabcentral/fileexchange/19550-recursive-directory-listing

in.ignore_exact        = {'private'}; %NOTE: Other directories that we might
%have typically ignored ...
in.leading_char_ignore = '.'; %This can be used to specify ignoring
in.no_sub_char         = '+@';
in.init_size           = 1000;
in.growth_size         = 1000;
%directories that start with a specific character. By using only
%a single character we can optimize the filter ...
[in,extras] = sl.in.processVarargin(in,varargin);

%TODO: probably need to run unique on all inputs ...
in.ignore_exact = unique([{'.' '..'} in.ignore_exact]);

%parent_index  name

cur_index = 1;
n_total   = 
parent_index = zeros(1,in.init_size);
names        = cell(1,in.init_size);

while cur_index < n_total
   next_dir = 
    
    
    
end










output = [];

return

ignoreDir, bReturnAbsolutePath, wildcard, returnOption



%MAIN CODE - Run without input checks
%====================================
output = getDirectoryTree_Helper(root,ignoreDir,bReturnAbsolutePath,wildcard,lower(returnOption));
end


function output = getDirectoryTree_Helper(root,ignoreDir,bReturnAbsolutePath, wildcard,returnOption)
%

% get the directory contents
[files,is_dir] = mex_dir(root);

if ischar(files)
    files = {files};
end

%true - we know these inputs are unique
mask = ismember_str(files,ignoreDir,true);

files(mask)    = [];
is_dir(mask)   = [];

% create list of subdirs by cropping files that are not directories
dir_list          = files;
dir_list(~is_dir) = [];

isAbsoluteDir = false;
switch returnOption
    case 'files'    
        % apply wildcard
        if ~isempty(wildcard)
            start_ca = regexp(files,wildcard,'start','once');
            files(cellfun('isempty',start_ca)) = [];
            
            if isempty(files)
                files = {}; % enforce cell
            end
        end
        
        if bReturnAbsolutePath
            files = fullfileCA(root,files);
        end
        
        output = files;
    case 'dir'
        if ~isempty(wildcard)
            start_ca = regexp(dir_list,wildcard,'start','once');
            dir_list(cellfun('isempty',start_ca)) = [];
            
            if isempty(dir_list)
                dir_list = {}; % enforce cell
            end
        end
        
        if bReturnAbsolutePath
           dir_list = fullfileCA(root,dir_list);
           isAbsoluteDir = true;
        end
        
        output = dir_list;
end

%NOTE: This allows the output above to be relative
%and then we must correct it here for calling the function
if ~isAbsoluteDir
    dir_list = fullfileCA(root,dir_list);
end


% and get more from the subdirectories
%Could make this stacked (non-recursive)
%   although it doesn't seem all that slow to make the recursive calls ...
%Memory concatenation also doesn't seem that slow
for iiDir = 1:length(dir_list)
    output = [output; getDirectoryTree_Helper(dir_list{iiDir},ignoreDir, bReturnAbsolutePath,wildcard,returnOption)]; %#ok<AGROW>
end

end

