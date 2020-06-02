function varargout = screenCapture(h,varargin)
%X 
%   
%   s = sl.os.screenCapture(h,varargin)
%
%   Interactive - NYI - i.e. select ROI
%   sl.os.screencapture([],varargin)    
%
%   Outputs
%   -------
%   s : 
%
%   Inputs
%   ------
%   h : Figure or others
%       Only Figure is implemented. Eventually we could support other types
%       of screen-grab requests.
%
%   Optional Inputs
%   ---------------
%   fig_crop : NYI
%
%   Examples
%   --------
%   1) Captures to clipboard
%   sl.os.screenCapture(gcf)
%
%   2) Capture to memory
%   s = sl.os.screenCapture(gcf)
%
%   Improvements
%   ------------
%   1) Support interactive

in.fig_crop = false; %NYI - if true, eat
%into the figure in all directions when all the same color ...
%=> i.e. remove all the grey
in.white_fig = false; %NYI - if true make the background white
%temporarily for screen capture ...
in.save_path = '';
in.crop_toolbar = true;
in = sl.in.processVarargin(in,varargin);

in.use_clipboard = isempty(in.save_path) && nargout == 0;

if ~isempty(in.save_path)
    %mwrite(imgData,'out.png')
    error('Not yet implemented')
end

s = struct;

if isempty(h)
    %interactive
    error('Not yet implemented')
elseif isa(h,'matlab.ui.Figure')
    s = h__getFigurePosition(h,in.crop_toolbar,s);
else
    error('Not yet implented')
end

%TODO: Need to ensure figure is visible and up to date
image_data = h__getImageData(s.p);
s.image_data = image_data;
if in.use_clipboard
    h__imageToClipboard(image_data);
end

if nargout
    varargout{1} = s;
end

end
function h__imageToClipboard(image_data)
    %
    %   Borrowed from  Yair Altman's screencapture submission:
    %   https://www.mathworks.com/matlabcentral/fileexchange/24323-screencapture-get-a-screen-capture-of-a-figure-frame-or-component
    %
    %   Requires JAVA code in this directory that converts data
    %   to a clipboard
    
    % Import necessary Java classes
%     import java.awt.image.BufferedImage
%     import java.awt.datatransfer.DataFlavor


    %Add the necessary Java class (ImageSelection) to the Java classpath
    %---------------------------------------------------------------------
    %This is needed to allow going from a matrix to a clipboard image
    if ~exist('ImageSelection', 'class')
        % Obtain the directory of the executable (or of the M-file if not deployed) 
        %javaaddpath(fileparts(which(mfilename)), '-end');
        if isdeployed % Stand-alone mode. 
            [status, result] = system('path');  %#ok<ASGLU>
            MatLabFilePath = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
        else % MATLAB mode. 
            MatLabFilePath = fileparts(mfilename('fullpath')); 
        end 
        javaaddpath(MatLabFilePath, '-end'); 
    end

    cb = java.awt.Toolkit.getDefaultToolkit.getSystemClipboard;
    
    % Get image size
    ht = size(image_data, 1);
    wd = size(image_data, 2);
    
    % Convert to Blue-Green-Red format
    image_data = image_data(:, :, [3 2 1]);
    
    % Convert to 3xWxH format
    image_data = permute(image_data, [3, 2, 1]);
    
    % Append Alpha data (not used)
    image_data = cat(1, image_data, 255*ones(1, wd, ht, 'uint8'));
    
    % Create image buffer
    imBuffer = java.awt.image.BufferedImage(...
        wd, ht, java.awt.image.BufferedImage.TYPE_INT_RGB);
    imBuffer.setRGB(0, 0, wd, ht, typecast(image_data(:), 'int32'), 0, wd);
    
    % Create ImageSelection object
    %    % custom java class
    imSelection = ImageSelection(imBuffer);
    
    % Set clipboard content to the image
    cb.setContents(imSelection, []);
