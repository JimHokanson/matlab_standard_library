function varargout = getList(root_folder_path,varargin)
%x Return a list of files and/or folders in a directory with many options
%
%   This function gets a list of files and/or folders in a directory (and
%   possibly subdirectories) with many options for filtering and specifying
%   how the information should be returned (full paths, names, etc.)
%
%   The format is such that hopefully additional filters are relatively
%   easy to add and have everything kept well organized.
%
%   The function code is written so that it should be closest to being
%   as fast as what is possible given the Matlab approach. Additional
%   methods could be added which would allow the results to be obtained
%   via not Matlab approaches. This has already been done when searching
%   for files recursively on Windows, in which case .NET code is called.
%
%
%   Calling Forms: (Not comprehensive, see 'output_type' and 'search_type')
%   -----------------------------------------------------------------------
%   1) Default form where we are searching for files and the result is 
%   an object
%   
%   list_result = sl.dir.getList(root_folder_path,varargin)
%
%
%   2) Only return certain info, not the object
%   
%   file_names = sl.dir.getList(root_folder_path,...
%                       'output_type','names',varargin)
%
%
%   3) Return folders instead of files & returns as full paths
%   
%   folder_paths = sl.dir.getList(root_folder_path,'output_type','paths','search_type',folders',varargin)
%
%
%   4) File and folders when 'output_type' is not 'list_result'
%   
%   [file_names,folder_names] = sl.dir.getList(root_folder_path,...
%                       'output_type','names','search_type',both',varargin)
%
%
%
%   Output (See 'output_type' option):
%   ----------------------------------
%   list_result : sl.dir.list_result
%       An object that can contain both file and folder info.
%   file_names : cellstr
%       The name of each file, without the path
%   folder_names : cellstr
%       The name of each folder, without the path
%   file_paths : cellstr
%       Full paths to the file
%   folder_paths : cellstr
%       Full paths to the folder
%   d_files : struct
%       Same format as the output from dir() for each file
%           .name
%           .date
%           .bytes
%           .isdir
%           .datenum
%   d_folders : struct
%       Same format as the output from dir() for each folder
%
%
%
%   Input:
%   ------
%   root_folder_path : string
%       The folder to search for files or folders. It is recommended that
%       this be an absolute path although the function might work even if
%       it is relative, depending upon which outputs are desired.
%
%
%
%   Optional Inputs:
%   ----------------
%
%       ========= Output format/type related =====
%
%   enforce_single_file_match : (default false) NOT YET IMPLEMENTED
%       If true, then an error will be thrown if a single match is not
%       found. This can be used to throw a bit nicer of an error message
%       and to make the calling code not as messy.
%   natural_sort_files : (default false) NOT YET IMPLEMENTED
%       The goal of this property would be to return things sorted
%       such that numbers determine a sort, rather than alphabetical order
%       i.e. you might get:
%           'file9','file10','file11' instead of 'file10','file11','file9'
%   need_dir_props: logical (default false)
%       If true, then an algorithm will be chosen that returns 
%       the structure associated with the dir() function. If false, faster
%       algorithms may be used that don't require this information. This
%       is necessary specifically for the list_result output where
%       the user may be expecting this information.
%   output_type : {'object','names','paths','dir'} (default 'object')
%       - object : return sl.dir.list_result
%       - names  : return only the names
%       - paths   : return only the paths
%       - dir    : return only the dir structures
%       NOTE: When searching for both files and folders (search_type =
%       'both'), the file property is returned as the first output and 
%       the folder property is returned as the second output.
%   recursive : logical (default false)
%       If true, results are included from subdirectories in addition to
%       just the root directory
%   search_type : {'files','folders','both'} (default 'files')
%       - 'files' : find only files
%       - 'folders' : find only folders
%       - 'both' : find files and folders
%
%               =============   File filtering    ==========
%
%   extension : string, default ''
%       If not empty filters on the extension. A leading period is optional.
%   file_date_filter : function handle, default []
%       If not empty, a function should be provided which takes in the
%       modification date as a Matlab 'datenum' and returns a mask
%       indicating whether or not each entry should be kept 
%           (true means the entry is kept)
%   file_pattern : string, default ''
%       If not empty, filters the file names based on using the string.
%       Unlike 'file_regex', only * characters are
%       supported. This also means that chacters like '.' are treated as
%       literals rather than as special regular expression characters.
%           (a match means the entry is kept)
%       This pattern should not include the extension.
%   file_regex : string, default ''
%       If not empty, filters file names based on using the supplied string
%       as a pattern to regexp(). All special characters should be escaped.
%           (a match means the entry is kept)
%   file_regex_case_sensitive : logical, default false
%       Whether or not the regex is case sensitive. True indicates that it
%       is case sensitive.
%   file_size_filter : function handle, default []
%       The function should take in a single input, an array where each
%       element contains the # of bytes of a file, and return whether or 
%       not each entry should be kept
%           (true means the entry is kept)
%   
%
%               ==============  Folder filtering ========
%
%   folder_regex : string (default '')
%       A regular expression pattern to run on each folder name.
%           (a match means the entry is kept)
%   folder_pattern : string (default '')
%       See notes on 'file_pattern'
%   folder_date_filter : function handle (default None)
%       Input should be a function which takes in an array of datenum
%       values for when the folders were modified and returns an array of
%       logicals regarding whether or not the folders should be kept.
%           (true means the entry is kept)
%   folders_to_ignore : cellstr (default {})
%       Names of folders not to match (at any level)
%   first_chars_in_folders_to_ignore : string (default '')
%       Characters that a folder may not start with. Currently starting
%       with a period '.' is not supported. If it ever is, it will be
%       exposed as an option with the default behavior being to ignore
%       them. This was created for filtering code paths such as directories
%       that begin with a '+' or '@', e.g.
%           first_chars_in_folders_to_ignore = '+@'
%
%
%   Limitations:
%   ------------
%   1) Currently it is impossible to get a list of any folder that starts
%   with a period.
%   2) Unicode support is currently lacking. See this link for more info:
%       http://www.mathworks.com/matlabcentral/answers/86186-working-with-unicode-paths
%
%
%
%   Possible Improvements:
%   ----------------------
%   - ignore hidden files
%   - quicker recursive directory listing
%   - multi-level path filtering
%   - unicode support
%
%
%   Examples:
%   ---------
%   1) Find files in a directory with a given extension
%   list_result = sl.dir.getList(folder_path,'extension','.mat')
%
%   2) Find files of a given type in a directory AND subdirectories
%   list_result = sl.dir.getList(root_path,'recursive',true,'extension','.mat')
%
%   3) Find all nested folders starting with the word 'block'
%   list_result = sl.dir.getList(root_path,'recursive',true,...
%       'search_type','folders','folder_pattern','block*')
%
%   4) Recursive file search where only full file paths are needed
%   file_paths = sl.dir.getList(root_path,'recursive',true,'output_type','paths')
%
%
%   Still to do:
%   ------------
%   - implement folder searching using .NET
%
%   See Also:
%   ---------
%   dir()

