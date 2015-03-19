function varargout = addLineLabel(h,text_strings,varargin)
%x Places a text label next to your data.  
%
%   htext = sl.plot.annotation.addLineLabel(h,textString,varargin)
%
%     This function provides an option between the legend and text or
%     annotation commands for labeling data that you plot.  Edward Tufte
%     says that data shouldn't stray far from its label, because the viewer
%     of a graph should not need to repeatedly move his or her eyes back
%     and forth between plotted data and the legend to connect the dots of
%     which data are which.  In this spirit, label can be used to place a
%     label directly on a plot close to the data it describes.
%
%   Inputs:
%   -------
%   h : line handles
%   text_strings : string or cellstr
%         
%   Optional Inputs:
%   ----------------
%   location : string (default 'left')
%       Options include, rows are grouped by funcitonality:
%       'left','west','leftmost','westmost', 
%       'right','east','rightmost','eastmost'
%       'top','north','topmost','northmost'
%       'bottom','south','southmost','bottommost'
%       'center','central','middle','centered','middlemost','centermost'
%
%       It is currently not possible to mix locations. Eventually I might
%       change this behavior so that something like 'left top' would be
%       supported.
%
%   follow_slope : logical (default false)
%       If true the text is angled to follow the gradient of the line.
%
%   text properties : Any additional text properties may also be specified
%   as property value pairs.
%
%   Examples:
%   ---------
%   1)
%   h(1) = line([0 0],[0 150]);
%   h(2) = line([10 10],[0 150]);
%   htext = sl.plot.annotation.addLineLabel(h,{'start' 'stop'},'follow_slope',true,'FontSize',18)


%TODO: I was having trouble with this on certain subplots. The text was not
%anchored where I wanted it to be ...

% Initial Author Info:
% Written by Chad A. Greene of the University of Texas at Austin and its 
% Institute for Geophysics, July 2014. 
% Fixed for R2014b in January 2015. 
% 
% See also annotation, text, and legend. 

% Initial input error checks: 
assert(all(ishandle(h)),'Unrecognized object handle.')
%??? What is this for????
assert(isempty(get(0,'children'))==0,'No current axes are open.') 
%assert(isnumeric(text_string)==0,'Label given by textString must be a string.') 
assert(nargin>=2,'Must input an object handle and corresponding label string.') 


in.location = 'left';
in.follow_slope = false;
[varargin,text_options] = sl.in.removeOptions(varargin,fieldnames(in));
in = sl.in.processVarargin(in,varargin);
   
if ischar(text_strings)
    text_strings = {text_strings};
end

h_temp = cell(1,length(h));
for iH = 1:length(h)
   h_temp{iH} = h__runPlotting(h(iH),text_strings{iH},in,text_options);
end

if nargout
    varargout{1} = [h_temp{:}];
end

end


function h_text = h__runPlotting(h,text_string,in,text_options)
%
%   The main function that adds the text according to specs.
%

color = get(h,'color'); 
xdata = get(h,'XData'); 
assert(isvector(xdata)==1,'Plotted data must be vector or scalar.') 
ydata = get(h,'YData'); 

gcax = get(gca,'xlim'); 
gcay = get(gca,'ylim'); 

if in.follow_slope
    pbp = kearneyplotboxpos(gca); % A modified version of Kelly Kearney's 
    %plotboxpos function is included as a subfunction below.  

    % slope is scaled because of axes and plot box may not be equal and square:
    gcaf = pbp(4)/pbp(3); 
    apparentTheta = atand(gcaf*gradient(ydata,xdata).*(gcax(2)-gcax(1))/(gcay(2)-gcay(1)));

end

% Find indices of data within figure window: 
ind = find(xdata>=gcax(1)&xdata<=gcax(2)&ydata>=gcay(1)&ydata<=gcay(2)); 

%TODO: This is a temp fix, ideally we would interpolate
if isempty(ind)
    ind = 1:length(xdata);
end

%This could be empty ...

