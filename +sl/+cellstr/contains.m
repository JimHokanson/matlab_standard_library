function mask = contains(data,str_or_pattern,varargin)
%x Returns mask on whether each string contains the pattern
%
%   mask = sl.cellstr.contains(data,str_or_pattern,varargin)
%
%   This is mainly meant to avoid

in.case_sensitive = false;
in.regexp = false;
in = sl.in.processVarargin(in,varargin);

if ~in.regexp
   str_or_pattern = regexptranslate('escape',str_or_pattern);
end

if in.case_sensitive
    fh = @regexp;
else
    fh = @regexpi;
end

I = fh(data,str_or_pattern,'once');

mask = ~cellfun('isempty',I);

end