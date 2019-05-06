function str_out = padText(input_str,total_len,varargin)
%x Pads a sting with a character to a given length
%
%   str_out = sl.str.padText(input_str,total_len,varargin)
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
%       Currently only a single character is supported for padding 
%
%   Examples
%   --------
%   %1 - Default options
%   %Note I add 'x' and 'X' so that the padding can be visualized
%   disp(['x' sl.str.padText('test',30) 'X'])
%   => xtest                          x
%   
%   %2 - pad to the left (text goes to the right)
%   disp(['x' sl.str.padText('test',30,'text_loc','right') 'X'])
%   => x                          testX
%
%   %3 - pad with a different character
%   disp(['x' sl.str.padText('test',30,'pad_char','.') 'X'])
%   => xtest..........................X

%{
    %error testing
    disp(sl.str.padText('test',3))
    disp(sl.str.padText('test','text_loc','up'))

    disp(sl.str.padText('test',30))
    disp(sl.str.padText('test',30,'text_loc','right'))
%}

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
    error('The string to pad (length %d) is longer than the desired length after padding: %d',str_length,total_len);
end

remaining_length = total_len - str_length;

if length(in.pad_char) ~= 1
    error('Multiple length pad char currently unsupported')
end

%TODO: Check input_str dimensionality, throw error if column vector
repc = @(n) repmat(in.pad_char,1,n);

switch lower(in.text_loc)
    case 'right'
        str_out = [repc(remaining_length) input_str];
    case 'left'
        str_out = [input_str repc(remaining_length)];
    case 'centered'
        half_length = floor(remaining_length/2);
        right_len   = half_length;
        left_len    = remaining_length - right_len;
        str_out     = [repc(left_len) input_str repc(right_len)];
    otherwise
        error('"text_loc" option: "%s" is not recognized',in.text_loc)
end