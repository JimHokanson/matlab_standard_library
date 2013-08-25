#ifndef MAT_FILE_H
#define MAT_FILE_H

#include <cstdio>
#include <exception>
#include  <string>

#pragma warning(disable: 4290)

namespace MexSupport{

    typedef enum {
        miINT8   = 1,
        miUINT8  = 2,
        miINT16  = 3,
        miUINT16 = 4,
        miINT32  = 5,
        miUINT32 = 6,
        miSINGLE = 7,
        // -- 8 RESERVED --
        miDOUBLE = 9,
        // -- 10 RESERVED --
        // -- 11 RESERVED --
        miINT64  = 12,
        miUINT64 = 13,
        miMATRIX = 14,
        miCOMPRESSED = 15,
        miUTF8  = 16,
        miUTF16 = 17,
        miUTF32 = 18
    }MATFileDataTypes;

    // represents a matfile
    // see http://www.mathworks.com/support/solutions/en/data/1-1617J/?product=ML&solution=1-1617J
    class MatFile {

        public:
            MatFile(const char *filename) throw(std::exception);

            virtual ~MatFile();

            void parseAll();

            bool isOpen() const;
        protected:
            void parseHeader();

            void parseSubSys();

            void parseHeaderFlags();

            void readVariable();
        private:

            MatFile();

            MatFile(const MatFile& );

            MatFile & operator=(const MatFile& );

            bool openFile();

            bool closeFile();

            std::string mFilename;

            FILE* mFid;

    };
};
#endif
