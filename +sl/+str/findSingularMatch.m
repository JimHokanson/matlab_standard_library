function output = findSingularMatch(string_to_match,cellstr_data,varargin)
%
%   output = sl.str.findSingularMatch(string_to_match,cellstr_data)
%
%   This function matches a string against an array of strings (cell array
%   of strings) and ensures that only a singular match is found (i.e. not
%   zero matches or more than one).
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

in.use_regexp = false;
in.as_mask = false;
in.zero_ok = false;
in = sl.in.processVarargin(in,varargin);

%NOTE: If we are sure that we only have 0 or 1 instances, we could possibly
%implement a short circuit comparison to improve peformance. For example,
%when doing a directory listing, the contents of a directory will not be
%repeated (generally).

%TODO: Should do check of string_to_match and cellstr_data

if in.use_regexp
    regex_matches = regexp(cellstr_data,string_to_match,'match','once');
    mask = ~cellfun('isempty',regex_matches);
else
    mask = strcmp(string_to_match,cellstr_data);
end

n = sum(mask);

if n == 0
    if in.zero_ok
        if in.as_mask
            output = mask;
        else
            output = [];
        end
    else
        error('No matches found for string:\n"%s"\n',string_to_match);
    end
elseif n > 1
    error('%d matches found instead of only one for string:\n%s\n',n,string_to_match);
end

if in.as_mask
    output = mask;
else
    output = find(mask);
end
