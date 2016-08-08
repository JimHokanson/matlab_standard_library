#include "matrix.h"
#include "mex.h"

#include <string>

#include "MexMappedFile.h"
#include "MexTimingSupport.h"

#include "boost/iostreams/device/mapped_file.hpp"

using namespace boost::iostreams;
using namespace std;
namespace MexSupport{
    
    MexMappedFile::MexMappedFile()
    : mpFile(0x0), mFilePos(0) {
    }
    
    MexMappedFile::MexMappedFile(const char* filename)
    : mpFile(0x0), mFilePos(0) {
        fopen(filename, "");
    }
    
    MexMappedFile::~MexMappedFile() {
        if(mpFile != 0x0) {
            if(mpFile->is_open())
                mpFile->close();
            delete mpFile;
        }
    }
    
    void MexMappedFile::fopen(const char* filename, const char* ignore) {
        string filename_str(filename);
        // check to see if a file is already open. if so, close
        if(mpFile != 0x0) {
            if(mpFile->is_open())
                mpFile->close();
            mpFile = 0x0;
        }
        mpFile = new mapped_file_source(filename_str);
//         if( mpFile->is_open())
//             return this;
//         return 0x0;
        return;
    }
    
    MexInt32 MexMappedFile::fseek(MexUInt32 offset, MexInt32 reference) {
        if( ferror())
            return 1;
        
        if(reference == SEEK_SET)
            mFilePos = offset;
        else if (reference == SEEK_CUR )
            mFilePos += offset;
        else if (reference == SEEK_END )
            mFilePos += mpFile->size()-offset;
        
        return 0;
    }
    
    MexInt32 MexMappedFile::ftell() {
        return mFilePos;
    }
    
    MexInt32 MexMappedFile::fread( void *buffer, MexUInt32 size, MexUInt32 count) {
        if( ferror())
            return 0;
        
        int nBytes = size*count;
        if( mFilePos + nBytes > mpFile->size()) {
            // cannot read the specified number of objects, attempt to read
            // a smaller number
            size = (double)(mpFile->size()-mFilePos)/count;
            nBytes = size*count;
        }
        memcpy(buffer, mpFile->data()+mFilePos, nBytes);
        mFilePos += nBytes;
        return size;
    }
    MexInt32 MexMappedFile::fclose() {
        if( !ferror())
            mpFile->close();
        // CAA TODO error check?
        return 0;
    }
    
    bool MexMappedFile::feof() {
        return !ferror() && (mFilePos == mpFile->size());
    }
    
    void MexMappedFile::rewind() {
        if( !ferror())
            mFilePos = 0;
        return;
    }
    
    MexInt32 MexMappedFile::ferror() {
        return  ( (mpFile != 0x0) & mpFile->is_open() ? 0 : 1);
    }
};