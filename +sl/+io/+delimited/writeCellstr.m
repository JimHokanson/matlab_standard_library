function writeCellstr(file_path,data,delimiter)
%
%   sl.io.delimited.writeCellstr(file_path,data,delimiter)
%

if nargin ~= 3
    error('Incorrect # of inputs')
end

output_string = sl.cellstr.join(data,'d',delimiter,'keep_rows',true);

sl.io.fileWrite(file_path,output_string);

end

