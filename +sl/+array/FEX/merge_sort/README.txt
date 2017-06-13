MergeSortedArrays package

The main function is mergesa.m

Type
>> help mergesa.m
for usage

installation:

- copy the files in user folder
- Add the folder to matlab path (using menu <File> <Set Path>)
- if need, setup mex by 
   >> mex -setup
- lauch
  >> mergesa_install

Package contents:

mergemex.c 
mergemex.m 
mergerowsmex.c 
mergerowsmex.m 
mergesa.m 
mergesa_install.m 
README.txt 
testmerge.m 

Author Bruno Luong <brunoluong@yahoo.com>
Date: 03-Oct-2010
      31-Oct-2010 small speed improvement
      02-Nov-2013 fix bug of merge rows with empty array
