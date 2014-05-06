function lines = getLines(str)
%
%   lines = sl.str.getLines(str)
lines = regexp(str,'(\n)|(\n\r)','split');
end