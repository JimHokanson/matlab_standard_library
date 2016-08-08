#ifndef MEX_MAPPED_FILE_H
#define MEX_MAPPED_FILE_H

#include "MexDataTypes.h"

namespace boost{
    namespace iostreams{
        class mapped_file_source;
    };
};

namespace MexSupport{
    class MexMappedFile{
    public:
        MexMappedFile();
        MexMappedFile(const char* filename);
        ~MexMappedFile();
        
        void fopen(const char*, const char*);
        MexInt32 fseek(MexUInt32, MexInt32);
        MexInt32 ftell();
        MexInt32 fread( void *, MexUInt32 size, MexUInt32 count);
        MexInt32 fclose();
        bool feof();
        void rewind();
        MexInt32 ferror();
    private:
        MexMappedFile(const MexMappedFile&);
        MexMappedFile& operator=(const MexMappedFile&);
        
        
        boost::iostreams::mapped_file_source* mpFile;
        // current position in the file
        MexUInt32 mFilePos;
    };
};

#endif