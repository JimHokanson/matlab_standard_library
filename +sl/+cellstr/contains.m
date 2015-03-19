function mask = contains(data,strings_or_patterns,varargin)
%x Returns mask on whether each string contains the pattern
%
%   mask = sl.cellstr.contains(data,strings_or_patterns,varargin)
%
%   Note the current behavior is to 'or' the responses such that a match to
%   any pattern will return true. 
%
%   Inputs:
%   -------
%   data : cellstr
%   strings_or_patterns : char or cellstr
%       
%   Optional Inputs:
%   ----------------
%   case_sensitive : logical (default false)
%   regexp : logical (default false)
%
%   
%
%   TODO: Insert usage example and finish documentation
%
%   Improvements:
%   -------------
%   1) Provide 'and' functionality
%   2) Allow specifying a regxp flag for every pattern (i.e. 'regexp' would
%   be an array)
%
%
%   Examples:
%   ---------
%   1)
%   data = {'this is a test','example I am','cheeseburger'}
%   strings_or_patterns = {'test' 'cheese'};
%   mask = sl.cellstr.contains(data,strings_or_patterns)
%   mask => [1 0 1]
%
%
%   See Also:
%   ---------
%   sl.str.contains

in.relationship = 'or'; %NYI, could do 'AND' as well
in.case_sensitive = false;
in.regexp = false;
in = sl.in.processVarargin(in,varargin);

if in.case_sensitive
    fh = @regexp;
else
    fh = @regexpi;
end

if ~iscell(data)
    error('Input data must be a cellstr')
end


mask = false(1,length(data));

if ischar(strings_or_patterns)
    strings_or_patterns = {strings_or_patterns};
end

for iPattern = 1:length(strings_or_patterns)
    str_or_pattern = strings_or_patterns{iPattern};
    
    if ~in.regexp
       str_or_pattern = regexptranslate('escape',str_or_pattern);
    end

    cur_mask = mask;
    
    %negating cur_mask provides an 'or' function rather than not negating
    %which would do 'and'
    I = fh(data(~cur_mask),str_or_pattern,'once');

    mask(~cur_mask) = ~cellfun('isempty',I);
    
end

end