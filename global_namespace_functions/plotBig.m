function plotBig(varargin)
%x Like Matlab's plot function except it handles large data nicely
%
%   plotBig()
%
%   See Also:
%   sl.plot.big_data.LinePlotReducer
%
%   TODO: output handles ...

wtf = sl.plot.big_data.LinePlotReducer(varargin{:});
wtf.renderData();

end