%{

    tic;
    wtf = getDirectoryTree('C:\D\repos\matlab_git\matlab_SVN','','','\.m','files');
    toc;

    %Non-recursive list of folders
    wtf = sl.dir.getList('C:\D\repos\matlab_git\matlab_SVN','search_type','folders','first_chars_in_folders_to_ignore','+@')

    %Non-recursive with an extension
    wtf = sl.dir.getList('C:\D\repos\matlab_git\matlab_SVN','extension','.m')

    %Non-recursive list of files and folders
    wtf = sl.dir.getList('C:\D\repos\matlab_git\matlab_SVN','search_type','both')

    %Different return type ...
    [file_names,folder_names] = sl.dir.getList('C:\D\repos\matlab_git\matlab_SVN',...
            'search_type','both','output_type','names')

    %Recursive
	wtf = sl.dir.getList('C:\D\repos\matlab_git\matlab_SVN','recursive',true)

    %Recursive, only folders
	wtf = sl.dir.getList('C:\D\repos\matlab_git\matlab_SVN','recursive',true,'search_type','folders')

    %Recursive with an extension
	wtf = sl.dir.getList('C:\D\repos\matlab_git\matlab_SVN','recursive',true,'extension','.m')

    %Recursive with a pattern
    wtf = sl.dir.getList('C:\D\repos\matlab_git\matlab_SVN','recursive',true,'file_pattern','g*.m')

    %Recursive with an extension - but needing dir info
    wtf = sl.dir.getList('C:\D\repos\matlab_git\matlab_SVN','recursive',true,'extension','.m','need_dir_props',true)

    %Recursive with an extension and size filter
    %Keep files that are less than 6000 bytes
    wtf = sl.dir.getList('C:\D\repos\matlab_git\matlab_SVN','recursive',true,'file_pattern','*.m','file_size_filter',@(x)(x < 6000))


    tic;
	wtf = sl.dir.rdir('C:\D\repos\matlab_git\matlab_SVN\**\*.m');
    toc;

%}

