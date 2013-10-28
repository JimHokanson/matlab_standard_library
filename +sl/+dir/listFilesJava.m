function file_paths = listFilesJava(file_root)
%
%   This is a temporary file. I am going to move it eventually.

wtf = listFiles(java.io.File(file_root));

file_paths = cell(1,length(wtf));

for iFile = 1:length(file_paths);
   file_paths{iFile} = cell(toString(wtf(iFile))){1}; 
end

end
