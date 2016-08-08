#include "MatFile.h"
#include "mex.h"
#include <cstdio>
#include <cstdlib>
#include <exception>

typedef unsigned char byte;

static unsigned int lo_word = 255;
static unsigned int hi_word = lo_word << 8;

static const int HeaderSize = 116;
static const int SubSysSize = 8;
using namespace std;


unsigned short bswap_16(unsigned short x) {
    return (x>>8) | (x<<8);
}

unsigned int bswap_32(unsigned int x) {
    return (bswap_16(x&0xffff)<<16) | (bswap_16(x>>16));
}


namespace MexSupport
{
    MatFile::MatFile(const char *filename) throw(std::exception)
        : mFilename(filename), mFid(0x0){
            if ( !openFile() )
            {
                mexPrintf("wut\n");
                //   throw(std::exception("MatFile::openFile() failed!"));
            }
        }

    MatFile::~MatFile() {
        closeFile();
    }

    bool MatFile::openFile(){
        if( mFid != 0x0 ) {
            if ( !closeFile()) {
                return false;
            }
        }
        mFid = fopen(mFilename.c_str(), "rb");
        return mFid != 0x0;
    }

    bool MatFile::closeFile(){
        fclose(mFid);
        return true;
    }

    bool MatFile::isOpen() const
    {
        return mFid != 0x0;
    }

    void MatFile::parseAll()
    {
        if( isOpen() )
        {
            mexPrintf("reading header\n");
            parseHeader();

            mexPrintf("\nreading subsys\n");
            parseSubSys();

            mexPrintf("\nreading flags\n");
            parseHeaderFlags();

            int ii = 0;
            /*
            while( !feof(mFid) )
            {
                mexPrintf("\nreading entry %d\n",ii);
                readVariable();
                ii++;
            }
            */
        }
    }
    void MatFile::parseHeader(){
        char * header = (char *)malloc(HeaderSize*sizeof(char)+1);
        header[HeaderSize] = '\0';
        int n = fread(header,  sizeof(char), HeaderSize, mFid);
        mexPrintf("%s\n",header);
        free(header);
    }

    void MatFile::parseSubSys(){
        byte* buffer= (byte*)malloc(SubSysSize*sizeof(byte));
        int n = fread(buffer,  sizeof(byte), SubSysSize, mFid);
        free(buffer);
    }

    void MatFile::parseHeaderFlags(){
        unsigned short version;
        unsigned short endian_tmp;
        char * endian = (char *)malloc(3*sizeof(char));
        endian[3] = '\0';

        fread(&version,  sizeof(unsigned short), 1, mFid);
        fread(&endian_tmp,  sizeof(unsigned short), 1, mFid);
        version    = bswap_16(version);
        endian_tmp = bswap_16(endian_tmp);
        endian[0]  = char(endian_tmp & lo_word);
        endian[1]  = char((endian_tmp & hi_word) >> 8); 
        mexPrintf("version: %x endian: %s\n",version, endian);
        free(endian);

    }

    void MatFile::readVariable()
    {

        unsigned int datatype;
        fread(&datatype,sizeof(unsigned int),1,mFid);
        if ( (datatype & 3) == 0)
        {
            // small format
            short small_numbytes = (datatype & lo_word);
            short small_datatype = (datatype & hi_word) >> 8;
            unsigned int the_data;
            fread(&the_data, sizeof(unsigned int), 1, mFid);
            mexPrintf("small things!\n");
        }   
        else
        {
            unsigned int num_bytes;
            fread(&num_bytes, sizeof(unsigned int),1,mFid);

            //            mexPrintf("Type: %d Num Bytes: %d",bswap_32(datatype),bswap_32(num_bytes));
            datatype  = bswap_32(datatype);
            num_bytes = bswap_32(num_bytes);
            mexPrintf("Type: %d Num Bytes: %d",datatype,num_bytes);

            // skip for now
            fseek(mFid, num_bytes,SEEK_CUR);
        }
    }

}
