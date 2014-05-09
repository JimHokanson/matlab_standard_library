function str_out = padText(input_str,total_len,varargin)
%x Pads a sting with a character to a given length
%
%   str_out = sl.str.padText(input_str,total_len,varargin)
%
%   Status: code done, needs to be cleaned up
%

%{
    disp(sl.str.padText('test',30))
    disp(sl.str.padText('test',30,'text_loc','right'))
%}

in.disp_len = []; %Pass in if the length should be adjusted. This was
%created for using this function with strings that had links.
in.text_loc = 'left'; %'left', 'right', or 'center' - left would indicate
%that the padding should go on the right
in.pad_char = ' ';
in = sl.in.processVarargin(in,varargin);

if isempty(in.disp_len)
    str_length = length(input_str);
else
    str_length = in.disp_len;
end

if str_length > total_len
    error('TODO: Fill in with better error code')
end

remaining_length = total_len - str_length;

if length(in.pad_char) ~= 1
    error('Multiple length pad char currently unsupported')
end

%TODO: Check input_str dimensionality, throw error if column vector
repc = @(n) repmat(in.pad_char,1,n);

switch in.text_loc
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
        error('Direction: "%s" is not recognized',in.direction')
end