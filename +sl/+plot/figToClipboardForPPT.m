function figToClipboardForPPT(h_fig,varargin)
%
%   sl.plot.figToClipboardForPPT(h_fig,varargin)
%
%   Issue: https://github.com/JimHokanson/matlab_standard_library/issues/24
%
%   Optional Inputs
%   ---------------
%   ratio : numeric, default 4/3
%       single element: ratio
%       double element: [width height]
%       -  4/3
%       - 16/9
%       - 19/9 - has a nice header for 16/9
%       - 1 - good for 1/2 of 16/9
%   size_rule : string
%       - 'grow' - Grow to acheive the ratio
%       - 'shrink' - Shrink to acheive the ratio
%       - 'hfixed' - Keep Height fixed - adjust width
%       - 'wfixed' - Keep Width fixed - adjust height
%
%   
%   Examples
%   --------
%   sl.plot.figToClipboardForPPT(gcf,'ratio',16/9)
%
%   Improvements
%   ------------
%   - allow not growing past the screen size
%
%   See Also
%   --------
%   sl.hg.figure.maximize
%   sl.plot.uimenu.addScreenshotOption

%sl.os.screenCapture(h_fig)
%setpixelposition

in.fit_rule = 'hshrink';
%wshrink

in.maximize_first = false;
in.keep_in_screen = true;
%This should basically always be true otherwise the screen capture doesn't
%seem to work

in.size = 4/3;
in.size_rule = 'grow';
% 'grow'   - grow whatever needs to grow
% 'shrink'
% 'hfixed'
% 'wfixed'

in.verbose = 'false';
in = sl.in.processVarargin(in,varargin);

%How do we know what monitor we are on?

%Algorithm????
%--------------------------------------------
%If not enlarge - choose 

%{
fh = @sl.plot.figToClipboardForPPT;

p1 = [10 10 400 500];

clf; plot(1:10); setpixelposition(gcf,p1);
fh(gcf,'size_rule','grow');
fh(gcf,'size_rule','shrink');
fh(gcf,'size_rule','hfixed');
fh(gcf,'size_rule','wfixed');

clf; plot(1:10); setpixelposition(gcf,p1);
fh(gcf,'size',16/9)


%Overflow
clf; plot(1:10); setpixelposition(gcf,[10 10 10000 5000]);
fh(gcf,'size',16/9)
fh(gcf,'size',19/9)


%}

if in.maximize_first
	sl.hg.figure.maximize();
end

%p = sl.hg.figure.getPixelPosition(h_fig);

p = getpixelposition(h_fig);

%Note, this moves to a particular monitor which we may not want
%p(1:2) = 1;

if length(in.size) == 2
    p(3:4) = in.size;
    setpixelposition(h_fig,p);
else

    width = p(3);
    height = p(4);
    
    start_height = height;
    start_width = width;

    current_ratio = width/height;
    target_ratio = in.size;
    
    %small ratio - decrease height, increase width
    %large ratio - increase height, decrease width
    
    
    %ratio = width/height;
    %
    %width = height*ratio
    %height = width/ratio
    
    if current_ratio == target_ratio
        %Great!
    elseif current_ratio < target_ratio
        %need to decrease height, increase width
        switch in.size_rule
            case {'grow' 'hfixed'}
                width = height*target_ratio;
            case {'shrink' 'wfixed'}
                height = width/target_ratio;
        end
    else
        %increase height, decrease width
        switch in.size_rule
            case {'grow' 'wfixed'}
                height = width/target_ratio;
            case {'shrink' 'hfixed'}
                width = height*target_ratio;
        end        
    end
    
    p(3) = width;
    p(4) = height;
    
    setpixelposition(h_fig,p);
    
    if in.keep_in_screen
        mmi = sl.hg.figure.monitor_mapping_info(h_fig);
        if ~mmi.figureCompletelyOnAScreen()
            main_fig_id = mmi.getScreenHoldingFigure();
            %Move to ll of main figure
            ss = mmi.screen_sizes(main_fig_id);
            p(1) = ss.left;
            p(2) = ss.bottom;
           
            if width > ss.width || height > ss.height
                %Shrink until it fits
                %ratio is currently correct
                %
                %Need to shrink by whichever shrink factor
                %is larger, that needed to fit the width or that needed to 
                %fit the height
                
                r_height = height/ss.height;
                r_width = width/ss.width;
                
                if r_height > r_width
                    height = height/r_height;
                    width = width/r_height;
                else
                    height = height/r_width;
                    width = width/r_width;
                end
                p(3) = width;
                p(4) = height;
                
            end
            setpixelposition(h_fig,p);
        end
    end
    
    %setpixelposition(h_fig,p);
    
    if in.verbose
        fprintf('h: %0.1f, w: %0.1f, h2: %0.1f, w2: %0.1f\n',...
            start_height,start_width,height,width);    
    end

end

sl.os.screenCapture(h_fig);

if in.verbose
    fprintf('Figure copied to clipboard\n');
end

end