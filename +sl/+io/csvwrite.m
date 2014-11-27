function csvwrite(file_path,data)
%
%
%   sl.io.csvwrite(filepath,data)

%TODO: Provide override options for file creation
%TODO: Allow format specified for writing ...

%Coding approach taken from:
%http://www.mathworks.com/matlabcentral/newsreader/view_thread/174228

row_format = sl.cellstr.join(repmat({'%.*g'},1,size(data,2)));

row_format = sprintf('%s\n',row_format);

fid = fopen(file_path,'w');
fprintf(fid,row_format,data);
fclose(fid);

end