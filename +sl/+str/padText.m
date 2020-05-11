function str_out = padText(input_str,total_len,varargin)
%x Pads a string with a character to a given length
%
%   str_out = sl.str.padText(input_str,total_len,varargin)
%
%   Inputs
%   ------
%   total_len :
%       Length of the string to achieve. Note, if the string is already
%       too long I've added functionality that truncates ('too_long' and
%       'truncate_str')
%       
%
%   Optional Inputs
%   ---------------
%   disp_len : numeric (default [])
%       Pass this in if the length of the input string is not the same
%       as the length of the string when displayed (due to html markup)
%   text_loc : {'left','right','center'} (default 'left')
%       'left' indicates that the padding goes to the right
%   pad_type : {'left','right','center'} (default 'right')
%       This is the opposite of 'text_loc' for 'left' and 'right'. It can
%       be used if it is preferable to the user to specify where the
%       padding goes rather than where the text goes.
%   pad_char : character (default ' ')
%       ** Currently only a SINGLE character is supported for padding 
%   too_long : TODO: Document
%       - 'error' - throw an error
%       - 'truncate' - truncate
%       - 'leave' - leave string as is 
%   truncate_str : default '...'
%
%   Examples
%   --------
%   %1 - Default options
%   %Note I add 'x' and 'X' so that the padding can be visualized
%   disp(['x' sl.str.padText('test',30) 'X'])
%   => xtest                          X
%   
%   %2 - pad to the left (text goes to the right)
%   disp(['x' sl.str.padText('test',30,'text_loc','right') 'X'])
%   => x                          testX
%
%   %3 - pad with a different character
%   disp(['x' sl.str.padText('test',30,'pad_char','.') 'X'])
%   => xtest..........................X
%
%   %4) - truncates if too long
%   disp(['x' sl.str.padText('this is a long string',10,'too_long','truncate') 'X'])
%   xthis is...X
%
%   %5) - but pads if too short
%   disp(['x' sl.str.padText('this is a long string',30,'too_long','truncate') 'X'])
%   xthis is a long string         X

%{
    %error testing
    disp(sl.str.padText('test',3))
    disp(sl.str.padText('test','text_loc','up'))

    disp(sl.str.padText('test',30))
    disp(sl.str.padText('test',30,'text_loc','right'))
%}

in.too_long = 'error';
%- 'truncate'
%- 'leave'
in.truncate_str = '...';
in.disp_len = []; %Pass in if the length should be adjusted. This was
%created for using this function with strings that had links.
in.text_loc = []; %'left', 'right', or 'center' - left would indicate
in.pad_type = [];
in.pad_char = ' ';
in = sl.in.processVarargin(in,varargin);

if isempty(in.pad_type) && isempty(in.text_loc)
    in.text_loc = 'left';
elseif isempty(in.pad_type)
    %do nothing, in.text_loc is what we are using
elseif isempty(in.text_loc)
    switch lower(in.pad_type)
        case 'left'
            in.text_loc = 'right';
        case 'right'
            in.text_loc = 'left';
        case 'center'
            in.text_loc = 'center';
        otherwise
            error('"pad_type" option: "%s" is not recognized',in.pad_type)
    end
else
    error('Code error, case unhandled')
end

if isempty(in.disp_len)
    str_length = length(input_str);
else
    str_length = in.disp_len;
end

if str_length > total_len
    remaining_length = 0;
    switch lower(in.too_long)
        case 'error'
            error('The string to pad (length %d) is longer than the desired length after padding: %d',str_length,total_len);
        case 'truncate'
            input_str = sl.str.truncateStr(input_str,total_len,'short_indicator',in.truncate_str);
        case 'leave'
            %do nothing to string ...
    end
else
    remaining_length = total_len - str_length;
end

if length(in.pad_char) ~= 1
    error('Multiple length pad char currently unsupported')
end

%TODO: Check input_str dimensionality, throw error if column vector
rep_char = @(n) repmat(in.pad_char,1,n);

switch lower(in.text_loc)
    case 'right'
        str_out = [rep_char(remaining_length) input_str];
    case 'left'
        str_out = [input_str rep_char(remaining_length)];
    case 'centered'
        half_length = floor(remaining_length/2);
        right_len   = half_length;
        left_len    = remaining_length - right_len;
        str_out     = [rep_char(left_len) input_str rep_char(right_len)];
    otherwise
        error('"text_loc" option: "%s" is not recognized',in.text_loc)
end