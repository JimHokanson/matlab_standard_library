classdef constants
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    %MJPG only
    %SOF - 0,1,2,3,9,10,11 - only baseline dct? -SOF0
    
    
    properties (Constant)
        %??? Why are all of the bytes flipped
        %mjpg is big endian :/
        
        SOF0 = uint16(hex2dec('C0FF'))
        SOF1 = uint16(hex2dec('C1FF'))
        SOF2 = uint16(hex2dec('C2FF'))
        SOF3 = uint16(hex2dec('C3FF'))
        
    #define JIFMK_SOF0    0xFFC0   /* SOF Huff  - Baseline DCT*/
#define JIFMK_SOF1    0xFFC1   /* SOF Huff  - Extended sequential DCT*/    
        #define JIFMK_SOF2    0xFFC2   /* SOF Huff  - Progressive DCT*/
#define JIFMK_SOF3    0xFFC3   /* SOF Huff  - Spatial (sequential) lossless*/
#define JIFMK_SOF5    0xFFC5   /* SOF Huff  - Differential sequential DCT*/
#define JIFMK_SOF6    0xFFC6   /* SOF Huff  - Differential progressive DCT*/
#define JIFMK_SOF7    0xFFC7   /* SOF Huff  - Differential spatial*/
#define JIFMK_JPG     0xFFC8   /* SOF Arith - Reserved for JPEG extensions*/
#define JIFMK_SOF9    0xFFC9   /* SOF Arith - Extended sequential DCT*/
 
#define JIFMK_SOF10   0xFFCA   /* SOF Arith - Progressive DCT*/
#define JIFMK_SOF11   0xFFCB   /* SOF Arith - Spatial (sequential) lossless*/
#define JIFMK_SOF13   0xFFCD   /* SOF Arith - Differential sequential DCT*/
#define JIFMK_SOF14   0xFFCE   /* SOF Arith - Differential progressive DCT*/
#define JIFMK_SOF15   0xFFCF   /* SOF Arith - Differential spatial*/
#define JIFMK_DHT     0xFFC4   /* Define Huffman Table(s) */
#define JIFMK_DAC     0xFFCC   /* Define Arithmetic coding conditioning(s) */
        
        
        
        
        
        
        
        SOI = uint16(hex2dec('D8FF'))    %Start of Image
        EOI = uint16(hex2dec('D9FF'))    %End of Image
        SOS = uint16(hex2dec('DAFF'))    %Start of Scan
        DQT = uint16(hex2dec('DBFF'))    %Define quantization Table(s)
        DNL = uint16(hex2dec('DCFF'))    %Define Number of Lines
        DRI = uint16(hex2dec('DDFF'))    %Define Restart Interval
        DHP = uint16(hex2dec('DEFF'))    %Define Hierarchical progression
        EXP = uint16(hex2dec('DFFF'))    %Expand Reference Component(s)     
    end
    
    methods
    end
    
end

