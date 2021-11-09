classdef fcn_call < sl.obj.display_class
    %
    %   Class:
    %   sl.mlint.fcn_call
    %
    %   TODO: This looks like it should be in sl.mlint.mex ...
    %
    %   This class is meant to work closely with sl.mlint.calls
    %
    %   See Also:
    %   sl.mlint.calls
    
    properties
        name %Name of the function
        type
        %'anonymous'
        %'main method'
        %'nested function'
        %'subfunction'
        %'unresolved'
        line_number
        column_number
        start_I
        
        is_anonymous = false
        
        is_fcn_definition = false
        end_line_number
        end_column_number
        end_I %
        %mac 2013a - end seems to point the 'd' in end
    end
    
    properties (Hidden)
        parent
    end
    
    properties
        fcn_text 
    end
    
    methods 
        function value = get.fcn_text(obj)
           if obj.is_fcn_definition
               value = obj.fcn_text;
               if isempty(value)
                   raw_text = obj.parent.raw_file_string;
                   value = raw_text(obj.start_I:obj.end_I);
                   obj.fcn_text = value;
               end
           else
               value = '';
           end
        end
    end
    
    methods
        function obj = fcn_call(calls_obj,I)
            %
            %   obj = sl.mlint.fcn_call(calls_obj,I);
            %
            %   See Also:
            %   sl.mlint.calls
            %   
            
            obj.parent = calls_obj;

            %Handle end of function declaration
            %--------------------------------------------------------------
            %The selected input may signify the end of a function
            %definition. In this case the index is adjusted so that
            %we process the start of the function, rather than the end.
            call_type  = calls_obj.fcn_call_types{I};
            if call_type == 'E'
                %We're making an assumption here that the previous
                %function is the start definition of the function.
                I = I - 1;
                call_type = calls_obj.fcn_call_types{I};
            end
            
            %Populate properties
            %--------------------------------------------------------------
            obj.name    = calls_obj.fcn_names{I};
            obj.start_I = calls_obj.absolute_indices(I);
            
            switch call_type
                case 'A'
                    obj.type = 'anonymous';
                    obj.is_anonymous = true;
                case 'M'
                    obj.type = 'main method';
                case 'N'
                    obj.type = 'nested function';
                case 'S'
                    obj.type = 'subfunction';
                case 'U'
                    obj.type = 'unresolved';
                otherwise
                    error('Unhandled case: %s',call_type)
            end
            
            obj.line_number = calls_obj.line_numbers(I);
            obj.column_number = calls_obj.column_start_indices(I);
            
            %End handling
            %--------------------------------------------------------------
            %If the input is a function declaration with code and a
            %corresponding end of function, then we populate that
            %termination info here.
            %
            if I ~= calls_obj.n_calls && calls_obj.fcn_call_types{I+1} == 'E'
                end_name = calls_obj.call_names{I+1};
                if ~strcmp(end_name,obj.name)
                   error('End function doesn''t match start function name') 
                end
                
                obj.is_fcn_definition = true;
                obj.end_line_number = calls_obj.line_numbers(I+1);
                obj.end_column_number = calls_obj.column_start_indices(I+1);
                obj.end_I = calls_obj.absolute_indices(I+1);
            end
        end
    end
    
end

