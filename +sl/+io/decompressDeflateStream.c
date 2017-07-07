#include "mex.h"
#include "zlib.h"
#include <stdint.h>

//  sl.io.decompressDeflateStream

/*
 TODO: Provide round trip example
 *
 *
 *
 */


// The tricky part of this code is getting the proper zlib library code
// in place for Windows. I don't remember how I did this :/ 
// It involved compiling from source. For Macs, the -lz flag works.

//  Compiling
//  --------------------------------
//  windows command:
//  mex decompressDeflateStream.c zlibstat.lib
//
//  mac command:
//  mex -lz decompressDeflateStream.c

void throwError(int ret){
    //TODO: Add on strm.msg, requires presumably copying before clearing
    mexErrMsgIdAndTxt("SL:decompressDeflateStream:decompression_error","decompressionError: %d, something went wrong ...",ret);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{    
    //   Usage
    //   -----
    //   output_data = sl.io.decompressDeflateStream(uint8_data,n_bytes_out);
    //
        
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
    
    //Structure of z_stream, for reference
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
    
    //This code is based on:
    //https://zlib.net/zpipe.c
    
    z_stream strm;
    
    //These are apparently necessary to specify ...
    strm.zalloc = Z_NULL; //We shouldn't need to allocate ...
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    
    //  uInt     avail_in;  /* number of bytes available at next_in */
    strm.avail_in = n_data_samples;
    //  z_const Bytef *next_in;     /* next input byte */
    strm.next_in = data_in; //This is a a pointer to the input data
    
    //uInt     avail_out; /* remaining free space at next_out */
    strm.avail_out = n_samples_out;
    //Bytef    *next_out; /* next output byte will go here */
    strm.next_out = data_out;
    
    //This is some old code for when I thought a project I was working with
    //had stripped the leading zlib header. I was just passing in the wrong
    //data section. Eventually we could provide this feature as an optional
    //input to this function
    
    // http://stackoverflow.com/questions/18700656/zlib-inflate-failing-with-3-z-data-error 
    //We don't expect gzip headers, so we need a negative number
    //Not sure why -15 is better than any other negative number
    //int ret = inflateInit2(&strm,-15);
    
    int ret = inflateInit(&strm);
    
    if (!(ret == Z_STREAM_END || ret == Z_OK)){
        //??? How is the error message allocated??? strm.msg
        //Is it on the stack?
        mexPrintf("Return: %d",ret);
        (void)inflateEnd(&strm);
        throwError(ret);
    }
    
    
    ret = inflate( &strm, Z_FINISH );
    
    if (!(ret == Z_STREAM_END || ret == Z_OK)){
        //??? How is the error message allocated??? strm.msg
        //TODO: Figure out how to 
        (void)inflateEnd(&strm);
        throwError(ret);
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

    
    /* clean up and return */
    (void)inflateEnd(&strm);
    //return ret == Z_STREAM_END ? Z_OK : Z_DATA_ERROR;
    
    
    
    //--------------------------------------------------------
    
    
}