function str_out = capitalizeWords(str_in)
%
%
%   str_out = sl.str.capitalizeWords(str_in)
%
%   This isn't great for all cases. For example, contractions like don't.

str_out = regexprep(str_in,'(\<\w)','${upper($1)}');

end