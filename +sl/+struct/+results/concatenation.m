classdef concatenation
    %
    %   Class:
    %   sl.struct.results.concatenation
    %
    %   See Also
    %   --------
    %   sl.struct.concatenate
    
    properties
        raw_output = 'call getRawOutput()'
        raw_table  = 'call getRawTable()'
        unique_field_names
    end
    
    
    properties (Dependent)
        missing_per_field
    end
    
    properties (Hidden)
        raw_cell
        is_missing
    end
    
    methods
        function obj = concatenation(unique_field_names,raw_cell,is_missing,options)
            %
            %
            %   See Also
            %   --------
            %   output = sl.struct.concatenate(varargin);
            
            obj.unique_field_names = unique_field_names;
            obj.raw_cell = raw_cell;
            obj.is_missing = is_missing;
            %TODO: Use options from concatenate
        end
        function output = getRawOutput(obj)
            output = cell2struct(obj.raw_cell,obj.unique_field_names,1);
        end
        function output = getRawTable(obj)
            temp = obj.getRawOutput;
            output = struct2table(temp);
        end
        
        %TODO: 
        %---------------------
        %Support filling in missing based on default values
        
%         function getFinalValue(obj)
%             
%         end
    end
    
end

