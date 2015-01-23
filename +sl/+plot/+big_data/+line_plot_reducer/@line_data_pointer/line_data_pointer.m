classdef (Hidden) line_data_pointer
    %
    %   Class:
    %
    %   sl.plot.big_data.line_plot_reducer.line_data_pointer
    
    properties
       line_plot_reducer_ref
       group_I
       line_I
    end
    
    methods
        function obj = line_data_pointer(plot_ref,group_I,line_I)
            %
            %   obj = sl.plot.big_data.line_plot_reducer.line_data_pointer(plot_ref,group_I,line_I)
           obj.line_plot_reducer_ref = plot_ref;
           obj.group_I = group_I;
           obj.line_I = line_I;
        end
        function y_data = getYData(obj)
           %
           %
           %    Some thoughts:
           %    1) We might want to have a method in LinePlotReducer
           %    2) If we ever add or delete lines and shift y, the indices
           %    could be off
           
           y_data = obj.line_plot_reducer_ref.y{obj.group_I}(:,obj.line_I);
        end
    end
    
end

