function addExportPDFOption(h_fig)
%
%   sl.plot.uimenu.addExportPDFOption(h_fig)
%
%   Improvements
%   ------------
%   Allow adding a popup GUI that easily manipulates the options for
%   calling the function (when I add options to the underlying function)
%
%   See Also
%   --------
%   sl.plot.export.saveAsPDF

TEXT = 'Export to PDF';

if nargin == 0
    h_fig = gcf;
end

m = sl.plot.uimenu.menu('Custom',h_fig);
mitem = m.addChild(TEXT,'Callback',@(~,~)sl.plot.export.saveAsPDF(h_fig));

end