end  %imclipboard


function RGB = h__getImageData(p)
%https://www.mathworks.com/matlabcentral/answers/379379-what-is-the-fastest-way-to-export-a-figure-in-matlab

pos = round(p);
robot  = java.awt.Robot;

rect   = java.awt.Rectangle(pos(1), pos(2), pos(3), pos(4));
jImage = robot.createScreenCapture(rect);
h      = jImage.getHeight;
w      = jImage.getWidth;
pixel  = reshape(typecast(jImage.getData.getDataStorage, 'uint8'), 4, w, h);
RGB = cat(3, transpose(reshape(pixel(3, :, :), w, h)), ...
             transpose(reshape(pixel(2, :, :), w, h)), ...
             transpose(reshape(pixel(1, :, :), w, h)));
end

function s = h__getFigurePosition(h_fig,crop_toolbar,s)
%
%   s = h__getFigurePosition(h_fig,crop_toolbar,s)
%
%   Outputs
%   -------
%   s : struct
%       .fig_position - 4 element vector [left, bottom, width, height]
%       .p - also of p
%
%   Inputs
%   ------
%   h_fig
%   crop_toolbar : boolean
%       Whether or not to remove toolbar when calculating 

    keep_toolbar = ~crop_toolbar;

    %TODO: Docked is not ok ...
    
    screen = get(groot, 'ScreenSize');
    
 	%Figure must be visible
    figure(h_fig);
    
	%https://www.mathworks.com/matlabcentral/answers/432320-getpixelposition-vs-outerposition-of-figure
    %Throwaway figure for correction factor ...
    
    
    %Equivalent to Position
    p = getpixelposition(h_fig);
    
    %For debugging ...
    s.fig_position = p;
    
    if keep_toolbar
        %This is only for getting the toolbar height        
        if strcmp(h_fig.Units,'pixels')
            p2 = h_fig.OuterPosition;
            h_diff = p2(4)-p(4);
        else
            %Change units ...
            old_units = h_fig.Units;
            h_fig.Units = 'pixels';
            p2 = h_fig.OuterPosition;
            h_fig.Units = old_units;
            
%             fig_temp = figure('Visible','on','Units','pixels',...
%                 'Toolbar',h_fig.ToolBar,'MenuBar',h_fig.MenuBar,'Position',p);
%             plot(1:10)
%             drawnow()
%             pause(0.1)
%             %Not sure why this matters but it appears to ...
%             p1 = fig_temp.Position;
%             p2 = fig_temp.OuterPosition;
%             close(fig_temp);
%             pause(0.4)

            h_diff = p2(4)-p(4);
        end
    
    end
    
    %I'm not sure where this comes from ...
    %Came from trial and error, most likely not generalizable
    %On my machine the borders are 8 pixels ...
    
    %Note: OuterPosition 
    
    if crop_toolbar        
        LEFT_SHIFT = -1; %1 to 0 based????
        WIDTH_SHIFT = 1; %Not sure why this is needed ...
        
        UP_SHIFT = 0;
        HEIGHT_SHIFT = 1;
    else
        %For toolbar being kept
        LEFT_SHIFT = -1;
        WIDTH_SHIFT = 1;
        
        %TODO: Test this on someone else's machine ...
        UP_SHIFT = -10;
        HEIGHT_SHIFT = -9;
    end

    p(1) = p(1) + LEFT_SHIFT;
    p(2) = p(2) + UP_SHIFT;
    %Java needs 0 at top, not at bottom so flip y
    %This flip needs to be done before updating p(4)
    p(2) = screen(4) - p(4) - p(2);
    p(3) = p(3) + WIDTH_SHIFT;
    p(4) = p(4) + HEIGHT_SHIFT;
    
    if ~crop_toolbar
        p(2) = p(2) - h_diff;
        p(4) = p(4) + h_diff; 
    end

    s.p = p;    
    
end