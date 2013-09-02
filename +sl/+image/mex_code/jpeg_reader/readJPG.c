/*

Status: This code is currently unfinished. 
 
I need to decide upon the calling format. There are quite a few flags that
would be nice to expose to the user.

Currently it decodes a jpg image from memory

img = readJPG(uint8_data)

file_path = '/Users/jameshokanson/Desktop/Music/Mos Def & Talib Kweli/Black Star/AlbumArt_{745F688E-9905-448D-9269-9905ACC1D8C2}_Large.jpg'

data = sl.io.fileRead(file_path,'*uint8'); 

img_data = permute(sl.image.readJPG(data),[3 2 1]);
*/


//I'm not sure what these are needed for ...
#include <stdio.h>
#include <stdint.h>

//These are a bit more obvious
#include <turbojpeg.h>
#include "mex.h"

//http://www.mathworks.com/matlabcentral/newsreader/view_thread/81585
//http://www.mathworks.com/matlabcentral/answers/35071
//
//  Windows compiling. Currently this must be done from the same directory
//
//mex -I"C:\libjpeg-turbo64\include" COMPFLAGS="$COMPFLAGS /MT"  readJPG.c turbojpeg-static.lib
//
//mex -I"/opt/libjpeg-turbo/include" readJPG.c libturbojpeg.a

//http://stackoverflow.com/questions/9094691/examples-or-tutorials-of-using-libjpeg-turbos-turbojpeg

/*
 * Main Documentation:
 * http://www.libjpeg-turbo.org/Documentation/Documentation
 * See C API
 *
 *
 *  Functions Used:
 *  tjDecompressHeader2
 *  tjDecompress2
 */
void mexFunction( int nlhs, mxArray *plhs[], 
                  int nrhs, const mxArray*prhs[] )
{ 
    
    //Calling form
    //img_data = readJPG(uncompressed_image_data);
    
    uint8_T* buffer;
    
    unsigned char* compressed_image;
    int compressed_image_size;
    
    mwSize dims[3] = {0,0,0};
    int width;
    int height;
    int jpeg_subsamp;
    
    if (nrhs != 1) { 
        mexErrMsgTxt("1 input required, image data as uint8");
    }else if (!mxIsUint8(prhs[0])) {
        mexErrMsgTxt("Input data type must be uint8"); 
    }
    
    compressed_image = (unsigned char *)mxGetData(prhs[0]);
    compressed_image_size = (int)mxGetNumberOfElements(prhs[0]);
    
    tjhandle jpeg_decompressor = tjInitDecompress();
    
    //Retrieve image information, namely width and height
    //tjhandle handle, unsigned char *jpegBuf, unsigned long jpegSize, int *width, int *height, int *jpegSubsamp
    tjDecompressHeader2(jpeg_decompressor, compressed_image, compressed_image_size, &width, &height, &jpeg_subsamp);
    
    //NOTE, this might eventually change based on what we want out
    //--------------------------------------------
    buffer = mxMalloc((width)*(height)*3); //*3 implies RGB

    //mexPrintf("Width: %d\n",width);
    //mexPrintf("Height: %d\n",height);
    //mexPrintf("sub_samp: %d\n",jpeg_subsamp);
    
        /*
     * tjhandle handle
     * unsigned char *jpegBuf
     * unsigned long jpegSize, 
     * unsigned char *dstBuf, 
     * int width, 
     * int pitch, 
     * int height, 
     * int pixelFormat, 
     *      TJPF_GRAY - does this work for RGB ???
     * int flags
     *
     *  There are a lot of potentially useful options here. Eventually
     *  it might be useful to expose them.
     *
     *  TJFLAG_FASTDCT - fast DCT/IDCT algorithm, has more of an impact
     *  on decompression, currently enabled by default
     *  TJXOPT_GRAY - discard color data, produce grayscale image instead 
     */
    
    
    //Last two inputs are flags and options
    //I'm not sure how to distinguish them, but the inputs are very different
    
    tjDecompress2(jpeg_decompressor, compressed_image, compressed_image_size, buffer, width, 0, height, TJPF_RGB, TJFLAG_FASTDCT);

    tjDestroy(jpeg_decompressor);
    
    //Setup Output
    //------------------------------------------------------------------
    plhs[0] = mxCreateNumericArray(3,&dims[0], mxUINT8_CLASS, mxREAL);
    
    mxSetData(plhs[0], buffer);
	    
    dims[0] = 3;
    dims[1] = width;
    dims[2] = height;
    
    mxSetDimensions(plhs[0],&dims[0], 3);
    
    //OLD, single dimension only
    //-------------------------------
    //plhs[0] = mxCreateNumericMatrix(0, 0, mxUINT8_CLASS, mxREAL);
    //mxSetM(plhs[0], width*height*3);
    //mxSetN(plhs[0], 1);
    
}