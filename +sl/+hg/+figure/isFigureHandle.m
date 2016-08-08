function mask = isFigureHandle(handles_in)
%
%
%   mask = sl.plot.isFigureHandle(handles_in)

mask = arrayfun(@helper__isFigure,handles_in);

end

function tf = helper__isFigure(handle)

    tf = strcmp(get(handle,'Type'),'figure');
end