function out = addQuotes(data,varargin)
%x Add quotes (or other char) around each string
%
%   out = sl.cellstr.addQuotes(data,varargin)
%
%   Example
%   -------
%   data = {'str1','str2','str3'};
%   disp(join(data,','))
%   %   => 'str1,str2,str3'
%   data2 = sl.cellstr.addQuotes(data);
%   disp(join(data2,','))
%   %   => ''str1','str2','str3''
%
%   See Also
%   --------
%   sl.cellstr.rowsToStrings

in.char = '''';
in = sl.in.processVarargin(in,varargin);

if strcmp(in.char,'''')
    %This might be slightly faster for normal case
    out = cellfun(@h__addQuote,data,'un',0);
else
    out = cellfun(@(x) h__addChar(x,in.char),data,'un',0);
end    

end

function out = h__addQuote(str)
    out = ['''' str ''''];
end

function out = h__addChar(str,char)
    out = [char str char];
end