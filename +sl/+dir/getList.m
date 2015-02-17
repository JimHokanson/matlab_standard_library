function varargout = getList(root_folder_path,varargin)
%getList Return a list of files and/or folders in a directory with many options
%
%   STATUS: 
%   2015-02-17 - recursive listing working with extension filtering, LOTS OF ROOM FOR IMPROVEMENT
%
%
%   Calling Forms:
%   --------------
%   TODO: THIS IS OUT OF DATE
%
%   list_result = sl.dir.getList(root_folder_path,varargin)
%
%   Output:
%   -------
%   list_result : sl.dir.file_list_result
%   
%
%
%   Optional Inputs:
%   ----------------
%   
%       ========= Output format/type related =====
%
%   output_type : {'object','names','paths','dir'}
%       TODO: Document what this means ...
%   search_type : {0,1,2,'files','folders','both'}
%       - 'files' or 0 : find only files
%       - 'folders' or 1 : find only folders
%       - 'both' or 2: find files and folders
%   recursive : false
%       If true, results are included from subdirectories in addition to
%       just the root directory
%   need_dir_props: false
%       If true, then the 
%   enforce_single_file_match : (default false) NOT YET IMPLEMENTED
%       If true, then an error will be thrown if a single match is not
%       found. This can be used to throw a bit nicer of an error message
%       and to make the calling code not as messy.
%
%       =============   File filtering    ==========
%
%   extension : default ''
%       If not empty filters on the extension. A leading period is optional.
%   file_regex : default ''
%       If not empty, filters file names based on using the supplied string
%       as a pattern to regexp(). All special characters should be escaped.
%   file_pattern : default ''
%       If not empty, filters the file names based on using the string.
%       Unlike 'file_regex', only * characters (and possibly ?) are
%       supported. This also means that chacters like '.' are treated as
%       literals rather than as special regular expression characters.
%
%       ==============  Folder filtering ========
%
%
%
%
%
%
%
%

%
%   regexp : (default '')
%       If not empty filters based on regex matches. Regular expressions
%       must be properly escaped prior to function (e.g. matching a period
%       requires a leading backslash)
%   use_java : (default false), if true the result uses Java, this can
%       avoid some problems with Unicode file paths. Eventually I would
%       like to have code that makes this unecessary and just works.
%
%   Improvements:
%   -------------
%   - ignore hidden files
%   - ignore certain directories
%   - return or don't return dir results - date modified ...
%   - relative path support :/
%
%   Not Yet Supported:
%   ------------------
%   Ability to do multi-level path filtering
%
%   Examples:
%   ---------
%
%
%   See Also:
%   sl.dir.rdir

%{

    tic;
    wtf = getDirectoryTree('C:\D\repos\matlab_git\matlab_SVN','','','\.m','files');
    toc;


	wtf = sl.dir.getList('C:\D\repos\matlab_git\matlab_SVN','recursive',true)

	wtf = sl.dir.getList('C:\D\repos\matlab_git\matlab_SVN','recursive',true,'extension','.m')


    tic;
	wtf = sl.dir.rdir('C:\D\repos\matlab_git\matlab_SVN\**\*.m');
    toc;

%}

if nargout == 0
    return
else
    %TODO: Validate nargout being 1 or 2 ...
end



%Speed approaches NYI
%----------------------
%1) Use mex or .NET
%2) filter heavily on listing
%3) System specific listing

t_tic = tic;

%Optional Inputs
%=================================
%Results related
%---------------------------------------------
in.output_type = 'object'; %DONE {'object','names','paths','dir'}
in.search_type = 0; %DONE {0,1,2,'files','folders','both'}
in.recursive = false; %HALF-DONE
in.need_dir_props = false;
in.natural_sort_files = false; %NYI - http://www.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
in.enforce_single_file_match = false;

%File filtering
%---------------------------------------------
in.extension = ''; %HALF_DONE file extension
in.file_regex = ''; %NOTE: All regex must be escaped
in.file_pattern = '';%NYI: this would be  
in.date_filter = []; %NYI, should be a function handle

%Folder filtering
%---------------------------------------------
in.folder_regex = '';
in.folders_to_ignore = {}; %NYI

in = sl.in.processVarargin(in,varargin);

in = h__cleanOptionalInputs(in);
%===============================================================

[file_filters,need_dir_1]   = h__setupFileFilters(in);
[folder_filters,need_dir_2] = h__setupFolderFilters(in);

need_dir_approach = in.need_dir_props || need_dir_1 || need_dir_2;

if ~need_dir_approach && in.recursive && ispc && in.search_type == 0
    s = h__getFilesDotNet(root_folder_path,in);
else
    %Basic approaches using dir()
    %------------------------------
    if in.recursive
        s = h__runBasicRecursiveApproach(root_folder_path,in);
    else
        s = h__runBasicApproach(root_folder_path,in);
    end
