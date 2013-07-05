function output_path = createFolderIfNoExist(varargin)
%createIfNecessary: creates a folder if it doesn't exist
%
%   #1 - just create the folder if necessary
%   folder_path = sl.dir.createFolderIfNoExist(folderPath) - creates the folderPath
%   if it doesn't exist
%
%   #2 - build path with multiple directories
%   folder_path = createFolderIfNoExist(folderPath,subdir1,subdir2,...,subdirN) - create
%   a directory tree starting at folderPath
%
%   #3 - build file name, last input is file name
%   file_path = createFolderIfNoExist(true,folderPath,subdir1,subdir2,file_name)
%
%

if islogical(varargin{1})
    if varargin{1}
        file_name = varargin{end};
        varargin([1 end]) = [];
    else
        varargin(1) = [];
    end
else
    varargin = [{last_as_file_flag} varargin];
    file_name = '';
end

output_path = fullfile(varargin{:});
if ~exist(output_path,'dir')
    mkdir(output_path)
end

if ~isempty(file_name)
    output_path = fullfile(output_path,file_name);
end

end
