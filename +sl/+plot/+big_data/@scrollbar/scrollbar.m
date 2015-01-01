classdef scrollbar < handle
    %
    %   Class:
    %   sl.plot.big_data.scrollbar
    %
    %   See Also:
    %   sl.plot.big_data.LinePlotReducer
    
    %{
        close all
        n = 1e7 + randi(1000);                          % Number of samples
        t = sort(100*rand(1, n));                       % Non-uniform sampling
        x = [sin(0.10 * t) + 0.05 * randn(1, n); ...
            cos(0.43 * t) + 0.001 * t .* randn(1, n); ...
            round(mod(t/10, 5))];
        x(:, t > 40 & t < 50) = 0;                      % Drop a section of data.
        x(randi(numel(x), 1, 20)) = randn(1, 20);       % Emulate spikes.

        wtf = sl.plot.big_data.LinePlotReducer(t,x);
        wtf.renderData;   
        s = sl.plot.big_data.scrollbar(wtf)
    
       %Testing
    s.h_slider.slider_width_pct = 0.4
    
    %}
    
    properties
       h_axes
       h_slider
    end
    
    methods
        function obj = scrollbar(lpr)
            %
            %   Inputs:
            %   -------
            %   lpr : sl.plot.big_data.LinePlotReducer
            
           %A scrollbar normally manipulates the xlim of the figure
            
           INITIAL_WIDTH = 0.5; %Pct
           
           DEFAULT_POSITION = [NaN 0.02 NaN 0.03];
           
           %TODO: Set extents based on figure extents (left and right)
           
           %Starting points:
           %----------------
           %1) How far to zoom in
           %2) Where to start
                      
           xlim_temp = lpr.x_lim_original;
           %TODO: Do we want to round based on step size???
           
           obj.h_axes = lpr.h_axes;
           axes_extents = get(obj.h_axes,'position');
           DEFAULT_POSITION(1) = axes_extents(1);
           DEFAULT_POSITION(3) = axes_extents(3);
           %TODO: Show window width and limits somewhere ...
           
           %set(obj.h_axes,'xlim',
           
           obj.h_slider = sl.gui.scrollbar(lpr.h_figure,...
                'units','normalized',...
                'position',DEFAULT_POSITION,...
                'Value',0.5*diff(xlim_temp) + xlim_temp(1),...
                'min',xlim_temp(1),...
                'max',xlim_temp(2),...
                'callback',@(~,~)obj.CB_sliderValueChanged()); 
            
        end
        function CB_sliderValueChanged(obj)
           disp('callback ran') 
        end
    end
    
end

%{
%SliderStep
[0.01 0.10] (default) | [minorstep majorstep] Slider step size, specified
as the array, [minorstep majorstep]. This property controls the magnitude
of the slider value change when the user clicks the arrow keys or the
slider trough (slider channel):

The slider Value property increases or decreases by the value of minorstep
when the user presses an arrow key.

The slider Value property increases or decreases by the value of majorstep
when the user clicks the slider trough.

Both minorstep and majorstep must be greater than 1e-6, and minorstep must
be less than or equal to minorstep.

The actual step size depends on the SliderStep value and the slider range
(Max – Min). For example, a slider having SliderStep value of [0.01 0.10],
Max value of 1, and Min of 0 provides a 1% change when the user presses an
arrow key and a 10% change when the user clicks in the trough.

As majorstep increases, the slider thumb indicator grows longer. When
majorstep is equal to 1, the thumb indicator is half as long as the trough.
The size is larger for majorstep values greater than 1.

Example: [.5 1]

http://undocumentedmatlab.com/blog/customizing-listbox-editbox-scrollbars

http://undocumentedmatlab.com/blog/continuous-slider-callback

%findjobj
%SliderPeer$MLScrollBar
%getVisibleRect => Rectangle

%}
