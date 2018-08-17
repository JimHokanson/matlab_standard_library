function image_data = readBMP(uint8_data_or_filepath)
%
%   image_data = sl.image.readBMP(uint8_data_or_filepath)

if ischar(uint8_data_or_filepath)
    image_data = imread(uint8_data_or_filepath,'bmp');
else
   uint8_data = uint8_data_or_filepath;
   name = [tempname '.bmp'];
   try
      sl.io.fileWrite(name,uint8_data);
      image_data = imread(name,'bmp');
      delete(name)
   catch ME
      try
          delete(name)
      end
      rethrow(ME)
   end
end



end