%TODO: This is a bit misleading as to how the locations work
switch lower(in.location)
    case {'left','west','leftmost','westmost'}
        horizontalAlignment = 'left'; 
        verticalAlignment = 'bottom'; 
        x = min(xdata(ind));
        y = ydata(xdata==x);
        text_string = [' ',text_string]; 
        xi = xdata==x; 
        
    case {'right','east','rightmost','eastmost'}
        horizontalAlignment = 'right'; 
        verticalAlignment = 'bottom'; 
        x = max(xdata(ind)); 
        y = ydata(xdata==x);
        text_string = [text_string,' ']; 
        xi = xdata==x(1); 
        
    case {'top','north','topmost','northmost'}
        horizontalAlignment = 'left'; 
        verticalAlignment = 'top'; 
        y = max(ydata(ind));
        x = xdata(ydata==y);
        xi = xdata==x(1); 
        
    case {'bottom','south','southmost','bottommost'} 
        horizontalAlignment = 'left'; 
        verticalAlignment = 'bottom'; 
        y = min(ydata(ind));
        x = xdata(ydata==y);
        xi = xdata==x(1); 
        
    case {'center','central','middle','centered','middlemost','centermost'}
        horizontalAlignment = 'center'; 
        verticalAlignment = 'bottom'; 
        xi = round(mean(ind)); 
        if ~ismember(xi,ind)
            xi = find(ind<xi,1,'last'); 
        end
        x = xdata(xi); 
        y = ydata(xi);
        
        
    otherwise
        error('Unrecognized location string.') 
end
 
% Set rotation preferences: 
if in.follow_slope
    theta = apparentTheta(xi); 
else
    theta = 0; 
end


% Create the label: 
h_text = text(x(1),y(1),text_string,'color',color,...
    'horizontalalignment',horizontalAlignment,...
    'verticalalignment',verticalAlignment,...
    'rotation',theta(1)); 

% Add any user-defined preferences: 
if ~isempty(text_options)
    set(h_text,text_options{:});
end

end


function pos = kearneyplotboxpos(h)
%PLOTBOXPOS Returns the position of the plotted axis region. THIS IS A
%SLIGHTLY MODIFIED VERSION OF KELLY KEARNEY'S PLOTBOXPOS FUNCTION. 
%
% pos = plotboxpos(h)
%
% This function returns the position of the plotted region of an axis,
% which may differ from the actual axis position, depending on the axis
% limits, data aspect ratio, and plot box aspect ratio.  The position is
% returned in the same units as the those used to define the axis itself.
% This function can only be used for a 2D plot.  
%
% Input variables:
%
%   h:      axis handle of a 2D axis (if ommitted, current axis is used).
%
% Output variables:
%
%   pos:    four-element position vector, in same units as h

% Copyright 2010 Kelly Kearney

% Check input

if nargin < 1
    h = gca;
end

if ~ishandle(h) || ~strcmp(get(h,'type'), 'axes')
    error('Input must be an axis handle');
end

% Get position of axis in pixels

currunit = get(h, 'units');
set(h, 'units', 'pixels');
axisPos = get(h, 'Position');
set(h, 'Units', currunit);

% Calculate box position based axis limits and aspect ratios

darismanual  = strcmpi(get(h, 'DataAspectRatioMode'),    'manual');
pbarismanual = strcmpi(get(h, 'PlotBoxAspectRatioMode'), 'manual');

if ~darismanual && ~pbarismanual
    
    pos = axisPos;
    
else

    dx = diff(get(h, 'XLim'));
    dy = diff(get(h, 'YLim'));
    dar = get(h, 'DataAspectRatio');
    pbar = get(h, 'PlotBoxAspectRatio');

    limDarRatio = (dx/dar(1))/(dy/dar(2));
    pbarRatio = pbar(1)/pbar(2);
    axisRatio = axisPos(3)/axisPos(4);

    if darismanual
        if limDarRatio > axisRatio
            pos(1) = axisPos(1);
            pos(3) = axisPos(3);
            pos(4) = axisPos(3)/limDarRatio;
            pos(2) = (axisPos(4) - pos(4))/2 + axisPos(2);
        else
            pos(2) = axisPos(2);
            pos(4) = axisPos(4);
            pos(3) = axisPos(4) * limDarRatio;
            pos(1) = (axisPos(3) - pos(3))/2 + axisPos(1);
        end
    elseif pbarismanual
        if pbarRatio > axisRatio
            pos(1) = axisPos(1);
            pos(3) = axisPos(3);
            pos(4) = axisPos(3)/pbarRatio;
            pos(2) = (axisPos(4) - pos(4))/2 + axisPos(2);
        else
            pos(2) = axisPos(2);
            pos(4) = axisPos(4);
            pos(3) = axisPos(4) * pbarRatio;
            pos(1) = (axisPos(3) - pos(3))/2 + axisPos(1);
        end
    end
end

% Convert plot box position to the units used by the axis

temp = axes('Units', 'Pixels', 'Position', pos, 'Visible', 'off', 'parent', get(h, 'parent'));
% set(temp, 'Units', currunit); % <-This line commented-out by Chad Greene, specifically for label function.  
pos = get(temp, 'position');
delete(temp);
end
