function unique_char_array = unique(char_array)
%unique  Computes unique set of characters
%
%   unique_char_array = sl.str.quick.unique(char_array)
%
%   This is the first in a series of small functions designed 
%   to be really small and quick and to not provide all of the frills
%   that another implementation of the function could provide.
%
%   unique_char_array = sl.str.quick.unique('asdfasdfasdfghert')
%   unique_char_array => adefghrst

%Safety off
% % % assert(ischar(char_array),'Input must be a character array')
% % % assert(isvector(char_array),'Input must be a vector')

sorted_char_array = sort(char_array);

if isrow(char_array)
    mask = [true sorted_char_array(1:end-1) ~= sorted_char_array(2:end)];
else
    mask = [true; sorted_char_array(1:end-1) ~= sorted_char_array(2:end)];
end

unique_char_array = sorted_char_array(mask);