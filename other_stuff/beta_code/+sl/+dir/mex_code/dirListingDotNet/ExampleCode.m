
DIR_ROOT = 'C:\Users\RNEL\Documents\Mendeley Desktop\1957';
%DIR_ROOT = 'C:\Users\RNEL\Desktop\Matlab_Work';

%Only needs to be run once
%NET.addAssembly('System');

wtf  = System.IO.DirectoryInfo(DIR_ROOT);
wtf2 = wtf.GetFiles;
E    = wtf2.GetEnumerator;

file_list = cell(100,1);
raw_list  = cell(100,1);
file_objs = cell(100,1);
cur_index = 0;

while E.MoveNext
   cur_index = cur_index + 1;
   file_objs{cur_index} = E.Current;
   file_list{cur_index} = char(E.Current.FullName);
   raw_list{cur_index}  = E.Current.FullName;
end
file_list(cur_index+1:end) = [];
raw_list(cur_index+1:end)  = [];
file_objs(cur_index+1:end) = [];

f  = System.IO.File.Open(raw_list{end},System.IO.FileMode.Open);
br = System.IO.BinaryReader(f);

%http://stackoverflow.com/questions/8613187/an-elegant-way-to-consume-all-bytes-of-a-binaryreader
yikes = uint8(br.ReadBytes(int32(f.Length)));
br.Close;

%Using Java
%------------------------------------------------
%http://stackoverflow.com/questions/6058003/elegant-way-to-read-file-into-byte-array-in-java
dir_obj    = java.io.File(DIR_ROOT);
dir_files  = dir_obj.listFiles;
file_bytes = typecast(org.apache.commons.io.FileUtils.readFileToByteArray(dir_files(end)),'uint8');