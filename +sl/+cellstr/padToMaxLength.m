function new_strings = padToMaxLength(old_strings,varargin)
%x Pad all strings to a given length
%
%   new_strings = sl.cellstr.padToMaxLength(old_strings,varargin)
%
%   Outputs
%   -------
%   new_strings : cellstr
%
%   Inputs
%   ------
%   old_strings : cellstr
%   
%   Optional Inputs
%   ---------------
%   pad_length : default []
%       By default all strings are padded to the length of the maximum
%       length string. This allows specifying a longer string.
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
%   old_strings = {
%   'test'
%   'padText'
%   'something'
%   '123'}
%   new_strings = sl.cellstr.padToMaxLength(old_strings);
%   new_strings => 
%     {'test     '} %Note they all have the same length
%     {'padText  '}
%     {'something'}
%     {'123      '}
%
%   See Also
%   --------
%   sl.str.padText
%   

in.text_loc = []; %'left', 'right', or 'center' - left would indicate
in.pad_type = []; %opposite of text_loc
in.pad_char = ' ';
in.pad_length = [];
in = sl.in.processVarargin(in,varargin);

if isempty(in.pad_length)
    max_length = max(cellfun('length',old_strings));
else
    max_length = in.pad_length;
end
in = rmfield(in,'pad_length');

new_strings = cellfun(@(x) sl.str.padText(x,max_length,in),old_strings,'un',0);

end