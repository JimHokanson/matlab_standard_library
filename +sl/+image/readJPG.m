function image_out = readJPG(uint8_data_or_filepath,option)
%
%
%   image_out = sl.image.readJPG(uint8_data_or_filename,*option)
%
%   This function reads a JPEG image from file OR MEMORY. It was originally
%   written to facilitate decoding of videos that had been read into memory
%   that used the mjpeg (motion JPEG) codec (essentially just a series of 
%   JPEG's that form a video).
%
%   It relies on the libjpeg-turbo project.
%
%   This function will be much faster at processing in memory pictures as
%   compared to writing the image to disk just to have it be processed.
%
%   INPUTS
%   ---------------------------------------------------------------
%   uint8_data_or_filepath : (uint8 or path to a jpg image)
%   option: (default 1) - fast uses the fast idct algorithm
%       available and might cause some slight quality loss. On Windows I've
%       actually found the 'fast' to be somewhat slower
%       - 1: fast rgb
%       - 2: slow rgb   - default
%       - 3: fast gray
%       - 4: slow gray
%
%   fp = 'C:\Users\RNEL\Desktop\Able_air_and_space.jpg';
%   image_out = sl.image.readJPG(fp,3);

if ~exist('option','var')
    option = 2;
end

if ischar(uint8_data_or_filepath)
   uint8_data = sl.io.fileRead(uint8_data_or_filepath,'*uint8');
else
   uint8_data = uint8_data_or_filepath;
end

switch option
    case {1 2}
        image_out = permute(readJPGHelper(uint8_data,option),[3 2 1]);
    case {3 4}
        image_out = readJPGHelper(uint8_data,option)';
    otherwise
        error('Unrecognized option: %d',option)
end