if nargout == 0
    return
else
    %TODO: Validate nargout being 1 or 2 ...
end

t_tic = tic;

%Optional Inputs
%=================================
%Results related
%---------------------------------------------
in.enforce_single_file_match = false; %NYI
in.natural_sort_files = false; %NYI - http://www.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
in.need_dir_props = false; %DONE
in.output_type = 'object'; %DONE {'object','names','paths','dir'}
in.recursive = false; %DONE
in.search_type = 'files'; %DONE {0,1,2,'files','folders','both'}
%in.numeric_search_type
%0 - files
%1 - folders
%2 - both

%File filtering
%---------------------------------------------
in.extension = ''; %DONE file extension
in.file_date_filter = []; %DONE
in.file_pattern = '';%DONE 
in.file_regex = ''; %DONE NOTE: All regex must be escaped
in.file_regex_case_sensitive = false; %DONE
in.file_size_filter = []; %DONE

%Folder filtering
%---------------------------------------------
in.folder_regex = ''; %DONE
in.folder_pattern = ''; %DONE
in.folder_date_filter = []; %DONE
in.folders_to_ignore = {}; %DONE
in.first_chars_in_folders_to_ignore = ''; %DONE

in = sl.in.processVarargin(in,varargin);

in = h__cleanOptionalInputs(in);
%===============================================================

%Whether or not we need to get the structure returned by dir() which
%includes meta data besides just the name
need_dir_approach = in.need_dir_props || ...
    ~isempty(in.file_date_filter) || ...
    ~isempty(in.file_size_filter) || ...
    ~isempty(in.folder_date_filter);

folder_filtering = ~isempty(in.folder_regex) || ...
    ~isempty(in.folder_pattern) || ...
    ~isempty(in.folder_date_filter) || ...
    ~isempty(in.folders_to_ignore) || ...
    ~isempty(in.first_chars_in_folders_to_ignore);

possible_dotnet = ~need_dir_approach && in.recursive && ispc && ~folder_filtering;

if  possible_dotnet && in.numeric_search_type == 0 
    %
    % in.numeric_search_type == 0 => get files
    %
    
    %The folder filtering bit could be done post hoc but we'll ignore 
    %this method for now if folder filtering is done
    s = h__getFilesDotNet(root_folder_path,in);
elseif possible_dotnet && in.numeric_search_type == 1
    s = h__getFoldersDotNet(root_folder_path,in);
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

%==============   OUTPUT HANDLING  ========================================

function output = h__setupOutput(root_folder_path,s,in,n_outputs,t_tic)
%
%   Inputs:
%   -------
%   s : (structure)
%       .file_names
%       .folder_names
%       .file_paths
%       .folder_paths
%       .d_files
%       .d_folders
%
%
%


output = cell(1,n_outputs);
switch in.output_type
    case 'object'
        %TODO: We probably shouldn't return more than we have to
        %as different listing methods might not return everything ...
        lr = sl.dir.list_result;
        lr.root_folder_path = root_folder_path;
        
        if ismember(in.numeric_search_type,1:2)
            lr.folder_names = s.folder_names;
            lr.folder_paths = s.folder_paths;
        end
        
        if ismember(in.numeric_search_type,[0 2])
            lr.file_names   = s.file_names;
            lr.file_paths   = s.file_paths;
        end
        
        if in.need_dir_props
            lr.d_folders    = s.d_folders;
            lr.d_files      = s.d_files;
        end
        lr.elapsed_time = toc(t_tic);
        output{1} = lr;
    case 'names'
        switch in.numeric_search_type
            case 0
                output{1} = s.file_names;
            case 1
                output{1} = s.folder_names;
            case 2
                output{1} = s.file_names;
                if n_outputs > 1
                output{2} = s.folder_names;
                end
        end
    case 'paths'
        switch in.numeric_search_type
            case 0
                output{1} = s.file_paths;
            case 1
                output{1} = s.folder_paths;
            case 2
                output{1} = s.file_paths;
                if n_outputs > 1
                    output{2} = s.folder_paths;
                end
        end
    case 'dir'
        switch in.numeric_search_type
            case 0
                output{1} = s.d_files;
            case 1
                output{1} = s.d_folders;
            case 2
                output{1} = s.d_files;
                if n_outputs > 1
                    output{2} = s.d_folders;
                end
        end
    otherwise
        error('Unrecognized output type')
