function I = findSingularMatch(string_to_match,cellstr_data,varargin)
%
%
%   I = sl.str.findSingularMatch(string_to_match,cellstr_data)
%
%   This function can be used to find a match with the added check of 
%   ensuring that it is a singular match
%
%   INPUTS
%   -----------------------------------------------------------
%   string_to_match : (char)
%   cellstr_data : {cellstr}
%
%
%   IMPROVEMENTS:
%   --------------------------------------
%   - allow 0?
%   - Custom empty message
%   - Custom +1 message
%   - Custom strcmp -> strcmpi, strcmpn, etc

%NOTE: If we are sure that we only have 0 or 1 instances, we could possibly
%implement a short circuit comparison to improve peformance. For example,
%when doing a directory listing, the contents of a directory will not be
%repeated (generally).

%TODO: Should do check of string_to_match and cellstr_data

I = find(strcmp(string_to_match,cellstr_data));

if isempty(I)
    error('No matches found for string:\n"%s"\n',string_to_match);
elseif length(I) > 1
    error('%d matches found instead of only one for string:\n%s\n',length(I),string_to_match);
end

