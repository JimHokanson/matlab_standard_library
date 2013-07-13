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
%
%   IMPROVEMENTS
%   =======================================================================
%   I'd eventually like to implement this as a two step class method with
%   subclasses ...
%
% tags: directory, system utility

%Filter methods
%--------------------------------------------------------------------------
%name1
%   - .leading_char_ignore
%   - .ignore_exact
%   - 

%.dir_method - Implementation notes, these should filter out 
%--------------------------------------------------------------------------
%dir1 - Uses dir() command ...



in.filter_method       = @name1; %The idea is to allow custom filtering
%and maybe eventually custom input/output structures ...
in.ignore_exact        = {}; %Specify exact names of directories to ignore
in.leading_char_ignore = '.'; %This is an array of leading characters to ignore ...
in.init_size           = 1000;
in.growth_size         = 1000;
in.dir_method          = @dir1;  %This allows us
%directories that start with a specific character. By using only
%a single character we can optimize the filter ...
in.loop_method         = @normal1;  %This method would determine the output ...
[in,extras] = sl.in.processVarargin(in,varargin);



return

%MAIN CODE - Run without input checks
%====================================
output = getDirectoryTree_Helper(root,ignoreDir,bReturnAbsolutePath,wildcard,lower(returnOption));
end


function normal1()





end

function dir1(current_path)

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

