function updateDataTipPrecision(h_fig,format_str)
%
%
%   sl.plot.interactive.updateDataTipPrecision(h_fig,format_str)

dcm = datacursormode(h_fig);

set(dcm, 'UpdateFcn', @(obj,event_obj) myfunction(obj,event_obj,format_str),...
    'Enable', 'on');

end

%This was copied from Matlab 2018b when I opted to edit the callback

function output_txt = myfunction(obj,event_obj,format_str)
% Display data cursor position in a data tip
% obj          Currently not used
% event_obj    Handle to event object
% output_txt   Data tip text, returned as a character vector or a cell array of character vectors

pos = event_obj.Position;


%********* Define the content of the data tip here *********%

% Display the x and y values:
output_txt = {['X',formatValue(pos(1),event_obj,format_str)],...
              ['Y',formatValue(pos(2),event_obj,format_str)]};
%***********************************************************%


% If there is a z value, display it:
if length(pos) > 2
    output_txt{end+1} = ['Z',formatValue(pos(3),event_obj,format_str)];
end

end

%***********************************************************%

function formattedValue = formatValue(value,event_obj,format_str)
% If you do not want TeX formatting in the data tip, uncomment the line below.
% event_obj.Interpreter = 'none';
if strcmpi(event_obj.Interpreter,'tex')
    valueFormat = ' \color[rgb]{0 0.5 1}\bf';
    removeValueFormat = '\color[rgb]{.15 .15 .15}\rm';
else
    valueFormat = ': ';
    removeValueFormat = '';
end
formattedValue = [valueFormat sprintf(format_str,value) removeValueFormat];

end
