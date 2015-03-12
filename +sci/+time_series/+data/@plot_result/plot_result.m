classdef plot_result
    %
    %   Class:
    %   sci.time_series.data.plot_result
    %
    %   This is the output from plot() in:
    %       sci.time_series.data
    %   
    %
    %   See Also:
    %   sci.time_series.data.plot
    %   
    
    properties
       render_objs %sl.plot.big_data.LinePlotReducer
       axes %axes graphics handle
    end
    
    methods
        function addComments(obj,varargin)
           in.axes_use = obj.axes;
           in = sl.in.processVarargin();
        end 
    end
    
end