end

end %---------------------------------   End of h__setupOutput  -----------

%===============    INPUT HANDLING   ======================================

function in = h__cleanOptionalInputs(in)
%x Makes sure optional inputs are standardized and agree
%
%   TODO: I haven't given this function a lot of attention yet. It could
%   probably have things added to it.
%
%   This is just supposed to run some sanity checks on the optional inputs
%   and change them if necessary

%Change possible characters to numbers
%TODO: Move the function to being right next to this one
in = h__fixInType(in);

%TODO: Extension when search type is folders

if strcmp(in.output_type,'dir')
    in.need_dir_props = true;
end



end  %------------   End of h__cleanOptionalInputs    ---------------------

function in = h__fixInType(in)
%x
%
%   Converts characters to numerics and makes sure numerics are in range
%
%

if ischar(in.search_type)
    switch in.search_type(1:2)
        case 'fi'
            in.numeric_search_type = 0;
        case 'fo'
            in.numeric_search_type = 1;
        case 'bo'
            in.numeric_search_type = 2;
        otherwise
            error('Unrecognized return type: %s',in.search_type)
    end
else
    in.numeric_search_type = in.search_type;
    %Valid values are 0, 1, or 2
    if ~ismember(in.search_type,0:2)
        error('Unrecognized search type: %d',in.search_type)
    end
end

end  %----------    End of h__fixInType    --------------------

%===========  LISTING APPROACHES   ========================================

function s = h__getFoldersDotNet(root_folder_path,in)
%NOT YET FINISHED ...
%https://msdn.microsoft.com/en-us/library/ms143314(v=vs.110).aspx
%
%(path,searchPattern,searchOption)
%
temp = System.IO.Directory.GetDirectories(root_folder_path,'*',...
    System.IO.SearchOption.AllDirectories);

s = struct;
s.folder_paths = cell(temp);
s.folder_names = sl.dir.getFileName(s.folder_paths);

end

function s = h__getFilesDotNet(root_folder_path,in)
%x Finds all files in in a directory and subdirectories using .NET
%
%

[file_filters,search_pattern]   = h__setupFileFilters(in,true);

if isempty(search_pattern)
    search_pattern = '*';
end

%TODO: Introduce try/catch and look for missing directory on catch
%otherwise rethrow original error

%This is the magic function ...
%Documentation at:
%https://msdn.microsoft.com/en-us/library/07wt70x2%28v=vs.110%29.aspx
temp = System.IO.Directory.GetFiles(root_folder_path,search_pattern,...
    System.IO.SearchOption.AllDirectories);

file_paths = cell(temp); %Conversion of String[] to cellstr
file_names = sl.dir.getFileName(file_paths);

%Using file_paths instead of d_files is a bit of a hack but it works
%.... It is an array that can be filtered side by side with the names
%NOTE: We've already ensured we don't need d_files before calling this
%function ...
[file_names,file_paths] = h__filterFiles(file_names,file_paths,file_filters);

%TODO: Move to a constructor function

s = struct;
s.file_paths   = file_paths;
s.folder_names = {};
s.file_names   = file_names;
s.folder_paths = {};
s.d_files      = [];
s.d_folders    = [];

end

function s = h__runBasicApproach(root_folder_path,in)
%x Runs dir() with filtering (non-recursive)
%
%   Called for the non-recursive case. This code isn't much different
%   than dir() except for the filtering that takes place

switch in.numeric_search_type
    case 0
        s = h__getFiles(root_folder_path,in);
    case 1
        s = h__getFolders(root_folder_path,in);
    case 2
        %We need to create the filters and then pass them in because
        %this function is also used as a helper in the recursive case 
        %and in that case the filters are precomputed to save time and
        %passed into the function we are calling here.
        file_filters   = h__setupFileFilters(in,false);
        folder_filters = h__setupFolderFilters(in,false);
        s = h__getFilesAndFolders(root_folder_path,in,file_filters,folder_filters);
