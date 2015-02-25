function output = getFilesInFolder(folder_path,varargin)
%
%   output = sl.dir.getFilesInFolder(folder_path,varargin)
%
%   Output:
%   -------
%   output : sl.dir.file_list_result or java.io.File[]
%
%           - if use_java is true, type is java.io.File[]
%
%   Optional Inputs:
%   ----------------
%   enforce_single_match :
%       If true, then an error will be thrown if a single match is not
%       found
%   type : numeric %TODO: Allow string
%       - 0: file
%       - 1: folder
%       - 2: both
%   ext : default ''
%       If not empty filters on the extension. Leading period optional.
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
%   - ignore leading dot directories
%   - return or don't return dir results - date modified ...
%   - relative path support :/
%
%
%   See Also:
%   sl.dir.rdir

%{
Other Implementations
---------------------
22 http://www.mathworks.com/matlabcentral/fileexchange/15505-recursive-dir
4 http://www.mathworks.com/matlabcentral/fileexchange/16217-wildcardsearch
9 http://www.mathworks.com/matlabcentral/fileexchange/40020-dir-read
26 http://www.mathworks.com/matlabcentral/fileexchange/32036-dirwalk-walk-the-directory-tree
5 http://www.mathworks.com/matlabcentral/fileexchange/44089-rdir-dos
131 http://www.mathworks.com/matlabcentral/fileexchange/19550-recursive-directory-listing
5 http://www.mathworks.com/matlabcentral/fileexchange/25753-new-dir-m
3 http://www.mathworks.com/matlabcentral/fileexchange/46873-dir-crawler-m
30 http://www.mathworks.com/matlabcentral/fileexchange/40149-expand-wildcards-for-files-and-directory-names
13 http://www.mathworks.com/matlabcentral/fileexchange/21791-search-files-recursively--dir2-
13 http://www.mathworks.com/matlabcentral/fileexchange/2118-getfilenames-m
49 http://www.mathworks.com/matlabcentral/fileexchange/1492-subdir--new-
15 http://www.mathworks.com/matlabcentral/fileexchange/41135-folders-sub-folders
5 http://www.mathworks.com/matlabcentral/fileexchange/39804-creating-file-and-folder-trees
75 http://www.mathworks.com/matlabcentral/fileexchange/15859-subdir--a-recursive-file-search
6 http://www.mathworks.com/matlabcentral/fileexchange/1570-dirdir
5 http://www.mathworks.com/matlabcentral/fileexchange/24567-searchfile
5 http://www.mathworks.com/matlabcentral/fileexchange/16216-regexpdir
91 http://www.mathworks.com/matlabcentral/fileexchange/32226-recursive-directory-listing-enhanced-rdir
17 http://www.mathworks.com/matlabcentral/fileexchange/40016-recursive-directory-searching-for-multiple-file-specs
33 http://www.mathworks.com/matlabcentral/fileexchange/8682-dirr--find-files-recursively-filtering-name--date-or-bytes-
7 http://www.mathworks.com/matlabcentral/fileexchange/43704-getdirectorycontents
7 http://www.mathworks.com/matlabcentral/fileexchange/22829-file-list
16 http://www.mathworks.com/matlabcentral/fileexchange/31343-enlist-all-file-names-in-a-folder-and-it-s-subfolders

%}

%Code structure
%-----------------
%1) Choose lister
%2) Setup filters





%TODO: Allow multiple folder paths ...

in.enforce_single_match = false;
in.type = 0; %0 - file, 1 - folder, 2 - both
in.ext = ''; %file extension
in.match_number = [];
in.regexp = ''; %NOTE: All regex must be escaped
in.use_java = false;
in = sl.in.processVarargin(in,varargin);


if in.use_java
    %This bit of code was written to handle file names which were not 7-bit
    %ascii.
    dir_obj    = java.io.File(folder_path);
    dir_files  = dir_obj.listFiles;
    
    if ~isempty(in.regexp)
       error('Regular Expression support not build into java version yet') 
    end
    if in.type ~= 0
       error('Only type 0 is supported for the Java version currently') 
    end
    if in.check_single_match
       error('Checking for a single match is not supported with this version') 
    end
    if ~isempty(in.match_number)
       error('Not supported with Java version') 
    end
    
    if ~isempty(in.ext)
        if in.ext(1) == '.'
            ext_use = in.ext;
        else
            ext_use = ['.' in.ext];
        end
        
        n_files = length(dir_files);
        
        keep_mask = false(1,n_files);
        for iFile = 1:n_files
            keep_mask(iFile) = dir_files(iFile).getName.endsWith(ext_use);
        end
        
        if ~all(keep_mask)
            dir_files = dir_files(keep_mask);
        end
    end
    output = dir_files;
else
    
    if ~isempty(in.ext)
        if in.ext(1) == '.'
            ext_use = ['*' in.ext];
        else
            ext_use = ['*.' in.ext];
        end
        file_path = fullfile(folder_path,ext_use);
        temp = dir(file_path);
    else
        temp = dir(folder_path);
    end
    
    %     name
    %     date
    %     bytes
    %     isdir
    %     datenum
    
    if in.type == 0
        temp([temp.isdir]) = [];
    elseif in.type == 1
        temp(~[temp.isdir]) = [];
    elseif in.type == 2
        %do nothing
    else
        error('Unrecognized option type: %d',in.type)
    end
    
    %NOTE: The order of these filters is a design choice (not necessarily
    %the right one). Eventually a bank of filters might be desirable ...
    if ~isempty(in.regexp)
       regex_matches = regexp({temp.name},in.regexp,'match','once');
       delete_mask = cellfun('isempty',regex_matches); 
       temp(delete_mask) = [];
    end

    if ~isempty(in.match_number)
       %NOTE: We only get one numberic match, which is why I put this
       %2nd so that you could filter out options via the regexp above
       regex_matches = regexp({temp.name},'\d+','match','once');
       found_number  = cellfun(@str2double,regex_matches);
       delete_mask   = found_number ~= in.match_number; 
       temp(delete_mask) = []; 
    end
    
    
    if in.enforce_single_match && length(temp) ~= 1
        error('Singular file match requested but %d files were found',length(temp))
    end
    
    output = sl.dir.file_list_result;
    
    output.file_names = {temp.name};
    output.file_paths = sl.dir.fullfileCA(folder_path,output.file_names);
    output.dir_result = temp;
    
end