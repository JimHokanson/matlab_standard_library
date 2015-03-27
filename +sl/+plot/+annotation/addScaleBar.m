function addScaleBar(axes_h,start_xy,y_height,x_width,y_label,x_label,varargin)
%
%   sl.plot.annotation.addScaleBar(axes_h,start_xy,y_height,x_length,y_label,x_label,varargin)
%
%   Inputs:
%   -------
%   start_xy
%   
%   Optional Inputs:
%   ----------------
%   remove_x_ticks : logical (defaut true)
%   remove_y_ticks : logical (default true)
%   no_y_scale : logical (default false)
%   no_x_scale : logical (default false)
%   line_specs :
%   text_specs :
%   y_label_shift_pct : 
%
%   Example:
%   --------
%   1)
%   sl.plot.annotation.addScaleBar(gca,start_xy,y_height,x_length,y_label,x_label,varargin)

%There's a lot we could customize here ...

in.remove_x_ticks = true;
in.remove_y_ticks = true;
in.no_y_scale = false;
in.no_x_scale = false;
in.line_specs = {'Color','k','Linewidth',2};

%TODO: Can we base this off of the figure ...
in.text_specs = {'FontSize',16};
in.y_label_shift_pct = 0.05; %TODO: Document this ...
in = sl.in.processVarargin(in,varargin);

if in.no_x_scale
    in.remove_x_ticks = false;
end
if in.no_y_scale
    in.remove_y_ticks = false;
end

if in.remove_x_ticks
    set(axes_h,'XTick',[],'XTickLabel',{})
end

if in.remove_y_ticks
    set(axes_h,'YTick',[],'YTickLabel',{})
end


%
%        x1,y1
%          |
%          |
% y_label  |
%          |
%          |
%        x2,y2  ------- x3,y3
%               x_label
%           


x = zeros(1,3);

x(1) = start_xy(1);
x(2) = start_xy(1);
x(3) = start_xy(1)+x_width;

y = zeros(1,3);
y(1) = start_xy(2)+y_height;
y(2) = start_xy(2);
y(3) = start_xy(2);

if in.no_y_scale
    x(1) = [];
    y(1) = [];
end

if in.no_x_scale
   x(end) = [];
   y(end) = [];
end

%TODO: Pas
line(x,y,'Parent',axes_h,in.line_specs{:});

%TODO: We could add on options

y_label_pos_y = y(2) + 0.5*y_height;
y_label_pos_x = x(1);

x_label_pos_y = y(2);
x_label_pos_x = x(2) + 0.5*x_width;

final_y_label = sprintf('%0g %s',y_height,y_label);
final_x_label = sprintf('%0g %s',x_width,x_label);

x_lim_temp = get(axes_h,'XLim');
x_width    = x_lim_temp(2) - x_lim_temp(1);

if ~in.no_y_scale
    text(y_label_pos_x-in.y_label_shift_pct*x_width,y_label_pos_y,final_y_label,...
        'Parent',axes_h,'HorizontalAlignment','right',in.text_specs{:});
end

if ~in.no_x_scale
text(x_label_pos_x,x_label_pos_y,final_x_label,'Parent',axes_h,...
    'VerticalAlignment','top','HorizontalAlignment','center',in.text_specs{:});
end



%Text Properties:
%----------------
%     'Color'
%     'Position'
%     'String'
%     'Interpreter'
%     'Extent'
%     'Rotation'
%     'FontName'
%     'FontUnits'
%     'FontSize'
%     'FontAngle'
%     'FontWeight'
%     'HorizontalAlignment'
%     'VerticalAlignment'
%     'EdgeColor'
%     'LineStyle'
%     'LineWidth'
%     'BackgroundColor'
%     'Margin'
%     'Editing'
%     'Clipping'
%     'FontSmoothing'
%     'Units'
%     'UIContextMenu'
%     'BusyAction'
%     'BeingDeleted'
%     'Interruptible'
%     'CreateFcn'
%     'DeleteFcn'
%     'ButtonDownFcn'
%     'Type'
%     'Tag'
%     'UserData'
%     'Selected'
%     'SelectionHighlight'
%     'HitTest'
%     'PickableParts'
%     'Annotation'
%     'DisplayName'
%     'Children'
%     'Parent'
%     'Visible'
%     'HandleVisibility'
