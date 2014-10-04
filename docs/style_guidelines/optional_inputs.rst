Handling Optional Inputs to a Function
======================================

This document is meant to outline how optional inputs to a function are handled in this library. This document will not cover variable calling forms, which for the most part are avoided.

Other Approaches
----------------

1. Having input arguments that are sometimes passed in and sometimes are not. This approach usually involves checking the number of arguments passed into a function, or alternatively, whether or not certain variables are defined.

TODO: Show examples

This approach is generally fine for an additional argument or two, but often times it is hard to tell how many additional arguments are needed. Adding additional arguments over time can make these functions unwieldly.

2. Input Parser - TODO

3. DEFINE CONSTANTS - TODO

Approach used in this repo
--------------------------

An example:

.. code-block:: matlab

  function [output,extras] = readDelimitedFile(filePath,delimiter,varargin)
  
  in.row_delimiter = '\r\n|\n|\r';
  in.make_row_delimiter_literal = false;
  in.make_delimiter_literal     = false;
  in.remove_empty_lines         = false;  %Any line which literally has no 
  %content will be removed. This does not check if all cells in a row are
  %empty.
  in.remove_lines_with_no_content = false; %If each cell for a line is empty,
  %then the line is deleted
  in.single_delimiter_match = false;
  in = sl.in.processVarargin(in,varargin);

All optional inputs are passed into a structure called 'in'. There is nothing magic about this variable name, it is just a consistent name for use that is also quite short.
