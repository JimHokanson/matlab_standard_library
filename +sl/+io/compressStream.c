#include "mex.h"
#include "zlib.h"
#include <stdint.h>

//TODO: Do we need to drop a few bytes at the beginning????

//TODO: look into chunk size
//..CHUNK is simply the buffer size for feeding data to and pulling data from the zlib routines. Larger buffer sizes would be more efficient, especially for inflate(). If the memory is available, buffers sizes on the order of 128K or 256K bytes should be used.
//#define CHUNK 16384

//This might work:
//https://github.com/qbittorrent/qBittorrent/wiki/Compiling-with-MSVC-2013-(static-linkage)#compiling-zlib


//TODO: How to not get the first couple of bytes by default???

//    wtf = sl.io.compressStream(uint8([1:255 1:255 1:255]));
//    orig = sl.io.decompressDeflateStream(wtf(3:end),765);


//LDFLAGS="$LDFLAGS -lz"
//  Compile via:
//  mex compressStream.c zlibstat.lib
//
//  mac command
//  mex -lz compressStream.c

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{

    //   Usage
    //   -----
    //   output_data = compressStream(uint8_data);

    if (nrhs != 1){
        mexErrMsgIdAndTxt("SL:compressStream:call_error","Invalid # of inputs, 2 expected");
    }else if (!mxIsClass(prhs[0],"uint8")){
        mexErrMsgIdAndTxt("SL:compressStream:call_error","The 1st input must be of type uint8");
    }
    
    //else if (!mxIsClass(prhs[1],"double")){
    //    mexErrMsgIdAndTxt("SL:decompressDeflateStream:call_error","The 2nd input must be of type double");
    //}
    
    if (!(nlhs == 1)){
        mexErrMsgIdAndTxt("SL:decompressDeflateStream:call_error","Invalid # of outputs, 1 expected");
    }
    
    mwSize n_data_samples = mxGetNumberOfElements(prhs[0]);
    Bytef *data_in = mxGetData(prhs[0]);
    
    //mwSize n_samples_out = mxGetScalar(prhs[1]);
    
    plhs[0] = mxCreateNumericMatrix(1,0,mxUINT8_CLASS,0);
    
    
    
    //---------------------------------------------------------------------
    
    int ret;
    mwSize total_out;
    
    z_stream strm;

    /* allocate deflate state */
    strm.zalloc = Z_NULL;
    strm.zfree  = Z_NULL;
    strm.opaque = Z_NULL;
    
    //TODO: Pass in the level optionally
    ret = deflateInit(&strm, 6);
    
    if (ret != Z_OK){
        mexPrintf("Return: %d",ret);
        (void)deflateEnd(&strm);
        mexErrMsgIdAndTxt("SL:compressStream:initialization_error","Something went wrong ...");
    }
    
    
    strm.avail_in = n_data_samples;
    strm.next_in = data_in;
    strm.avail_out = n_data_samples + 10;
    
    //For right now we'll compress in 1 pass. We could change this to 
    //reduce allocation but then we would need to do multiple passes.
    uint8_t *data_out = mxMalloc(deflateBound(&strm,n_data_samples));
    
    strm.next_out = data_out;

    //Z_FINISH indicates to finish writing all the compression overheads
    ret = deflate(&strm, Z_FINISH); 
    
    //What other codes might we get
    //Why not look at Z_OK?
    if (ret == Z_STREAM_ERROR){
        //??? How is the error message allocated??? strm.msg
        mexPrintf("Return: %d",ret);
        (void)deflateEnd(&strm);
        mexErrMsgIdAndTxt("SL:compressStream:compression_error","Something went wrong ...");
    }
    
    
    //This needs to be used to trim the output
    total_out = strm.total_out;


    /* clean up and return */
    (void)deflateEnd(&strm);

    mxSetData(plhs[0],data_out);
    mxSetN(plhs[0],total_out);
    //TODO: Clean up output
    
    
    
    
    
    
    
    
    
    
    
    
    
    
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
    

    
    // #define Z_OK            0
    // #define Z_STREAM_END    1    - all done
    // #define Z_NEED_DICT     2
    // #define Z_ERRNO        (-1)
    // #define Z_STREAM_ERROR (-2)
    // #define Z_DATA_ERROR   (-3)
    // #define Z_MEM_ERROR    (-4)
    // #define Z_BUF_ERROR    (-5)
    // #define Z_VERSION_ERROR (-6)

    
}