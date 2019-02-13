classdef concatenation
    %
    %   Class:
    %   sl.struct.results.concatenation
    %
    %   This class holds the result of concatenating structures. Unlike
    %   native concatenation in Matlab, this process supports missing
    %   fields.
    %   
    %   In Native Matlab code
    %   ----------------------
    %   s = struct();
    %   s.a = 1;
    %   s.b = 2;
    %   
    %   s2 = struct();
    %   s2.a = 3;
    %
    %   s3 = [s s2]; %Doesn't work
    %
    %   Using this code
    %   ---------------
    %   temp = sl.struct.concatenate(s,s2);
    %   s3 = temp.getRawStructureArray();
    %
    %   s3 => 
    %  1×2 struct array with fields:
    %
    %        a
    %        b
    %
    %
    %   See Also
    %   --------
    %   sl.struct.concatenate
    
    properties
        raw_struct = 'call getRawStructureArray()'
        raw_table  = 'call getRawTable()'
        unique_field_names
        %NOTE, the order here matches the order in raw_cell
    end
    
    %???? What was this ....
%     properties (Dependent)
%         missing_per_field
%     end

%   TODO: sum 'is_missing' over 2nd and 3rd dimensions
%     properties (Dependent)
%        n_missing_per_field 
%     end
    
    properties
        d1 = '---- Internal Properties ----'
        raw_cell    %[n_fields  rows  columns]
        is_missing  %[n_fields  rows  columns]
        %   NOTE, is_missing does not mean == []
        %   
        %   Instead it means that the field is not in the structure.
        %   
        %   s1.a = 1;
        %   'b' is missing in 's1'
        %
        %   s2.a = 1;
        %   s2.b = [];
        %   'b' is not missing in 's2'
    end
    
    methods
        function obj = concatenation(unique_field_names,raw_cell,is_missing,options)
            %
            %
            %   Example
            %   -------
            %   s = struct();
            %   s.b = 1;
            %   s.a = 2;
            %   
            %   s2 = struct();
            %   s2.a = 3;
            %   temp = sl.struct.concatenate(s,s2);
            %   s3 = temp.getRawStructureArray();
            %
            %   See Also
            %   --------
            %   sl.struct.concatenate
            
            obj.unique_field_names = unique_field_names;
            obj.raw_cell = raw_cell;
            obj.is_missing = is_missing;
            %TODO: Use options from concatenate
        end
        function output = getRawStructureArray(obj)
            %
            %   TODO: Document this function ...
            %
        	output = cell2struct(obj.raw_cell,obj.unique_field_names,1);
        end
% % % %         function output = getRawOutput(obj)
% % % %             %
% % % %             %   DEPRECATED - use  getRawStructureArray instead   
% % % %             %
% % % %             
% % % %             %Number of field names must match number of fields in new structure.
% % % %             %
% % % %             %S = cell2struct(C,FIELDS,DIM) 
% % % %             %
% % % %             output = cell2struct(obj.raw_cell,obj.unique_field_names,1);
% % % %         end
        function output = getRawTable(obj)
            %
            %   Returns the structure array as a table. 
            %
            %   Outputs
            %   -------
            %   output : table
            temp = obj.getRawStructureArray;
            output = struct2table(temp);
        end
        function output = getProcessedTable(obj,varargin)
            %
            %
            %   Optional Inputs
            %   ---------------
            %   defaults : cell of prop/value pairs
            %       Any fields which have missing 
            %       Example {'a',1,'b',2}
            %       
            %
            
            in.defaults = [];
            in.add_completely_missing_default = true;
            in = sl.in.processVarargin(in,varargin);
            
            output_cell = obj.raw_cell;
            field_names_local = obj.unique_field_names;
            is_missing_local = obj.is_missing;
            
            if ~isempty(in.defaults)
                props = in.defaults(1:2:end);
                values = in.defaults(2:2:end);
                %TODO: error check on length and type for props
                for i = 1:length(props)
                    cur_name = props{i};
                    cur_value = values(i); %leave as a cell for assignment
                    I = find(strcmp(cur_name,obj.unique_field_names)); 
                    if isempty(I)
                        if in.add_completely_missing_default
                            error('Not yet implemented')
                            %This can be challenging to do cleanly
                            %We should allow growing a dimension
                            %cleanly
                            %
                            %   Interesting solution ...
                            %   https://www.mathworks.com/matlabcentral/answers/57610-extending-columns-and-rows-of-matrix
                        else

                           %TODO: We might want to allow having completely
                           %missing defaults ... 
                           error('Missing field ...') 
                        end
                    else
                        prop_mask = false(size(output_cell));
                        prop_mask(I,:,:) = true;
                        final_mask = is_missing_local & prop_mask;
                        output_cell(final_mask) = cur_value;
                    end
                end
            end
        	output = cell2struct(output_cell,field_names_local,1);

            
        end
        %TODO: 
        %---------------------
        %Support filling in missing based on default values
        
%         function getFinalValue(obj)
%             
%         end
    end
    
end

