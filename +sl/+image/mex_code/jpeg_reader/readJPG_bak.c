/*

Status: This code is currently unfinished. 
 
I need to decide upon the calling format. There are quite a few flags that
would be nice to expose to the user.

Currently it decodes a jpg image from memory

img = readJPG(uint8_data)


*/


//I'm not sure what these are needed for ...
#include <stdio.h>
#include <stdint.h>

//These are a bit more obvious
#include <turbojpeg.h>
#include "mex.h"

//http://www.mathworks.com/matlabcentral/newsreader/view_thread/81585
//http://www.mathworks.com/matlabcentral/answers/35071
//mex -I"C:\libjpeg-turbo64\include" COMPFLAGS="$COMPFLAGS /MT"  please2.c turbojpeg-static.lib

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
void pleaseWork(unsigned char* compressed_image, int jpegSize,unsigned char** ret_buffer,int* width, int* height){
 
    uint8_T* buffer;
    int jpegSubsamp;
    
    tjhandle jpegDecompressor = tjInitDecompress();
    
    

    //tjhandle handle, unsigned char *jpegBuf, unsigned long jpegSize, int *width, int *height, int *jpegSubsamp
    tjDecompressHeader2(jpegDecompressor, compressed_image, jpegSize, width, height, &jpegSubsamp);

    buffer      = mxMalloc((*width)*(*height)*3);
    
    *ret_buffer = buffer;

    //mexPrintf("Width: %d\n",width);
    //mexPrintf("Height: %d\n",height);
    //mexPrintf("sub_samp: %d\n",jpegSubsamp);
    
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
     *  on decompression
     *  TJXOPT_GRAY - discard color data, produce grayscale image instead
     *
     *  
     *  
     */
    
    
    
    tjDecompress2(jpegDecompressor, compressed_image, jpegSize, buffer, *width, 0, *height, TJPF_RGB, TJFLAG_FASTDCT);

    tjDestroy(jpegDecompressor);
}

void mexFunction( int nlhs, mxArray *plhs[], 
                  int nrhs, const mxArray*prhs[] )
{ 
    
    uint8_T* bufferRef;
    mwSize dims[3] = {0,0,0};
    int width;
    int height;
    
    if (nrhs != 1) { 
        mexErrMsgTxt("Two inputs argument required.");
    }
    
    //TODO: Check input type, should be uint8
    
    pleaseWork((unsigned char *)mxGetData(prhs[0]),(int)mxGetNumberOfElements(prhs[0]),&bufferRef,&width,&height);
    
    plhs[0] = mxCreateNumericArray(3,&dims[0], mxUINT8_CLASS, mxREAL);
    
    
    
    mxSetData(plhs[0], bufferRef);
	
	//plhs[0] = mxCreateNumericMatrix(0, 0, mxUINT8_CLASS, mxREAL);
    //mxSetM(plhs[0], width*height*3);
    //mxSetN(plhs[0], 1);
    
    dims[0] = 3;
    dims[1] = width;
    dims[2] = height;
    
    mxSetDimensions(plhs[0],&dims[0], 3);
    
}