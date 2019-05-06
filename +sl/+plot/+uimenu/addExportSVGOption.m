function addExportSVGOption(h_fig)
%
%   sl.plot.uimenu.addExportSVGOption(h_fig)
%
%   Perhaps this could be a bit more generic ...
%
%   WARNING: This function may get renamed ...
%
%   See Also
%   --------
%   sl.plot.export.saveAsSVG

TEXT = 'Export to SVG';

if nargin == 0
    h_fig = gcf;
end

m = sl.plot.uimenu.menu('Custom',h_fig);
mitem = m.addChild(TEXT,'Callback',@(~,~)sl.plot.export.saveAsSVG(h_fig));

end