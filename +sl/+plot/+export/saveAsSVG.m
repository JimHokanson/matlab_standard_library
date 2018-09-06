function saveAsSVG(h_fig)
%X Save figure as SVG with prompt for filename
%
%   sl.plot.export.saveAsSVG(*h_fig)
%
%   Improvements
%   ------------
%   1) Allow file specification ...

if nargin == 0
   h_fig = gcf; 
end

[file_name,path_name] = uiputfile(...
    {'*.svg','SVG file (*.svg)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Save as', 'Untitled.svg');

if isequal(file_name,0) || isequal(path_name,0)
   %disp('User pressed cancel')
    return
end


file_path = fullfile(path_name, file_name);

print(h_fig,'-dsvg','-painters',file_path);
%print -dsvg painters
 
%https://www.mathworks.com/matlabcentral/answers/98094-why-does-my-printed-figure-have-poor-resolution    
end