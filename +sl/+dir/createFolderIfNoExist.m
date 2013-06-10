function folderPath = createFolderIfNoExist(varargin)
%createIfNecessary: creates a folder if it doesn't exist
%
%   folderPath = sl.dir.createFolderIfNoExist(folderPath) - creates the folderPath
%   if it doesn't exist
%   
%   createFolderIfNoExist(folderPath,subdir1,subdir2,...,subdirN) - create
%   a directory tree starting at folderPath

folderPath = fullfile(varargin{:});
if ~exist(folderPath,'dir')
    mkdir(folderPath)
end

end
