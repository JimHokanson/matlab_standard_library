classdef box_plot_result < sl.obj.display_class
    %
    %   Class:
    %   sl.plot.stats.results.box_plot_result
    %
    %   This class is returned from sl.plot.stats.boxPlot.
    %
    %
    %   See Also
    %   --------
    %   sl.plot.stats.boxPlot
    
    %   Methods
    %
    
    properties
        h_axes  % Axes
        entries % [sl.plot.stats.results.box_plot_entry]
        
        design  %sl.plot.stats.results.box_plot_designs
        %Can be called to create standard visualizations ...
        %   r.design.jim_std();
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
            obj.design = sl.plot.stats.results.box_plot_designs(obj);
        end
        function addData(obj,new_data,varargin)
            %x Add more boxes to the plot
            %
            %   addData(obj,new_data,varargin)
            %
            %   Inputs
            %   ------
            %   new_data : [samples x group]
            %
            %   Optional Inputs
            %   ---------------
            %   TODO
            %
            %   Note this can be called by sl.plot.stats.boxPlot
            %   to handle cells as inputs (creates recursive loop)
            %
            %   Written to facilitate adding data from different
            %   sets of experiments
            
            %Most likely need to redo the ylimits as well ...
            
            in.add_n = true;
            in.group_id = 1;
            in.x = [];
            in.labels = {};
            [in,varargin] = sl.in.processVararginWithRemainder(in,varargin);
            
            
            temp_e = obj.entries;
            x_current = [temp_e.x_center];
            
            if isempty(in.x)
                if length(x_current) == 1
                    x2 = 2*x_current;
                else
                    n_new = size(new_data,2);
                    %Assuming not 0 length ...
                    dt = x_current(2)-x_current(1);
                    start_x = x_current(end)+dt;
                    end_x = x_current(end)+n_new*dt;
                    x2 = start_x:dt:end_x;
                end
            else
               x2 = in.new_x; 
            end
            
            %TODO:
            hold on
            %reset this????
            set(obj.h_axes,'YLimMode','auto','XLimMode','auto')
            %TODO: Might need to ensure same axes by inputting to fcn
            temp_result = sl.plot.stats.boxPlot(new_data,varargin{:},...
                'group_id',in.group_id,'labels',in.labels,...
                'add_n',in.add_n,'x',x2);
            set(obj.h_axes,'YLimMode','auto','XLimMode','auto')
            hold off
            
            %boxplot removes labels when calling, so readd them
            obj.entries.readdLabels();

            %Currently entries are the only "new" data that we hold onto
            %from the new result
            obj.entries = [obj.entries temp_result.entries];
        end
        function setLabels(obj,labels,varargin)
            %x Set labels for each box ...
            %
            %   setLabels(obj,labels,varargin)
            %
            %   Optional Inputs
            %   ---------------
            %   rotate : default 0 (degrees)
            %       Amount to rotate label text by. 0 indicates no
            %       rotation (i.e. normal horizontal text). 90 would
            %       indicate vertical text.
            %   add_n : default false
            %       If true, adds to the label how many points contributed
            %       to the specified box plot.
            %
            %   Example
            %   -------
            %   r1.setLabels({'10 Hz, 1T'},'add_n',true);
            
            in.other_result = [];
            in.rotate = 0;
            in.add_n = false;
            in = sl.in.processVarargin(in,varargin);
            
            %Why aren't we calling the entris function???
            
            x_ticks = [obj.entries.x_center];
            
            
            if in.add_n
                d = [obj.entries.data];
                n_points = [d.n_data_points];
                if length(labels) ~= length(n_points)
                    error('Mismatch in # of labels: %d vs # of bars %d',length(labels),length(n_points))
                end
                labels2 = cellfun(@(x,y) sprintf('%s (n=%d)',x,y),labels,num2cell(n_points),'un',0);
                labels = labels2;
            end
            
            for i = 1:length(labels)
               obj.entries(i).x_label = labels{i}; 
            end
            
            if ~isempty(in.other_result)
                obj2 = in.other_result;
            	x_ticks2 = [obj2.entries.x_center];
                labels2 = {obj2.entries.x_label};
                merged_labels = [labels labels2];
                [x_ticks,I] = sort([x_ticks x_ticks2]);
                labels = merged_labels(I);
            end
            
            set(obj.h_axes,'XTick',x_ticks,'XTickLabel',labels,'XTickLabelRotation',in.rotate);
        end
        function changeBoxType(obj,varargin)
            %Change style of the box plot
            %
            %   changeBoxType(obj,varargin)
            %
            %
            obj.entries.changeBoxType(varargin{:});
        end
        function setXCenters(obj,x_locations,varargin)
            obj.entries.setXCenter(x_locations,varargin{:});
        end
        function setWidth(obj,varargin)
            %X Change the width of all components in box based on width
            %
            %   setWidth(obj,varargin)
            %
            %   Individual componentts are not set to this width but rather
            %   scaled based on how this width relates to the current box
            %   width.
            %
            %   See Also
            %   --------
            %   
            
            obj.entries.setWidth(varargin{:});
        end
        function renderScatterData(obj,varargin)
            %TODO: Add documentation
            obj.entries.renderScatterData(varargin{:});
        end
        function setHandlePropValue(obj,prop,varargin)
            in.I = 1:length(obj.entries);
            [in,varargin] = sl.in.processVararginWithRemainder(in,varargin);
            
            obj.entries(in.I).setHandlePropValue(prop,varargin{:}) 
        end
    end
end