end

end

function s = h__runBasicRecursiveApproach(root_folder_path,in)
%x Get a list of files and folders in the directory and subdirectories
%

MAGIC_CELL_LENGTH = 10000;

file_filters   = h__setupFileFilters(in,false);
folder_filters = h__setupFolderFilters(in,false);

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

function s = h__getFiles(root_folder_path,in)
%x Gets a list of files in a single directory

[file_filters,file_pattern_use] = h__setupFileFilters(in,true);

d = dir(fullfile(root_folder_path,file_pattern_use))';

d([d.isdir]) = [];

file_names = {d.name};

[file_names,d] = h__filterFiles(file_names,d,file_filters);

s = struct;
s.root_path    = {};
s.file_names   = file_names;
s.folder_names = {};
s.file_paths   = sl.dir.fullfileCA(root_folder_path,file_names);
s.folder_paths = {};
s.d_files      = d;
s.d_folders    = [];

end %--------------   End of h__getFiles  ---------------------------------

function s = h__getFolders(root_folder_path,in)
%x Gets a list of folders in a root folder and filters results
%
%
%   See Also:
%   h__setupOutput

[folder_filters,file_pattern_use] = h__setupFolderFilters(in,true);

d = dir(fullfile(root_folder_path,file_pattern_use))';
d(~[d.isdir]) = [];

folder_names = {d.name};

[folder_names,d] = h__filterFolders(folder_names,d,folder_filters);

s = struct;
s.root_path    = root_folder_path;
s.file_names   = {};
s.folder_names = folder_names;
s.file_paths   = {};
s.folder_paths = sl.dir.fullfileCA(root_folder_path,folder_names);
s.d_files      = [];
s.d_folders    = d;

end  %-------------   End of h__getFolders   ------------------------------ 

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
%
%   See Also:
%   h__runBasicRecursiveApproach

d = dir(root_folder_path)'; %Transpose to make a row vector

is_dir_mask = [d.isdir];


d_folders    = d(is_dir_mask);
folder_names = {d_folders.name};
[folder_names,d_folders] = h__filterFolders(folder_names,d_folders,folder_filters);

%Unfortunately right now we are using this function to get files and
%folders for a single directory AND when using the recursive approach,
%regardless of what we really need
if in.numeric_search_type ~= 1
    d_files    = d(~is_dir_mask);
    file_names = {d_files.name};
    [file_names,d_files] = h__filterFiles(file_names,d_files,file_filters);
else
    d_files = [];
    file_names = {};
end

s = struct;
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

function [folder_names,d_folders] = h__filterFolders(folder_names,d_folders,folder_filters)

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
first_char_array(leading_period_mask) = [];

%All other filters
%------------------
for iFilter = 1:length(folder_filters)
    fh = folder_filters{iFilter};
    remove_mask = fh(folder_names,d_folders,first_char_array);
    folder_names(remove_mask) = [];
    d_folders(remove_mask) = [];
end



end



%======================      Filters     ==================================

function [folder_filters,folder_pattern_use] = h__setupFolderFilters(in,filter_via_query)
%x Creates an array of function handles to filter folders
%

%Filters get called with the form:
%(folder_names,folder_paths,d_folders)
%
%where d_folders is the output of dir() for folders
%
%Functions should return back a mask indicating whether or not each entry
%should be kept. True indicates that it should be removed (not kept).


folder_filters = cell(1,5);

if ~isempty(in.folder_regex)
   folder_filters{1} = @(folder_names,~,~)cellfun('isempty',regexpi(folder_names,in.folder_regex,'once'));
end

if ~isempty(in.folder_date_filter)
   folder_filters{2} = @(~,d_folders,~)~in.folder_date_filter([d_folders.datenum]); 
end

if ~isempty(in.folders_to_ignore)
   folder_filters{3} = @(folder_names,~,~)ismember(folder_names,in.folders_to_ignore); 
end

if ~isempty(in.first_chars_in_folders_to_ignore)
   folder_filters{4} = @(~,~,first_chars)ismember(first_chars,in.first_chars_in_folders_to_ignore); 
end

