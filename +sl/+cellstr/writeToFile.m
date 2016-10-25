function writeToFile(data,file_path,column_delimiter)
%
%   sl.cellstr.writeToFile(data,file_path,column_delimiter)
%
%   Inputs
%   ------
%   data: cellstr
%   file_path: string
%   column_delimiter
%
%   Examples
%   --------
%   1)
%   data = {'1','2';'3','cheese'}
%   file_path = 'C:\test_directory\123_cheese.txt'
%   column_delimiter = ','
%   sl.cellstr.writeToFile(data,file_path,column_delimiter)

string = sl.cellstr.join(data,'d',column_delimiter,'keep_rows',true);
sl.io.fileWrite(file_path,string);

end