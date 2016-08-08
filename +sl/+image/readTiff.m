function image_data = readTiff(file_path)
%
%
%   sl.image.readTiff
%
%   This needs a bit of work. I put it together quickly for a report
%   writeup.

image_info = imfinfo(file_path);
mImage = image_info(1).Width;
nImage = image_info(1).Height;
NumberImages = length(image_info);

%??? - Why uint16????
image_data=zeros(nImage,mImage,NumberImages,'uint16');
for i=1:NumberImages
    image_data(:,:,i)=imread(file_path,'Index',i);
end


end