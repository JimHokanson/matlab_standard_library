function hideIcons(h_fig,varargin)
%
%   sl.hg.figure.hideIcons(h_fig,varargin)
%
%   sl.hg.figure.hideIcons(h_graphics,varargin)
%
%   Hides figure icons such as the save of new file icons. By default all
%   Matlab icons are hidden. Options to bypass hiding everything are not
%   yet implemented ...
%
%   Inputs
%   ------
%   h_fig : matlab.ui.Figure
%   h_graphics : matlab.graphics.Graphics
%       Results of findall(h_fig) or some other approach for finding 
%       relevant handles in the figure
%
%   Optional Inputs
%   ---------------
%   set : string
%       - 'jim_2d' - keeps only zoom in/out, pan, and data cursor

in.set = '';
in.hide = {};
in.keep = {};
in = sl.in.processVarargin(in,varargin);

%This is a work in progress ...
ALL_MATLAB_ICON_TAGS = {'Standard.NewFigure','Standard.FileOpen',...
    'Standard.SaveFigure','Standard.PrintFigure','DataManager.Linking',...
    'Exploration.ZoomIn','Exploration.ZoomOut','Exploration.Pan',...
    'Exploration.Rotate','Exploration.DataCursor','Exploration.Brushing',...
    'Annotation.InsertColorbar','Annotation.InsertLegend',...
    'Standard.EditPlot','Standard.OpenInspector'};
    ...
    
% 
% 
% 'New Figure','Open File','Save Figure','Print Figure',...
%     'Link Plot','Zoom In','Zoom Out','Pan','Rotate 3D','Brush/Select Data'
%     'Edit Plot','Insert Legend',...
%     'Brush/Select Data','Rotate 3D','Insert Colorbar','Open Property Inspector'};
% 
%   PushTool              (Standard.OpenInspector)
%   ToggleTool            (Standard.EditPlot)
%   ToggleTool            (Annotation.InsertLegend)
%   ToggleTool            (Annotation.InsertColorbar)
%   ToggleSplitTool       (Exploration.Brushing)
%   ToggleTool            (Exploration.DataCursor)
%   ToggleTool            (Exploration.Rotate)
%   ToggleTool            (Exploration.Pan)
%   ToggleTool            (Exploration.ZoomOut)
%   ToggleTool            (Exploration.ZoomIn)
%   ToggleTool            (DataManager.Linking)
%   PushTool              (Standard.PrintFigure)
%   PushTool              (Standard.SaveFigure)
%   PushTool              (Standard.FileOpen)
%   PushTool              (Standard.NewFigure)

%something like this for name matching ... (cast to lowercase)
% s = struct;
% s.help = 'figMenuHelp';
% s.figmenuhelp = 'figMenuHelp';

if ~isempty(in.set)
    switch lower(in.set)
        case 'jim_2d'
            tags_to_hide = ALL_MATLAB_ICON_TAGS;
            tags_to_hide(ismember(tags_to_hide,...
                {'Exploration.ZoomIn','Exploration.ZoomOut',...
                'Exploration.Pan','Exploration.DataCursor'})) = [];
        otherwise
            error('set option not recognized')
    end
elseif isempty(in.hide) && isempty(in.keep)
	tags_to_hide = ALL_MATLAB_ICON_TAGS;
else
	error('Not yet implemented') 
end

if isa(h_fig,'matlab.ui.Figure')
    a = findall(h_fig);
else
    a = h_fig;
end
%Note, I'm not clear on the parent object of all h_graphics
%that would allow us to ensure we have something valid

%Note, we could also check for the new figures and throw an error (or build
%in support for those new figures (although those don't have menus by
%default ...)

for i = 1:length(tags_to_hide)
    cur_tag = tags_to_hide{i};
    b = findall(a,'Tag',cur_tag);
    if ~isempty(b)
        set(b,'Visible','Off')
    end
end
end