end


%Setup output
%-----------------------------------------------
varargout = h__setupOutput(root_folder_path,s,in,nargout,t_tic);

end  %------------------------  End of sl.dir.getList ---------------------

function in = h__cleanOptionalInputs(in)
%x Makes sure optional inputs are standardized and agree
%
%
%

if strcmp(in.output_type,'dir')
   in.need_dir_props = true; 
end

%Change possible characters to numbers
in = h__fixInType(in);

end  %------------   End of h__cleanOptionalInputs    ---------------------

function s = h__getFilesDotNet(root_folder_path,in)

    s = struct;
    
    %TODO: Make this a function
    if ~isempty(in.file_pattern)
        search_pattern = in.file_pattern;
    elseif ~isempty(in.extension)
        if in.extension(1) == '.'
            search_pattern = ['*' in.extension];
        else
            search_pattern = ['*.' in.extension];
        end
    else
        search_pattern = '*';
    end
    
    %https://msdn.microsoft.com/en-us/library/07wt70x2%28v=vs.110%29.aspx
    temp = System.IO.Directory.GetFiles(root_folder_path,search_pattern,...
        System.IO.SearchOption.AllDirectories);
    
    %TODO: Need to allow filtering as well
    s.file_paths   = cell(temp);
    s.folder_names = {};
    s.file_names   = sl.dir.getFileName(s.file_paths);
    s.folder_paths = {};
    s.d_files      = [];
    s.d_folders    = [];

end

function s = h__runBasicApproach(root_folder_path,in)
    %NOT YET IMPLEMENTED
    switch in.search_type
        case 0
            h__getFiles(root_folder_path);
        case 1
            h__getFolders(root_folder_path);
        case 2
            h__getFilesAndFolders(root_folder_path,in);
    end

end

function s = h__runBasicRecursiveApproach(root_folder_path,in)

    MAGIC_CELL_LENGTH = 10000;

    file_filters   = h__setupFileFilters(in);
    folder_filters = h__setupFolderFilters(in);

    results = cell(1,MAGIC_CELL_LENGTH);
    
    folders_to_check = cell(1,MAGIC_CELL_LENGTH);
    folders_to_check{1} = root_folder_path;
    cur_list_length = 1;
    
    done = false;
    cur_I = 0;
    while ~done
        cur_I    = cur_I + 1;
        cur_root = folders_to_check{cur_I};
        
        %Main listing call
        s = h__getFilesAndFolders(cur_root,in,file_filters,folder_filters);
        results{cur_I} = s;
        
        %Update with more folders to check
        %---------------------------------
        folder_paths = s.folder_paths;
        if ~isempty(s.folder_paths)
            n_folders = length(folder_paths);
            folders_to_check(cur_list_length+1:cur_list_length+n_folders) = folder_paths;
            cur_list_length = cur_list_length + n_folders;
        end
        done = cur_I == cur_list_length;
    end
    
    %Reduce results to a single structure
    %------------------------------------
    r2 = [results{1:cur_I}];
    %At this point r2 is a structure array, let's create a single structure
    s = struct;
    s.file_names   = [r2.file_names];
    s.folder_names = [r2.folder_names];
    s.file_paths   = [r2.file_paths];
    s.folder_paths = [r2.folder_paths];
    s.d_files      = [r2.d_files];
    s.d_folders    = [r2.d_folders];

end  %------------------ End of h__runBasicRecursiveApproach --------------

function output = h__setupOutput(root_folder_path,s,in,n_outputs,t_tic)
%
%   Inputs:
%   -------
%     s.file_names   = [r2.file_names];
%     s.folder_names = [r2.folder_names];
%     s.file_paths   = [r2.file_paths];
%     s.folder_paths = [r2.folder_paths];
%     s.d_files      = [r2.d_files];
%     s.d_folders    = [r2.d_folders];
%
%


output = cell(1,n_outputs);
%in.output_type
%in.search_type
%{'object','names','paths','dir'}
%file,folder,both
switch in.output_type
    case 'object'
        %TODO: We probably shouldn't return more than we have to
        %as different listing methods might not return everything ...
        lr = sl.dir.list_result;
        lr.root_folder_path = root_folder_path;
        lr.folder_names = s.folder_names;
        lr.file_names   = s.file_names;
        lr.file_paths   = s.file_paths;
        lr.folder_paths = s.folder_paths;
        lr.d_folders    = s.d_folders;
        lr.d_files      = s.d_files;
        lr.elapsed_time = toc(t_tic);
        output{1} = lr;
    case 'names'
        switch in.search_type
            case 0
                output{1} = s.file_names;
            case 1
                output{1} = s.folder_names;
            case 2
                output{1} = s.file_names;
                output{2} = s.folder_names;
        end
    case 'paths'
        switch in.search_type
            case 0
                output{1} = s.file_paths;
            case 1
                output{1} = s.folder_paths;
            case 2
                output{1} = s.file_paths;
                output{2} = s.folder_paths;
        end
    case 'dir'
        switch in.search_type
            case 0
                output{1} = s.d_files;
            case 1
                output{1} = s.d_folders;
            case 2
                output{1} = s.d_files;
                output{2} = s.d_folders;
        end
