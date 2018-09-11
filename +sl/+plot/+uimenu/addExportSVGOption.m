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

c = get(h_fig,'Children');
is_menu_class = arrayfun(@(x) isa(x,'matlab.ui.container.Menu'),c);

c_menu = c(is_menu_class);

if isempty(c_menu)
    I = [];
else
    I = find(strcmp({c_menu.Text},'Custom'),1);
end

add_menu = true;
if ~isempty(I)
    m = c_menu(I);
    c2 = get(m,'Children');
    if ~isempty(c2)
        I = find(strcmp({c2.Text},TEXT),1);
        add_menu = isempty(I);
    end
else
    m = uimenu(h_fig,'Text','Custom'); 
end

if add_menu
    mitem = uimenu(m,'Text',TEXT,'Callback',@(~,~)sl.plot.export.saveAsSVG(h_fig));
end


%https://www.mathworks.com/help/matlab/ref/uimenu.html


end