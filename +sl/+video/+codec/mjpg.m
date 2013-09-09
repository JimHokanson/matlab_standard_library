classdef mjpg < sl.video.codec
    %
    %   Class:
    %   sl.video.codec.mjpg
    
    properties
       %What options would I like to include in here ????
    end
    
    methods
        function obj = mjpg()
           
            %What do I want to do in the constructor???
            
        end
        function output_data = decodeFrame(obj,input_data)
           % 
           %
            
           
           output_data = sl.image.readJPG(input_data);
           
        end
    end
    
end


%{






See Also:
http://www.impulseadventure.com/photo/jpeg-snoop.html
http://www.impulseadventure.com/photo/jpeg-huffman-coding.html

Quantization Tables:
---------------------------
8 x 8
255 219 <- identifies table
0 67 <- size

0 or 1 <- IDs, will be used later in SOF0

Followed by 64 bytes of the quantization table ...

Huffman Tables:
--------------------------------------------------------------
16 bits total ??? Why 16 - because of 8 bit precision, what about 12??

Example:
255 196
0 31 -> length
0 -> I'm not sure what the first 0 is
0 1 5 1 1 1 
The 2nd zero says 0 things use 1 bits
2 bits - 1
3 bits - 5
etc

Then we have:
0    1    2    3    4    5    6    7    8    9   10   11

This gets applied as cumatively to the preceeding values
i.e. 
2 bits for 0
3 bits for 1 2 3 4 5 <- 5 total
4 bits for 6 <- 1 total

Another example:
16 <- ????
0    2    1    3    3    2    4    3    5    5    4    4    0    0    1  125



Tc Th <- single byte
Tc -> table class
    - 0 DC or lossless
    - 1 AC table
Th -> Huffmann Table Destination Identifier
   - specifies one of four possible destinations into which the Huffman
   table shall be installed

0 - DC Class 0
1 - DC Class 1
16 - AC Class 0
17 - AC Class 1



%}



%{

ENCODING STEPS:
----------------------------------------

1) Color Space Transform
Y  = 0.299 * R + 0.587 * G + 0.114 * B;
Cb = 0.492 * (B - Y);
Cr = 0.877 * (R - Y);
Y -= 128.0;

2) Downsampling

3) Block Splitting
8 x 8

4) DCT

5) Quantization

8 x 8
%Top left - DC coefficient
%difference of DC coefficients is encoded
%

- color space transforms
- downsampling
- block splitting
- dct
- quantization
  - up to 4 tables, 64 values in each table
- encoding


%Destination ID - 0
%Class 0 - DC / Lossless Table

%Des



%}


%{

EVERYTHING IS BIG ENDIAN :/

1  - 9   - 216 - SOI start of image
2  - 11  - 224 - APP0 Application Data
3  - 23  - 224 
4  - 41  - 219 - DQT Quantization Tables
5  - 110 - 219 
6  - 179 - 192 - SOF0 Baseline DCT
7  - 198 - 196 - DHT  Define Huffman Tables
8  - 231 - 196
9  - 414 - 196
10 - 447 - 196
11 - 630 - 218 - SOS Start of Scan



From index:
%get's start and length

%- 00dc
%- # of bytes

%Some application data
%



If you skip the dc and the # of bytes, then you can write the remainder to
disk and have it be read as a normal jpg


%There is a premature ending warning from Matlab ...
%This is because we need to add 255 217 (end of image)
%
%   NOTE: Start is 255 216


%}

% % X'FF', SOI
% %  
% %   X'FF', DHT, length, Huffman table parameters (only in still JPEG)
% %   X'FF', DRI, length, restart interval
% %   X'FF', DOT,
% %        length                Lq = 67 for JPEG_Y or
% %                                   132 for JPEG_RGB or JPEG_YCbCr
% %        Precision, Table ID,  Pq = 0, Tq = 0
% %        DQT data [64]
% %        [If 3 Components
% %           Precision, Table ID,    Pq = 0, Tq = 1
% %           DQT data [64]
% %        ]
% %   X'FF', SOF0, length,
% %  
% %        Sample Precision      P = 8
% %        Number of lines       Y = biHeight
% %        Sample per line       X = biWidth
% %        Number of components  Nc = 1 or 3 (must match information from
% %          JPEGColorSpaceID)
% %  
% %                                           YCbCr     RGB
% %        1st Component parameters   C1=     1 =Y      4 =R
% %        2nd Component parameters   C2=     2 =Cb     5 =G
% %        3rd Component parameters   C3=     3 =Cr     6 =B
% %        *
% %        *]
% %   X'FF', SOS, length,
% %  
% %        Number of components  Ns = 1 or 3 (must match information from
% %          JPEGColorSpaceID)
% %  
% %                                           YCbCr     RGB
% %        1st Component parameters   C1=     1 =Y      4 =R
% %        2nd Component parameters   C2=     2 =Cb     5 =G
% %        3rd Component parameters   C3=     3 =Cr     6 =B
% %        *
% %        *
% %        *
% %  
% % X'FF', EOI

