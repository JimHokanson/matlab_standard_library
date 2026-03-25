function addExportPDFOption(h_fig,options)
%
%   sl.plot.uimenu.addExportPDFOption(h_fig,**options)
%
%   Inputs
%   ------
%   h_fig :
%       Pass in an empty value to use the current figure.
%
%   Optional Inputs
%   ---------------
%   - format 
%       - 'vector'
%       - 'image'
%
%   Improvements
%   ------------
%   Allow adding a popup GUI that easily manipulates the options for
%   calling the function (when I add options to the underlying function)
%
%   See Also
%   --------
%   sl.plot.export.saveAsPDF

arguments
    h_fig = [];
    options.format = 'vector';
end

TEXT = 'Export to PDF';

if isempty(h_fig)
    h_fig = gcf;
end

m = sl.plot.uimenu.menu('Custom',h_fig);
mitem = m.addChild(TEXT,'Callback',@(~,~)sl.plot.export.saveAsPDF(h_fig,'format',options.format));

end