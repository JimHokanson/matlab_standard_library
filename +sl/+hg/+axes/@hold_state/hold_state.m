classdef hold_state
    %
    %   Class:
    %   sl.hg.axes.hold_state
    %
    %   This class was created to enable reseting of a hold state
    %   to its current value after changing it.
    %
    %   Example:
    %   --------
    %   1)
    %
    %       s = sl.hg.axes.hold_state(gca);
    %       hold on
    %       plot(1:10)
    %       s.restore;
    %
    %   See Also:
    %   ---------
    %   hold
    %   ishold
    
    %http://www.mathworks.com/matlabcentral/newsreader/view_thread/321668
    
    properties
        h_axes
        status
        is_hold_on
        is_hold_off
        is_hold_all
    end
    
    methods
        function obj = hold_state(h_axes_input)
            %off
            %NextPlot - replace
            %on
            obj.h_axes = h_axes_input;
            next_plot_value = get(h_axes_input,'NextPlot');
            
            switch next_plot_value
                case 'replace'
                    obj.status = 'off';
                    obj.is_hold_on = false;
                    obj.is_hold_off = true;
                    obj.is_hold_all = false;
                case 'add'
                    hold_style = getappdata(h_axes_input,'PlotHoldStyle');
                    
                    %if graphicsversion(h_axes_input,'handlegraphics')
                    if verLessThan('matlab','8.4.0')
                                        
                        if ~islogical(hold_style)
                            error('Unexpected value of PlotHoldStyle')
                        elseif hold_style
                            obj.status = 'all';
                            obj.is_hold_on = false;
                            obj.is_hold_off = false;
                            obj.is_hold_all = true;
                        else
                            obj.status = 'on';
                            obj.is_hold_on = true;
                            obj.is_hold_off = false;
                            obj.is_hold_all = false;
                        end
                    
                    else
                       % :/ 
                       %hold on is now equivalent to the old hold all
                       %hold all should now longer be used ...
                       
                       obj.status = 'on';
                       obj.is_hold_on  = true;
                       obj.is_hold_off = false;
                       obj.is_hold_all = true;
                       
                    end
                    
                otherwise
                    error('Unrecognized "next_plot_value')
            end
        end
        function restore(obj)
            %
            %After changing the hold state, use this to reset it
            %back to what it is
            switch obj.status
                case 'on'
                    hold(obj.h_axes,'on')
                case 'off'
                    hold(obj.h_axes,'off')
                case 'all'
                    hold(obj.h_axes,'all')
                otherwise
                    error('Oops, Jim made a coding error')
            end
        end
    end
    
end

