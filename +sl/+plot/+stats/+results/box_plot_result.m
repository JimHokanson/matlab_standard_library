classdef box_plot_result < sl.obj.display_class
    %
    %   Class:
    %   sl.plot.stats.results.box_plot_result
    %
    %   See Also
    %   --------
    %   sl.plot.stats.boxPlot
    
    %   Methods
    %   
    
    properties
        h_axes
        entries
    end
    
    methods
        function obj = box_plot_result(h_axes,entries)
            %
            %   obj = sl.plot.stats.results.box_plot_result(entries)
            %
            %   See Also
            %   --------
            %   sl.plot.stats.results.box_plot_entry;
            obj.h_axes = h_axes;
            obj.entries = entries;
        end
        function setLabels(obj,labels,varargin)
           in.rotate = 0;
           in.add_n = false;
           in = sl.in.processVarargin(in,varargin);
           
           x_ticks = [obj.entries.x_center];
           
           if in.add_n
               d = [obj.entries.data];
               n_points = [d.n_data_points];
               labels = cellfun(@(x,y) sprintf('%s (n=%d)',x,y),labels,num2cell(n_points),'un',0);
           end
           
           set(obj.h_axes,'XTick',x_ticks,'XTickLabel',labels,'XTickLabelRotation',in.rotate);         
        end
        function changeBoxType(obj,varargin)
           obj.entries.changeBoxType(varargin{:}); 
        end
        function changeWidth(obj,varargin)
            %TODO: Add documentation
           obj.entries.changeWidth(varargin{:}); 
        end
        function renderScatterData(obj,varargin)
           %TODO: Add documentation
            obj.entries.renderScatterData(varargin{:}); 
        end
        function setHandlePropValue(obj,prop,varargin)
            obj.entries.setHandlePropValue(prop,varargin{:})
        end
    end
end

