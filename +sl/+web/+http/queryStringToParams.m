function output = queryStringToParams(queryString,varargin)
%queryStringToParams
%
%   This function is not properly documented and will eventually be moved
%   into a http request class
%
%
%   params = sl.web.http.queryStringToParams(queryString)
%
%   OUTPUTS
%   ================================================================
%   
%   
%   OPTIONAL INPUTS
%   ================================================================
%   make_struct : (default true)
%
%
%   NOTE: This function does not decode the outputs ...
%
%note, instead of struct allow map as well

in.make_struct    = true;
in.decode_entries = true;
in.decode_method  = 1;
in = processVarargin(in,varargin);

% temp  = stringToCellArray(queryString,'&');
% temp2 = cellfun(@(x) stringToCellArray(x,'='),temp,'un',0);
% 
% fNames  = cellfun(@(x) x{1},temp2,'un',0);
% fValues = cellfun(@(x) x{2},temp2,'un',0);

%fields, param, value
temp = regexp(queryString,'(?<param>[^=]+)=(?<value>[^&]*)&*','names');

params = {temp.param};
values = {temp.value};

if in.decode_entries
   I = strfind(queryString,'%');
   if ~isempty(I)
      if in.decode_method == 1
         params = cellfun(@urldecode,params,'un',0);
         values = cellfun(@urldecode,values,'un',0);
      end
   end
end

if in.make_struct    
    output = cell2struct(values,params,2);
else
    output = cell(1,length(values)*2);
    output(1:2:end) = params;
    output(2:2:end) = values;
end