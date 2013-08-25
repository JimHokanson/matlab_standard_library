function replaceTildes
% Recurses through directories, finding matlab code and replacing LHS
% tildes with 'ans' to make code backwards compatible.
%
% WARNING: this overwrites files!!! Copy the whole folder before use!!!
%
% Please report bugs on the Matlab FX. 
% And if you can come up with a better regex let me know.
%
% DM, Jun 2013
%
DUMMY_VAR_NAME = 'ans';

result = questdlg(...
    sprintf('Current directory:\n%s\n\nDo you really want to modify all *.m files in this folder and its subfolders?%s',cd) ,...
    'Replace Tildes','Yes','Cancel','Cancel');
if ~strcmp(result,'Yes'), return; end;


fileList = getAllFiles(cd);
for ii=1:numel(fileList)
    filename = fileList{ii};
    [pth,nm,ex] = fileparts(filename);
    if ~strcmp(ex,'.m'), continue; end;
  
    str = fileread(filename);
    str = regexprep(str,  '~(?=[^\]\[='']*\][\s(\.\.\.)]*=[^=])',DUMMY_VAR_NAME);
    f = fopen(filename,'w');
    fwrite(f,str);
    fclose(f);
end


end


function fileList = getAllFiles(dirName)
% from: stackoverflow.com/questions/2652630/

  dirData = dir(dirName);      %# Get the data for the current directory
  dirIndex = [dirData.isdir];  %# Find the index for directories
  fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
  if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
  end
  subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir)];  %# Recursively call getAllFiles
  end

end
