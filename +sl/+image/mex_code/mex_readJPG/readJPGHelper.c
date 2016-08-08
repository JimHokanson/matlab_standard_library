/*
 *  This code is meant to be used in conjunction with the function readJPG.m
 *
 *  It is a very basic wrapper to the libjpeg-turbo library using the TURBO-JPEG API
 */


//I'm not sure what these are needed for ...
#include <stdio.h>
#include <stdint.h>

//These are a bit more obvious
#include <turbojpeg.h>
#include "mex.h"

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
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] )
{
    
    //Calling form:
    //img_data = readJPG(uncompressed_image_data);
    //
    //  INPUTS
    //  ------------------------------------------------
    //  uncompressed_image_data: (uint8 array)
    //
    //
    //  Documentation
    //  http://libjpeg-turbo.sourceforge.net/ljtdoc.branches_1.3.x/turbojpeg-c/group___turbo_j_p_e_g.html
    
    uint8_T* buffer;
    
    unsigned char* compressed_image;
    int compressed_image_size;
    
    mwSize dims[3] = {0,0,0};
    int width;
    int height;
    int pixel_format;
    int flags;
    int is_3d;
    int option;
    int jpeg_subsamp;
    tjhandle jpeg_decompressor;
    
    //Input Checking
    //---------------------------------------------------------------------
    if (nrhs != 2) {
        mexErrMsgTxt("2 inputs needed, readJPGHelper(u8_data,option)");
    }else if (!mxIsUint8(prhs[0])) {
        mexErrMsgTxt("Input data type must be uint8");
    }
    
    //Input Retrieval
    //---------------------------------------------------------------------
    compressed_image      = (unsigned char *)mxGetData(prhs[0]);
    compressed_image_size = (int)mxGetNumberOfElements(prhs[0]);
    option                = (int)mxGetScalar(prhs[1]);
        
    switch (option) {
        case 1:
            //fast RGB
            flags = TJFLAG_FASTDCT;
            pixel_format = TJPF_RGB;
            is_3d = 1;
            break;
        case 2:
            //slow RGB
            flags = 0;
            pixel_format = TJPF_RGB;
            is_3d = 1;
            break;
        case 3:
            //fast gray
            flags = TJFLAG_FASTDCT;
            pixel_format = TJPF_GRAY;
            is_3d = 0;
            break;
        case 4:
            //slow gray
            flags = 0;
            pixel_format = TJPF_GRAY;
            is_3d = 0;
            break;
        default:
            mexErrMsgTxt("Invalid input option");
            break;   
    }
    
    
    jpeg_decompressor = tjInitDecompress();
    
    //Retrieve image information, namely width and height
    //tjhandle handle, unsigned char *jpegBuf, unsigned long jpegSize, int *width, int *height, int *jpegSubsamp
    //
    // NOTE: This might change for 1.4 ... to tjDecompressHeader3 with color type included
    tjDecompressHeader2(jpeg_decompressor, compressed_image, compressed_image_size, &width, &height, &jpeg_subsamp);
    
    //NOTE, this might eventually change based on what we want out
    //--------------------------------------------
    if (is_3d) {
        buffer = mxMalloc((width)*(height)*3); //*3 implies RGB
    }else{
        buffer = mxMalloc((width)*(height));
    }
    
    //mexPrintf("Width: %d\n",width);
    //mexPrintf("Height: %d\n",height);
    //mexPrintf("sub_samp: %d\n",jpeg_subsamp);
    
    
    //Last two inputs are flags and options
    //I'm not sure how to distinguish them, but the inputs are very different
    //After height:
    //1) pixel_format
    //2) flags
    //
    //Pixel Formats
    //---------------------------------------------------------------------
    //TJPF_RGB - RGB
    //TJPF_GRAY
    //
    //Flags
    //---------------------------------------------------------------------
    //TJFLAG_FASTDCT - used fastest IDCT algorithm
    //TJFLAG_FASTUPSAMPLE - not exposed
    //
    //TJXOPT_GRAY - discard color, produce gray
    
    tjDecompress2(jpeg_decompressor, compressed_image, compressed_image_size, buffer, width, 0, height, pixel_format, flags);
    
    //For gray, do I need to convery to YUV then grab
    
    tjDestroy(jpeg_decompressor);
    
    //Setup Output
    //------------------------------------------------------------------
    
    if (is_3d) {
        plhs[0] = mxCreateNumericArray(3,&dims[0], mxUINT8_CLASS, mxREAL);
        
        mxSetData(plhs[0], buffer);
        
        dims[0] = 3;
        dims[1] = width;
        dims[2] = height;
        mxSetDimensions(plhs[0],&dims[0], 3);
    } else {
        plhs[0] = mxCreateNumericMatrix(0, 0, mxUINT8_CLASS, mxREAL);
        mxSetData(plhs[0], buffer);
        mxSetM(plhs[0], width);
        mxSetN(plhs[0], height);
    }

    
    
    
    //OLD, single dimension only
    //-------------------------------
    //plhs[0] = mxCreateNumericMatrix(0, 0, mxUINT8_CLASS, mxREAL);
    //mxSetM(plhs[0], width*height*3);
    //mxSetN(plhs[0], 1);
    
}