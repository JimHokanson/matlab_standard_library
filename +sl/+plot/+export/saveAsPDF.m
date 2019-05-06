function saveAsPDF(h_fig)
%X Save figure as PDF with prompt for filename
%
%   sl.plot.export.saveAsPDF(*h_fig)
%
%   Improvements
%   ------------
%   1) Allow file specification as an input
%   2) Scale to print to a page size

if nargin == 0
   h_fig = gcf; 
end

[file_name,path_name] = uiputfile(...
    {'*.pdf','PDF file (*.pdf)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Save as', 'Untitled.pdf');

if isequal(file_name,0) || isequal(path_name,0)
   %disp('User pressed cancel')
    return
end


%Ideally we wouldn't change anything ...

s1 = get(h_fig);

h_fig.Units = 'inches';
h_fig.PaperSize = h_fig.Position(3:4);
h_fig.PaperUnits = 'inches';
h_fig.PaperPosition = h_fig.Position;
h_fig.PaperPositionMode = 'auto';
%TODO: reset based on s1



file_path = fullfile(path_name, file_name);

print(h_fig,'-dpdf','-painters',file_path);
 
end