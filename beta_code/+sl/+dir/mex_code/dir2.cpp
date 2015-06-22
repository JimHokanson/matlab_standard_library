#include "mex.h"
#include <stdlib.h>
#include <string.h>
#include <msclr\marshal.h>
using namespace msclr::interop;
using namespace System;
using namespace System::IO;

//JAH NOTE: Still working on getting mex flags right
//I need to remove a flag, I'd like to be able to do that
//via some command, instead of listing all of the other ones

//.NET code in Matlab
//NET.addAssembly('System')
//wtf = System.IO.DirectoryInfo('C:\Users\RNEL\Desktop\Matlab_Work')
//


//Managed targeted code requires /clr

//mex  \CLR dir2.cpp
//mex COMPFLAGS="$COMPFLAGS /clr" dir2.cpp
//Need to remove /EHs

//TO CHECK OUT
//----------------------------
//http://msdn.microsoft.com/en-us/library/c5b8a8f9.aspx

//This link discusses all of the includes for the marshaling process
//http://msdn.microsoft.com/en-us/library/vstudio/bb384859(v=vs.100).aspx

void mexFunction (int nlhs, mxArray *plhs[], int nrhs,const mxArray *prhs[])
{
    
    //Usage
    //list = dir2(dir_path)
    
	mxArray *output_array;
	char* dir_name;
	int iiCell;

	//This is needed for ????
	marshal_context^ context = gcnew marshal_context();

	// Grab file path from input (TODO: In matlab verify this path as valid ...)
	//Might do it in here ...
	//-----------------------------------------------------------------------------
	size_t N    = mxGetNumberOfElements(prhs[0]);
    dir_name = (char *)mxMalloc( (N+1)*sizeof(char));
    mxGetString(prhs[0], dir_name, N+1);

	//Retrieval of directories in this directory
	//-------------------------------------------------------------------------------
	//Copied from: http://msdn.microsoft.com/en-us/library/s7xk2b58(v=vs.100).aspx
    //System.IO.DirectoryInfo
	DirectoryInfo^ di = gcnew DirectoryInfo(marshal_as<String^>(dir_name));
    array<DirectoryInfo^>^diArr = di->GetDirectories();

	//Initialize output
	//NOTE: The result tells of the directory search tells us the size
	//so we initialize here ...
	plhs[0] = mxCreateCellMatrix(1, diArr->Length);
	output_array = plhs[0];

   //Create the output ...
   //--------------------------------------------------------------------------------
   Collections::IEnumerator^ myEnum = diArr->GetEnumerator();
   iiCell = -1;
   while (myEnum->MoveNext() )
   {
	  iiCell += 1;
      DirectoryInfo^ dri = safe_cast<DirectoryInfo^>(myEnum->Current);
      //mexPrintf("%s\n", dri->Name );
	  //mexPrintf("%d\n",iiCell);

	  //http://msdn.microsoft.com/en-us/library/bb384856.aspx
	  //http://www.mathworks.com/help/matlab/apiref/mxsetcell.html
	  //void mxSetCell(mxArray *pm, mwIndex index, mxArray *value);
	  mxSetCell(output_array,iiCell,mxCreateString(context->marshal_as<const char*>( dri->Name )));

   }

}