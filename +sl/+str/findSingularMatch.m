function output = findSingularMatch(string_to_match,cellstr_data,varargin)
%
%   indices_or_mask = sl.str.findSingularMatch(string_to_match,cellstr_data,varargin)
%
%   This function matches a string against an array of strings (cell array
%   of strings) and ensures that only a singular match is found (i.e. not
%   zero matches or more than one).
%
%   Inputs
%   ------
%   string_to_match : (char)
%       The string to find in the cellstr_data input argument. This can
%       be a regular expression pattern if 'use_regexp' is enabled
%   cellstr_data : {cellstr}
%
%   Optional Inputs
%   ---------------
%   use_regexp: logical (default false)
%       If true, the search is made using regular expressions
%   as_mask: logical (default false)
%       If true, then a logical mask is returned. If false, then matching
%       indices are returned.
%   zero_ok: logical (default false)
%
%   Outputs
%   -------
%   indices_or_mask : logical or numerical array
%       Type depends on 'as_mask' optional input. The mask refers to a
%       logical array, with a true value indicating a match.
%
%
%   IMPROVEMENTS:
%   --------------------------------------
%   - Custom empty message
%   - Custom +1 message
%   - Custom strcmp -> strcmpi, strcmpn, etc
%   - *** make this depend on findMatch
%
%

%TODO: Add on documentation that explains how to make things singular
error('Use findMatches instead')

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