end



end %---------------------------------   End of h__setupOutput  -----------

function in = h__fixInType(in)
%x 
%
%   Converts characters to numerics and makes sure numerics are in range
%
%

if ischar(in.search_type)
    switch in.search_type(1:2)
        case 'fi'
            in.search_type = 0;
        case 'fo'
            in.search_type = 1;
        case 'bo'
            in.search_type = 2;
        otherwise
            error('Unrecognized return type: %s',in.search_type)
    end
else
    %Valid values are 0, 1, or 2
    if ~ismember(in.search_type,0:2)
        error('Unrecognized search type: %d',in.search_type)
    end
end

end  %----------    End of h__fixInType    --------------------


%=====================    LISTING PROGRAMS   ==============================
function h__getFiles(root_folder_path)

% % % if ~isempty(in.extension)
% % %     if in.extension(1) == '.'
% % %         ext_use = ['*' in.extension];
% % %     else
% % %         ext_use = ['*.' in.extension];
% % %     end
% % % else
% % %     ext_use = '';
% % % end

end

function h__getFolders(root_folder_path)

end

function s = h__getFilesAndFolders(root_folder_path,in,file_filters,folder_filters)
%x  return a list of files and folders in a directory
%
%   This is the main function for listing results where both the file and
%   folder results are needed. This is probably most useful for the
%   recursive directory approach.
%
%   Inputs:
%   -------
%   root_folder_path :
%   in : struct
%       Optional inputs
%   file_filters : cell of function handles
%   folder_filters : cell of folder filters
%
%
%   TODO: It would be good to be able to:
%   1) Get a request that separates files and folders
%   2) filters both of these based on a criteria

s = struct;

d = dir(root_folder_path)'; %Transpose to make a row vector

is_dir_mask = [d.isdir];

d_files   = d(~is_dir_mask);
d_folders = d(is_dir_mask);

file_names   = {d_files.name};
folder_names = {d_folders.name};

[file_names,d_files] = h__filterFiles(file_names,d_files,file_filters);
[folder_names,d_folders] = h__filterFolders(folder_names,d_folders,in);

s.root_path    = root_folder_path;
s.file_names   = file_names;
s.folder_names = folder_names;
s.file_paths   = sl.dir.fullfileCA(root_folder_path,file_names);
s.folder_paths = sl.dir.fullfileCA(root_folder_path,folder_names);
s.d_files      = d_files;
s.d_folders    = d_folders;

end %-------------------    End of h__getFilesAndFolders  -----------------

%================== END OF LISTING PROGRAMS ===============================



function [file_names,d_files] = h__filterFiles(file_names,d_files,file_filters)
%
%   Runs each of the file filters on the inputs and removes any values that
%   don't match the filter
%

for iFilter = 1:length(file_filters)
   fh = file_filters{iFilter};
   remove_mask = fh(file_names,d_files);
   
   %??? - Do we combine all the masks first or filter first ???
   file_names(remove_mask) = [];
   d_files(remove_mask) = [];
end


end

function [folder_names,d_folders] = h__filterFolders(folder_names,d_folders,in)

%For now we'll only filter leading periods
%
%This eventually should be expanded to all of the other options

%TODO: Some directories may have empty names if it is a failed symbolic
%link, thus we should really check for any null entries first ...


%1) Filtering out leading periods
%--------------------------------
first_char_array = h__getFirstChar(folder_names);
leading_period_mask = first_char_array == '.';
folder_names(leading_period_mask) = [];
d_folders(leading_period_mask) = [];



end

function first_char_array = h__getFirstChar(cellstr_in)
%
%   Simple helper that grabs the first character of every string
%
%   Written for filtering folders if the first character is a period.
%
n = length(cellstr_in);
space = ' ';
first_char_array = space(ones(1,n));
for iStr = 1:n
    first_char_array(iStr) = cellstr_in{iStr}(1);
end
end

%======================      Filters     ==================================

function [folder_filters,need_dir] = h__setupFolderFilters(in)

%Folder filtering
%-------------------------------
%1) leading dot filtering
%2) folder_regex
%3) folders_to_ignore
%4) folders_to_keep

    folder_filters = {};
    need_dir = false;
end

