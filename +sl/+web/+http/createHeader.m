function header = createHeader(name,value)
%http_createHeader Simple function for creating input header to urlread2
%
%   header = sl.web.http.createHeader(name,value)
%
%   CODE: header = struct('name',name,'value',value);
%
%   See Also: 
%       urlread2

header = struct('name',name,'value',value);