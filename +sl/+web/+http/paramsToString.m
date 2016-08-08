function [query_string,header] = paramsToString(params,encode_option)
%http_paramsToString Creates string for a POST or GET requests
%
%   [queryString,header] = sl.web.http.paramsToString(params, *encodeOption)
%
%   INPUTS
%   =======================================================================
%   params        : {n x props,values} or {prop, value, prop value, etc.} 
%   encode_option : (default 1)
%           1 - the typical URL encoding scheme (Java call)
%           2 - oauth encoding, this is mainly different from the Java
%               call in the way that spaces are encoded '%20' vs '+'
%               
%   OUTPUTS
%   =======================================================================
%   query_string: String to add onto the end of a URL. This string lacks
%       the '?' character at the beginning.
%   header     : the header that should be attached for post requests when
%                using urlread2
%
%   EXAMPLE:
%   =======================================================================
%   params = {'cmd' 'search' 'db' 'pubmed' 'term' 'wtf batman'};
%   queryString = http_paramsToString(params);
%   queryString => cmd=search&db=pubmed&term=wtf+batman
%
%
%   IMPORTANT, this function does not:
%       - filter parameters
%       - sort them
%       - remove empty inputs (if necessary)
%   This must be done before hand.
%
%   See Also:
%   urlread2
%   oauth.percentEncodeString

if ~exist('encode_option','var')
    encode_option = 1;
end

if size(params,2) == 2 && size(params,1) > 1
    params = params';
    params = params(:)';
elseif size(params,1) > 1
    params = params';
end

query_string = '';
for iParam = 1:2:length(params)
    if (iParam == 1), separator = ''; else separator = '&'; end
    switch encode_option
        case 1
            param  = urlencode(params{iParam});
            value  = urlencode(params{iParam+1});
        case 2
            param    = oauth.percentEncodeString(params{iParam});
            value    = oauth.percentEncodeString(params{iParam+1});
        otherwise
            error('Case not used')
    end
    query_string = [query_string separator param '=' value]; %#ok<AGROW>
end

switch encode_option
    case {1 2}
        header = sl.web.http.createHeader('Content-Type','application/x-www-form-urlencoded');
end


end