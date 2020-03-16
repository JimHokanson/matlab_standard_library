classdef box_plot_designs < handle
    %
    %   Class:
    %   sl.plot.stats.results.box_plot_designs
    %
    %   See Also
    %   --------
    %   sl.plot.stats.results.box_plot_result
    
    properties
        r_internal % sl.plot.stats.results.box_plot_result
    end
    
    methods
        function obj = box_plot_designs(r)
            %
            %   obj = sl.plot.stats.results.box_plot_designs(r)
            
            obj.r_internal = r;
        end
        function jim_std(obj,varargin)
            
            in.pct_scatter_width = 0.5;
            in = sl.in.processVarargin(in,varargin);
            
            r = obj.r_internal;
            
          	r.changeBoxType('box')

            r.setHandlePropValue('h_box','FaceColor',[0.7 0.7 0.7],'EdgeColor','none')
            r.setHandlePropValue('h_median','Color','k','Linewidth',1.5)
            r.setHandlePropValue('h_outliers','MarkerSize',12,'MarkerEdgeColor','k')


            r.setWidth(0.7);
            r.renderScatterData('pct_width',in.pct_scatter_width);

            h_axes = r.h_axes;
            set(h_axes,'FontSize',16,'FontName','Arial')
%             h_axes.YLim(1) = 0;
        end

    end
end

