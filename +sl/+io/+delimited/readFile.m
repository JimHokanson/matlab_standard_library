function [output,extras] = readFile(file_path,delimiter,varargin)
%x  Reads a delimited file
%
%   Simple interface to regexp with some post-processing options for
%   reading a delimited file OR DELIMITED STRING.
%
%   Calling Forms:
%   --------------
%   1)
%   [output,extras] = sl.io.delimited.readFile(file_path,delimiter,varargin)
%
%   2)
%   [output,extras] = sl.io.delimited.readFile(str_data,delimiter,'input_is_str',true,varargin)   
%   
%   Examples:
%   ---------
%   readDelimitedFile(filePath,'\s*:\s*') - read file with a ':' delimiter
%       that might have space on either side ...
%
%   Inputs:
%   -------
%   file_path : 
%       Path to the file to read
%   delimiter : 
%       Delimiter to use in reading the file
%
%   Optional Inputs:
%   ----------------
%   return_type : {'cell','object'} (default 'cell')
%       - 'cell' => cell array
%       - 'object' => sl.io.delimited_file
%       - 'table' => Matlab table
%   merge_lines  : (default true), if true returns a cell array matrix
%                  if false, returns a cell array of cell arrays
%   header_lines : (default 0), if non-zero then the lines should be
%           rerned without processing
%   default_ca   : (default ''), the default empty entry for a cell array
%                   This is used when creating a matrix with rows that
%                   don't have the same number of columns
%   deblank_all  : (default false), if true uses deblank() on all entries
%   strtrim_all  : (default false), if true uses strtrim() on all entries
%   remove_empty_lines : (default false), if true, removes empty lines
%                         see Implementation Notes
%   row_delimiter : (default '\r\n|\n'), goes into regexp to get lines of
%                   delimited file ...
%   make_row_delimiter_literal : (default false), if true then backslashes
%       will be converted so that they are treated as backslashes during
%       matching, i.e. instead of \n matching a newline, it will match \n
%   make_delimiter_literal : (default false), same effect as above
%       property, just for the column delimiter
%   single_delimiter_match : (default false), true can be used
%       for property value files where the delimiter is not observed
%       in the property name, but may be observed in the property value
%       and thus we split on only the first one
%
%   Outputs:
%   --------
%   output : either a 
%               - cellstr matrix {'a' 'b'; 'c' 'd'}
%               - cell array of cellstr {{'a' 'b'} {'c' 'd'}}
%               See 'merge_lines' input
%   extras : (structure)
%       .raw           - raw text from file
%       .header_lines  - first n lines, see "header_lines" optional input
%   
%   Implementation Notes:
%   ---------------------
%   1) The last line if empty is always removed ...
%   2) Removal of empty lines is done before delimiter parsing, not
%   aftewards, i.e. a row with only delimiters will not be removed ...
%
%   See Also:
%   ---------
%   sl.io.delimited.column_specs
%   sl.io.delimited.delimited_file
   
if nargin == 1
    error('A 2nd input that specifies the delimiter is required for this function')
end

in.has_column_labels = false;

in.columns_specs = [];
in.input_is_str  = false; %If true, then 
in.merge_lines   = true;
in.header_lines  = 0;
in.default_ca    = '';
in.deblank_all   = false;
in.strtrim_all   = false;
in.row_delimiter = '\r\n|\n|\r';
in.make_row_delimiter_literal = false;
in.make_delimiter_literal     = false;
in.remove_empty_lines         = false;  %Any line which literally has no 
%content will be removed. This does not check if all cells in a row are
%empty.
in.remove_lines_with_no_content = false; %If each cell for a line is empty,
%then the line is deleted
in.single_delimiter_match = false;
in.return_type = 'cell'; %object
in = sl.in.processVarargin(in,varargin);

%Currently this association needs to hold
in.has_column_labels = strcmpi(in.return_type,'object');

%Obtaining the text data - change to using an optional input ...
%--------------------------------------------------------------------
if in.input_is_str
    text = file_path; 
else
    if ~exist(file_path,'file')
        error_msg = sl.error.getMissingFileErrorMsg(file_path);
        error(error_msg);
        %error('Missing file %s',file_path)
    end

    text = fileread(file_path);
end

%Fixing delimiters
%-------------------------------------------------------
if in.make_row_delimiter_literal
    in.row_delimiter = regexptranslate('escape',in.row_delimiter);
end

%Column delimiter ...
if in.make_delimiter_literal
    delimiter = regexptranslate('escape',delimiter);
end

%Lines handling
%--------------------------------------------------------
lines = regexp(text,in.row_delimiter,'split');

if isempty(lines)
    lines = {text};
end

if in.has_column_labels
   first_line_string = lines{1};
   extras.column_labels = regexp(first_line_string,delimiter,'split');
   lines(1) = [];
elseif in.header_lines > 0
   extras.header_lines = lines(1:in.header_lines);
   lines(1:in.header_lines) = [];
end

if isempty(lines{end})
    lines(end) = [];
end

if in.remove_empty_lines
   lines(cellfun('isempty',lines)) = [];
end

%Delimiter handling 
%------------------------------------------------------
if in.single_delimiter_match
    temp = regexp(lines,delimiter,'split','once');
else
    temp = regexp(lines,delimiter,'split');
end

%1st layer, lines, 
%2nd layer should be columns

if in.remove_lines_with_no_content
    no_content_mask = cellfun(@(x) all(cellfun('isempty',x)),temp);
    temp(no_content_mask) = [];
    
end

nLines = length(temp);

%OLD CODE: Might eventually be useful
%NOTE: This required reconstructing the delimiter
% if in.max_delimiters_per_line > 0
%    %ex. one delimiter splits two entries
%    max_entries = in.max_delimiters_per_line + 1;
%    for iLine = 1:nLines
%       cur_entry = temp{iLine};
%       if length(cur_entry) > max_entries
%          cur_entry{max_entries} = [cur_entry{max_entries:end}];
%          cur_entry(max_entries+1:end) = [];
%          temp{iLine} = cur_entry;
%       end
%    end
% end


if in.strtrim_all || in.deblank_all
    if in.strtrim_all && in.deblank_all
        error('Only one space removal option should be set')
    elseif in.strtrim_all
        fHandle = @strtrim;
    else
        fHandle = @deblank_all;
    end
    
   for iLine = 1:nLines
      temp{iLine} = cellfun(fHandle,temp{iLine},'un',0); 
   end
end

if in.merge_lines
   %Get the length of each cell array
   %Make a matrix from all lines
   nEach  = cellfun('length',temp);
   output = cell(nLines,max(nEach));
   output(:) = {in.default_ca};
   for iLine = 1:nLines
      output(iLine,1:nEach(iLine)) = temp{iLine}; 
   end
end

extras.raw = text;

switch lower(in.return_type)
    case 'cell'
        % Do nothing
    case 'object'
        output = sl.io.delimited.delimited_file(output, extras, in.columns_specs);
    case 'table'
        temp = cell2table(output(2:end,:));
        temp.Properties.VariableNames = output(1,:);
        output = temp;
    otherwise
        error('Output type: "%s" not recognized',in.return_type);
end
        