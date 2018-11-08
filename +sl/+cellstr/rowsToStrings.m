function out = rowsToStrings(data,varargin)
%x 
%
%   out = sl.cellstr.rowsToStrings(data,varargin)
%
%   Example
%   -------
%   data = {'str1','str2','str3';'str4','str5','str6'};
%   out = sl.cellstr.rowsToStrings(data)
%   out => 
%       {''str1','str2','str3''}
%       {''str4','str5','str6''}

in.quote_char = '''';
in.delimiter = ',';
in = sl.in.processVarargin(in,varargin);

if ~isempty(in.quote_char)
    temp = sl.cellstr.addQuotes(data,'char',in.quote_char);
else
    temp = data;
end

n_rows = size(data,1);
out = cell(n_rows,1);
for i = 1:n_rows
    %TODO: We could make this faster ...
    out{i} = sl.cellstr.join(temp(i,:),'d',in.delimiter);
end


end