function [file_filters,need_dir] = h__setupFileFilters(in)
%Setup file filters
%-------------------
%1) ext - only if not done in the search
%2) file_regex
%3) date filter

file_filters = cell(1,1); %Expand as we get more filters

%Extension filtering
%--------------------
if in.recursive && ~isempty(in.extension)
    %mask = h__filterByExtension(file_names,dot_leading_extension)
    dot_leading_extension = in.extension;
    if dot_leading_extension(1) ~= '.'
       dot_leading_extension = ['.' dot_leading_extension]; 
    end
    %Match .extension where the dot is a literal and at the end of the
    %string
    dot_leading_extension_pattern = ['\' dot_leading_extension '$'];
    file_filters{1} = @(file_names,~)cellfun('isempty',regexp(file_names,dot_leading_extension_pattern,'once'));

end

file_filters(cellfun('isempty',file_filters)) = [];

need_dir = false;

end



% % % function remove_mask = h__filterByExtension(file_names,dot_leading_extension_pattern)
% % %     %
% % % %
% % % %   See Also:
% % % %   h__setupFileFilters
% % % %
% % % %   TODO: We can remove this function and just
% % %    remove_mask = cellfun('isempty',regexp(file_names,dot_leading_extension_pattern,'once'));
% % %    
% % % end

%======================   END OF FILTERS   ================================


%{

.NET could be used rather effectively for recursive file searching but we
it would really be beneficial to write a nice enumerated retriever

%.NET 
%http://support.microsoft.com/kb/303974

%Is this needed or done by default? - already done by default
%NET.addAssembly('System.IO');

root_path = 'C:\D\repos\matlab_git\matlab_SVN';

wtf = System.IO.Directory.GetDirectories(root_path,'*.*');



tic;
wtf = System.IO.Directory.GetFiles(root_path,'*.m',System.IO.SearchOption.AllDirectories);
results = cell(wtf);
toc;

%This is really slow, can we do all of this with C#
results = cell(1,wtf.Length);
en = wtf.GetEnumerator
for iFolder = 1:wtf.Length
    en.MoveNext;
    results{iFolder} = char(en.Current);
end
toc;

%}


%{
Other Implementations
---------------------

49 http://www.mathworks.com/matlabcentral/fileexchange/1492-subdir--new-
6 http://www.mathworks.com/matlabcentral/fileexchange/1570-dirdir
13 http://www.mathworks.com/matlabcentral/fileexchange/2118-getfilenames-m
33 http://www.mathworks.com/matlabcentral/fileexchange/8682-dirr--find-files-recursively-filtering-name--date-or-bytes-
22 http://www.mathworks.com/matlabcentral/fileexchange/15505-recursive-dir
75 http://www.mathworks.com/matlabcentral/fileexchange/15859-subdir--a-recursive-file-search
5 http://www.mathworks.com/matlabcentral/fileexchange/16216-regexpdir
4 http://www.mathworks.com/matlabcentral/fileexchange/16217-wildcardsearch
131 http://www.mathworks.com/matlabcentral/fileexchange/19550-recursive-directory-listing
13 http://www.mathworks.com/matlabcentral/fileexchange/21791-search-files-recursively--dir2-
7 http://www.mathworks.com/matlabcentral/fileexchange/22829-file-list
5 http://www.mathworks.com/matlabcentral/fileexchange/24567-searchfile
5 http://www.mathworks.com/matlabcentral/fileexchange/25753-new-dir-m
16 http://www.mathworks.com/matlabcentral/fileexchange/31343-enlist-all-file-names-in-a-folder-and-it-s-subfolders
26 http://www.mathworks.com/matlabcentral/fileexchange/32036-dirwalk-walk-the-directory-tree
91 http://www.mathworks.com/matlabcentral/fileexchange/32226-recursive-directory-listing-enhanced-rdir
5 http://www.mathworks.com/matlabcentral/fileexchange/39804-creating-file-and-folder-trees
17 http://www.mathworks.com/matlabcentral/fileexchange/40016-recursive-directory-searching-for-multiple-file-specs
9 http://www.mathworks.com/matlabcentral/fileexchange/40020-dir-read
30 http://www.mathworks.com/matlabcentral/fileexchange/40149-expand-wildcards-for-files-and-directory-names
15 http://www.mathworks.com/matlabcentral/fileexchange/41135-folders-sub-folders
7 http://www.mathworks.com/matlabcentral/fileexchange/43704-getdirectorycontents
5 http://www.mathworks.com/matlabcentral/fileexchange/44089-rdir-dos
3 http://www.mathworks.com/matlabcentral/fileexchange/46873-dir-crawler-m

%}

%{

Interesting Questions:
http://www.mathworks.com/matlabcentral/answers/2221-how-can-i-use-dir-with-multiple-search-strings-or-join-the-results-of-two-dir-calls


%}