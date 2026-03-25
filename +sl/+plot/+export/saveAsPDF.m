function saveAsPDF(h_fig,varargin)
%X Save figure as PDF with prompt for filename
%
%   sl.plot.export.saveAsPDF(*h_fig,varargin)
%
%   Optional Inputs
%   ---------------
%   file_path 
%       Specify full path to file
%   format :
%       - "vector"
%       - "image"
%
%   Examples
%   --------
%   sl.plot.export.saveAsPDF(gcf,'file_path',file_path)
%
%   Improvements
%   ------------
%   1)DONE - update documentation Allow file specification as an input
%   2) Scale to print to a page size

in.format = 'vector';
in.file_path = '';
in = sl.in.processVarargin(in,varargin);

if nargin == 0 || isempty(h_fig)
   h_fig = gcf; 
end

if isempty(in.file_path)
    [file_name,path_name] = uiputfile(...
        {'*.pdf','PDF file (*.pdf)'; ...
            '*.*',  'All Files (*.*)'}, ...
            'Save as', 'Untitled.pdf');

    if isequal(file_name,0) || isequal(path_name,0)
       %disp('User pressed cancel')
        return
    end
    file_path = fullfile(path_name, file_name);
else
    file_path = in.file_path;
end


%Ideally we wouldn't change anything ...
s1 = get(h_fig);
%The idea is to reset to s1 after changing

h_fig.Units = 'inches';
h_fig.PaperSize = h_fig.Position(3:4);
h_fig.PaperUnits = 'inches';
h_fig.PaperPosition = h_fig.Position;
h_fig.PaperPositionMode = 'auto';

if isa(h_fig, 'matlab.ui.Figure')
    if in.format == "vector"
        exportgraphics(h_fig, file_path,'ContentType','vector','BackgroundColor',h_fig.Color);
    else 
        %Assuming image for now
        exportgraphics(h_fig, file_path,'ContentType','image','BackgroundColor',h_fig.Color);
    end
else
    %TODO: image format not yet support
    if verLessThan('matlab','9.11')
        %older than 2021b - use this
        if in.format == "vector"
            print(h_fig,'-dpdf','-painters',file_path); %#ok<PRTPT>
        else
            print(h_fig,'-dpdf','-opengl',file_path); %#ok<PRTOG>
        end
    else
        if in.format == "vector"
            print(h_fig,'-dpdf','-vector',file_path);
        else
            print(h_fig,'-dpdf','-image',file_path);    
        end
    end
end




end