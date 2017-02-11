function writeArray(file_path,data,varargin)
%x Writes an array of data to a delimited file 
%
%   sl.io.delimited.writeArray(filepath,data)

in.delimiter = ',';
in.format = '%.*g';
in = sl.in.processVarargin(in,varargin);

%TODO: Provide override options for file creation
%TODO: There has to be a better algorithm

%Coding approach taken from:
%http://www.mathworks.com/matlabcentral/newsreader/view_thread/174228

string_format_repeated = repmat({in.format},1,size(data,2));

row_format = sl.cellstr.join(string_format_repeated,'d',in.delimiter);

row_format = sprintf('%s\n',row_format);

fid = fopen(file_path,'w');
fprintf(fid,row_format,data);
fclose(fid);

end