if filter_via_query
    folder_pattern_use = in.folder_pattern;
else
    folder_pattern_use = '';
    if ~isempty(in.folder_pattern)
        
        folder_pattern = ['^' regexptranslate('wildcard',in.folder_pattern) '$'];
        folder_filters{5} = @(folder_names,~,~)cellfun('isempty',regexpi(folder_names,folder_pattern,'once'));    
    end
end


folder_filters(cellfun('isempty',folder_filters)) = [];

end  %----------   End of h__setupFolderFilters   -----------------

function [file_filters,file_pattern_use] = h__setupFileFilters(in,filter_via_query)
%x Creates an array of function handles to filter files
%
%   Filtering via the query
%   -----------------------
%   If we can filter via the query
%
%   Inputs:
%   -------
%   filter_via_query :
%       false - no filtering of files via the query
%
%
%Setup file filters
%-------------------
% in.extension = ''; %HALF_DONE file extension
% in.file_regex = ''; %NOTE: All regex must be escaped
% in.file_pattern = '';%NYI: this would be
% in.file_date_filter = []; %NYI, should be a function handle
% in.file_size_filter = []; %NYI, should be a function handle

file_filters = cell(1,5); %Expand as we get more filters

file_pattern_use = '';

%1) Extension filtering
%--------------------
if ~isempty(in.extension)
    
    dot_leading_extension = in.extension;
    if dot_leading_extension(1) ~= '.'
        dot_leading_extension = ['.' dot_leading_extension];
    end
    
    if filter_via_query
        if isempty(in.file_pattern)
            run_postquery_extension_filter = false;
            file_pattern_use = ['*' dot_leading_extension];
        else
            %file_pattern filtering takes precedence over extension
            %filtering
            run_postquery_extension_filter = true;
        end
    else
        run_postquery_extension_filter = true;
    end
    
    if run_postquery_extension_filter
        %Match .extension where the dot is a literal and at the end of the
        %string
        dot_leading_extension_pattern = ['\' dot_leading_extension '$'];
        file_filters{1} = @(file_names,~)cellfun('isempty',regexpi(file_names,dot_leading_extension_pattern,'once'));
    end
end

%2) Regex filtering - always post query
%--------------------------------------
if ~isempty(in.file_regex)
    if in.file_regex_case_sensitive
        file_filters{2} = @(file_names,~)cellfun('isempty',regexp(file_names,in.file_regex,'once'));
    else
        file_filters{2} = @(file_names,~)cellfun('isempty',regexpi(file_names,in.file_regex,'once'));
    end
end

%3) file pattern filtering
%---------------------------------------
if ~isempty(in.file_pattern)
    if filter_via_query
        file_pattern_use = in.file_pattern;
    else
        file_pattern = in.file_pattern;
        %* - any character
        %
        %? - 0 or 1 of any character ... - doesn't seem to work for Matlab
        %but could work for another approach, i.e. via .NET
        %TODO: Handle other approaches ...
        
        %Add anchors for matching entire string not just a subset
        file_pattern = ['^' regexptranslate('wildcard',file_pattern) '$'];
        
        file_filters{3} = @(file_names,~)cellfun('isempty',regexpi(file_names,file_pattern,'once'));
    end
end

%4) Modified date filtering
%--------------------------
if ~isempty(in.file_date_filter)
    file_filters{4} = @(~,d_files)~in.file_data_filter([d_files.datenum]);
end

%5) File size filtering
%----------------------
if ~isempty(in.file_size_filter)
    file_filters{5} = @(~,d_files)~in.file_size_filter([d_files.bytes]);
end

file_filters(cellfun('isempty',file_filters)) = [];

end   %---------  End of h__setupFileFilters --------------------

%======================   END OF FILTERS   ================================

%=====================  SMALL HELPERS  ====================================
function first_char_array = h__getFirstChar(cellstr_in)
%
%   Simple helper that grabs the first character of every string
%
%   Written for filtering folders if the first character is a period.


% tic
n = length(cellstr_in);
space = ' ';
first_char_array = space(ones(1,n));
for iStr = 1:n
    first_char_array(iStr) = cellstr_in{iStr}(1);
end
% toc
% tic
% temp = regexp(cellstr_in,'.','match','once');
% first_char_array = [temp{:}];
% toc

end

%sl.dir.getFileName

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