%{

#define JPEG_DIB     mmioFOURCC('J','P','E','G');
                     /* Still image JPEG DIB biCompression */
#define MJPG_DIB     mmioFOURCC('M','J','P','G'); 
                     /* Motion JPEG DIB biCompression     */
 
    /* JPEGProcess Definitions */
#define JPEG_PROCESS_BASELINE    0    /* Baseline DCT */
 
    /* JIF Marker byte pairs in JPEG Interchange Format sequence */
#define JIFMK_SOF0    0xFFC0   /* SOF Huff  - Baseline DCT*/
#define JIFMK_SOF1    0xFFC1   /* SOF Huff  - Extended sequential DCT*/
 
#define JIFMK_SOF2    0xFFC2   /* SOF Huff  - Progressive DCT*/
#define JIFMK_SOF3    0xFFC3   /* SOF Huff  - Spatial (sequential) lossless*/
#define JIFMK_SOF5    0xFFC5   /* SOF Huff  - Differential sequential DCT*/
#define JIFMK_SOF6    0xFFC6   /* SOF Huff  - Differential progressive DCT*/
#define JIFMK_SOF7    0xFFC7   /* SOF Huff  - Differential spatial*/
#define JIFMK_JPG     0xFFC8   /* SOF Arith - Reserved for JPEG extensions*/
#define JIFMK_SOF9    0xFFC9   /* SOF Arith - Extended sequential DCT*/
 
#define JIFMK_SOF10   0xFFCA   /* SOF Arith - Progressive DCT*/
#define JIFMK_SOF11   0xFFCB   /* SOF Arith - Spatial (sequential) lossless*/
#define JIFMK_SOF13   0xFFCD   /* SOF Arith - Differential sequential DCT*/
#define JIFMK_SOF14   0xFFCE   /* SOF Arith - Differential progressive DCT*/
#define JIFMK_SOF15   0xFFCF   /* SOF Arith - Differential spatial*/
#define JIFMK_DHT     0xFFC4   /* Define Huffman Table(s) */
#define JIFMK_DAC     0xFFCC   /* Define Arithmetic coding conditioning(s) */
 
#define JIFMK_RST0    0xFFD0   /* Restart with modulo 8 count 0 */
#define JIFMK_RST1    0xFFD1   /* Restart with modulo 8 count 1 */
#define JIFMK_RST2    0xFFD2   /* Restart with modulo 8 count 2 */
#define JIFMK_RST3    0xFFD3   /* Restart with modulo 8 count 3 */
#define JIFMK_RST4    0xFFD4   /* Restart with modulo 8 count 4 */
#define JIFMK_RST5    0xFFD5   /* Restart with modulo 8 count 5 */
#define JIFMK_RST6    0xFFD6   /* Restart with modulo 8 count 6 */
#define JIFMK_RST7    0xFFD7   /* Restart with modulo 8 count 7 */
 
#define JIFMK_SOI     0xFFD8   /* Start of Image */
#define JIFMK_EOI     0xFFD9   /* End of Image */
#define JIFMK_SOS     0xFFDA   /* Start of Scan */
#define JIFMK_DQT     0xFFDB   /* Define quantization Table(s) */
#define JIFMK_DNL     0xFFDC   /* Define Number of Lines */
#define JIFMK_DRI     0xFFDD   /* Define Restart Interval */
#define JIFMK_DHP     0xFFDE   /* Define Hierarchical progression */
#define JIFMK_EXP     0xFFDF   /* Expand Reference Component(s) */
 
#define JIFMK_APP0    0xFFE0   /* Application Field 0*/
#define JIFMK_APP1    0xFFE1   /* Application Field 1*/
#define JIFMK_APP2    0xFFE2   /* Application Field 2*/
#define JIFMK_APP3    0xFFE3   /* Application Field 3*/
#define JIFMK_APP4    0xFFE4   /* Application Field 4*/
#define JIFMK_APP5    0xFFE5   /* Application Field 5*/
#define JIFMK_APP6    0xFFE6   /* Application Field 6*/
#define JIFMK_APP7    0xFFE7   /* Application Field 7*/
#define JIFMK_JPG0    0xFFF0   /* Reserved for JPEG extensions */
 
#define JIFMK_JPG1    0xFFF1   /* Reserved for JPEG extensions */
#define JIFMK_JPG2    0xFFF2   /* Reserved for JPEG extensions */
#define JIFMK_JPG3    0xFFF3   /* Reserved for JPEG extensions */
#define JIFMK_JPG4    0xFFF4   /* Reserved for JPEG extensions */
#define JIFMK_JPG5    0xFFF5   /* Reserved for JPEG extensions */
#define JIFMK_JPG6    0xFFF6   /* Reserved for JPEG extensions */
#define JIFMK_JPG7    0xFFF7   /* Reserved for JPEG extensions */
#define JIFMK_JPG8    0xFFF8   /* Reserved for JPEG extensions */
 
#define JIFMK_JPG9    0xFFF9   /* Reserved for JPEG extensions */
#define JIFMK_JPG10   0xFFFA   /* Reserved for JPEG extensions */
#define JIFMK_JPG11   0xFFFB   /* Reserved for JPEG extensions */
#define JIFMK_JPG12   0xFFFC   /* Reserved for JPEG extensions */
#define JIFMK_JPG13   0xFFFD   /* Reserved for JPEG extensions */
#define JIFMK_COM     0xFFFE   /* Comment */
#define JIFMK_TEM     0xFF01   /* for temp private use arith code */
#define JIFMK_RES     0xFF02   /* Reserved */
 
#define JIFMK_00      0xFF00   /* Zero stuffed byte - entropy data */
#define JIFMK_FF      0xFFFF   /* Fill byte */
 
/* JPEGColorSpaceID Definitions */
#define JPEG_Y        1        /* Y only component of YCbCr */
#define JPEG_YCbCr    2        /* YCbCr as define by CCIR 601 */
#define JPEG_RGB      3        /* 3 component RGB */

%}