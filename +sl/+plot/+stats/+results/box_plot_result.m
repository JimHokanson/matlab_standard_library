classdef box_plot_result < handle
    %
    %   Class:
    %   sl.plot.stats.results.box_plot_result
    
    %   Methods
    %   
    
    properties
        entries
    end
    
    methods
        function obj = box_plot_result(entries)
            %
            %   obj = sl.plot.stats.results.box_plot_result(entries)
            %
            %   See Also
            %   --------
            %   sl.plot.stats.results.box_plot_entry;
            obj.entries = entries;
        end
        function setHandlePropValue(obj,prop,varargin)
            obj.entries.setHandlePropValue(prop,varargin{:})
        end
    end
end

