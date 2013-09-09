function image_out = readJPG(uint8_data_or_filename,option)
%
%
%   image_out = sl.image.readJPG(uint8_data_or_filename,*option)

%Can we read from file as well????

%OPTIONS
%1) fast rgb
%2) slow rgb
%3) 


if ischar(uint8_data_or_filename)
   uint8_data = sl.io.fileRead(uint8_data_or_filename,'*uint8');
else
   uint8_data = uint8_data_or_filename;
end

image_out = permute(readJPGHelper(uint8_data),[3 2 1]);

end