#include "mex.h"
#include "zlib.h"
#include <stdint.h>

//This might work:
//https://github.com/qbittorrent/qBittorrent/wiki/Compiling-with-MSVC-2013-(static-linkage)#compiling-zlib

// input = 1:10000;
//  buffer = java.io.ByteArrayOutputStream();
//  zlib = java.util.zip.DeflaterOutputStream(buffer);
//  zlib.write(input, 0, numel(input));
//  zlib.close();
//  output = typecast(buffer.toByteArray(), 'uint8')';



//      sl.io.decompressDeflateStream(uint8(1),2)

//  d = linspace(0,100,1e7);
//  tic; wtf = same_diff(d); toc;

//LDFLAGS="$LDFLAGS -lz"
//  Compile via:
//  mex decompressDeflateStream.c zlibstat.lib
//
//  mac command
//  mex -lz decompressDeflateStream.c

//%C:\Program Files\MATLAB\R2015b\bin\win64

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
    //
    //  This blog post describes how to modify rhs values safely
    //
    //  http://undocumentedmatlab.com/blog/matlab-mex-in-place-editing
    //
    //   Usage
    //   -----
    //   output_data = decompressDeflateStream(uint8_data,n_bytes_out);
    //
    //   TODO: We should also have an input of the form:
    //   (uint8_data,n_bytes_out,start_I_1_based,n_samples)
    //
    //   This is for when the input is part of a larger stream
    //
    //   Ideally we could output to a larger stream, but Matlab doesn't
    //   like modifications of RHS variables
    
    //mexPrintf("Whats up\n");
    
    if (nrhs != 2){
        mexErrMsgIdAndTxt("SL:decompressDeflateStream:call_error","Invalid # of inputs, 2 expected");
    }else if (!mxIsClass(prhs[0],"uint8")){
        mexErrMsgIdAndTxt("SL:decompressDeflateStream:call_error","The 1st input must be of type uint8");
    }else if (!mxIsClass(prhs[1],"double")){
        mexErrMsgIdAndTxt("SL:decompressDeflateStream:call_error","The 2nd input must be of type double");
    }
    
    if (!(nlhs == 1)){
        mexErrMsgIdAndTxt("SL:decompressDeflateStream:call_error","Invalid # of outputs, 1 expected");
    }
    
    mwSize n_data_samples = mxGetNumberOfElements(prhs[0]);
    Bytef *data_in = mxGetData(prhs[0]);
    
    mwSize n_samples_out = mxGetScalar(prhs[1]);
    
    plhs[0] = mxCreateNumericMatrix(1,0,mxUINT8_CLASS,0);
    uint8_t *data_out = mxMalloc(n_samples_out);
    
    //--------------------------------------------------------
    //  http://www.zlib.net/manual.html#Stream
    // typedef struct z_stream_s {
    //     z_const Bytef *next_in;     /* next input byte */
    //     uInt     avail_in;  /* number of bytes available at next_in */
    //     uLong    total_in;  /* total number of input bytes read so far */
    //
    //     Bytef    *next_out; /* next output byte will go here */
    //     uInt     avail_out; /* remaining free space at next_out */
    //     uLong    total_out; /* total number of bytes output so far */
    //
    //     z_const char *msg;  /* last error message, NULL if no error */
    //     struct internal_state FAR *state; /* not visible by applications */
    //
    //     alloc_func zalloc;  /* used to allocate the internal state */
    //     free_func  zfree;   /* used to free the internal state */
    //     voidpf     opaque;  /* private data object passed to zalloc and zfree */
    //
    //     int     data_type;  /* best guess about the data type: binary or text
    //                            for deflate, or the decoding state for inflate */
    //     uLong   adler;      /* Adler-32 or CRC-32 value of the uncompressed data */
    //     uLong   reserved;   /* reserved for future use */
    // } z_stream;
    
    
    z_stream strm;
    
    //These are apparently necessary to specify ...
    strm.zalloc = Z_NULL; //We shouldn't need to allocate ...
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    
    //  uInt     avail_in;  /* number of bytes available at next_in */
    strm.avail_in = n_data_samples;
    //  z_const Bytef *next_in;     /* next input byte */
    strm.next_in = data_in; //TODO: This is a a pointer to the input data
    
    //uInt     avail_out; /* remaining free space at next_out */
    strm.avail_out = n_samples_out;
    //Bytef    *next_out; /* next output byte will go here */
    strm.next_out = data_out;
    
    // http://stackoverflow.com/questions/18700656/zlib-inflate-failing-with-3-z-data-error
    
    int ret = inflateInit2(&strm,-15);
    
    
    if (!(ret == Z_STREAM_END || ret == Z_OK)){
        //??? How is the error message allocated??? strm.msg
        mexPrintf("Return: %d",ret);
        (void)inflateEnd(&strm);
        mexErrMsgIdAndTxt("SL:decompressDeflateStream:decompression_error","Something went wrong ...");
    }
    
    
    ret = inflate( &strm, Z_FINISH );
    
    if (!(ret == Z_STREAM_END || ret == Z_OK)){
        //??? How is the error message allocated??? strm.msg
        mexPrintf("Return: %d",ret);
        (void)inflateEnd(&strm);
        mexErrMsgIdAndTxt("SL:decompressDeflateStream:decompression_error","Something went wrong ...");
    }
    
    mxSetData(plhs[0],data_out);
    mxSetN(plhs[0],n_samples_out);
    
    // #define Z_OK            0
    // #define Z_STREAM_END    1    - all done
    // #define Z_NEED_DICT     2
    // #define Z_ERRNO        (-1)
    // #define Z_STREAM_ERROR (-2)
    // #define Z_DATA_ERROR   (-3)
    // #define Z_MEM_ERROR    (-4)
    // #define Z_BUF_ERROR    (-5)
    // #define Z_VERSION_ERROR (-6)
    
    
// // // // //     ret = inflate(&strm, Z_NO_FLUSH);
// // // // //     assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
// // // // //     switch (ret) {
// // // // //     case Z_NEED_DICT:
// // // // //         ret = Z_DATA_ERROR;     /* and fall through */
// // // // //     case Z_DATA_ERROR:
// // // // //     case Z_MEM_ERROR:
// // // // //         (void)inflateEnd(&strm);
// // // // //         return ret;
// // // // //     }
    
//     nErr= inflate( &zInfo, Z_FINISH );
    
    //This is the no error case ...
//     if ( nErr == Z_STREAM_END ) {
//         nRet= zInfo.total_out;
//     }
    
    
//     zInfo.total_in =  zInfo.avail_in=  nLenSrc;
//     zInfo.total_out=0;
//     zInfo.avail_out= nLenDst;
//     zInfo.next_in= (BYTE*)abSrc;
//     zInfo.next_out= abDst;
    
    
    //http://www.zlib.net/zpipe.c
    
    /* clean up and return */
    (void)inflateEnd(&strm);
    //return ret == Z_STREAM_END ? Z_OK : Z_DATA_ERROR;
    
    
    
    //--------------------------------------------------------
    
    
}