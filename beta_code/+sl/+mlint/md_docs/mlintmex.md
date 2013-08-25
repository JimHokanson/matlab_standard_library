## mlintmex ##


## mlintmex calling formats ##

When the file_path contains non-ascii characters apparently this format is needed ...

    mlintmex(file_string,file_path,'-text',options{:})

## questions ##

Matlab can analyze a file in the editor without that file being saved.


Note: These might be better as a set of examples of calling mlintmex





- Can pass in either a string or filepath (requires '-text' switch)
  - string still requires filename as 2nd input, for non-ascii filenames
- More than one filename can be passed in for the first set of inputs. This is done by multiple input positions, not by a cellstr to the first input


When given multiple files, the outputs are returned with the name of the
function.
========== C:\D\SVN_FOLDERS\matlab_toolboxes\database\version_2\hds\@HDS\HDS.m ==========
L 202 (C 72-82): MSNU: A Code Analyzer message was once suppressed here, but the message is no longer generated.
L 329 (C 62-66): When checking if a variable is a matrix consider using ISMATRIX.
========== C:\D\SVN_FOLDERS\matlab_toolboxes\database\version_2\classes\@Trial\Trial.m ==========
L 177 (C 30): This statement (and possibly following ones) cannot be reached.
L 195 (C 21-23): The value assigned here to 'iiA' appears to be unused. Consider replacing it by ~.



%An Invalid Option:
%temp = mlintmex(h,'-asdf');
%-----------------------------------------
%L 0 (C 0): Option '-asdf' is ignored because it is invalid.