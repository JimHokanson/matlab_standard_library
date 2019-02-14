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
        function output = getProcessedStructureArray(obj,varargin)
            %x Retrieve concatenated structure array with defaults support
            %
            %   output = getProcessedStructureArray(obj,varargin)
            %
            %   Optional Inputs
            %   ---------------
            %   defaults : cell of prop/value pairs
            %       Any fields which may have missing values
            %       Example {'a',1,'b',2}
            %   add_missing : default false
            %       If a default field does not exist, this adds it to
            %       all entries with the default value.
            %   throw_missing_error : default false
            %       If a default field does not exist, this throws an error
            %       indicating which field is missing.
            %       
            %   Missing Field Conditions
            %   ------------------------
            %   1) missing field, add with default value => 'add_missing'
            %   2) missing field, don't add 
            %   3) missing field, throw error => 'throw_missing_error'
            %
            %   Example
            %   -------
            %   s1 = struct;
            %   s1.a = 1;
            %   s1.b = 2;
            % 
            %   s2 = struct;
            %   s2.a = 3;
            % 
            %   temp = sl.struct.concatenate(s1,s2);
            %   s3 = temp.getProcessedStructureArray('defaults',{'c',4},'add_missing',true);
            % 
            %   s3(2) =>
            %       a: 3
            %       b: []
            %       c: 4

            
            in.defaults = [];
            in.add_missing = false;
            in.throw_missing_error = false;
            in = sl.in.processVarargin(in,varargin);
            
            output_cell = obj.raw_cell;
            field_names_local = obj.unique_field_names;
            is_missing_local = obj.is_missing;
            
            if ~isempty(in.defaults)
                props = in.defaults(1:2:end);
                values = in.defaults(2:2:end);
                if length(props) ~= length(values)
                    error('mismatch in # of default properties and # of default values')
                end
                for i = 1:length(props)
                    cur_name = props{i};
                    cur_value = values(i); %leave as a cell for assignment
                    I = find(strcmp(cur_name,obj.unique_field_names));                    
                    if isempty(I)
                        if in.add_missing
                            %This can be challenging to do cleanly
                            %We should allow growing a dimension
                            %cleanly
                            %
                            %   Interesting solution ...
                            %   https://www.mathworks.com/matlabcentral/answers/57610-extending-columns-and-rows-of-matrix
                            
                            output_cell(end+1,:,:) = cur_value; %#ok<AGROW>
                            field_names_local = [field_names_local; {cur_name}]; %#ok<AGROW>
                            
                            %This needs to keep the same shape for possible
                            %later use in another loop iteration
                            is_missing_local(end+1,:,:) = false; %#ok<AGROW>

                        elseif in.throw_missing_error
                           error('Missing fieldname: %s, for adding default values',cur_name) 
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
        function output = getProcessedTable(obj,varargin)
            %x Retrieve concatenated structure as a table with defaults support
            %
            %   output = getProcessedTable(obj,varargin)
            %
            %   Optional Inputs
            %   ---------------
            %   defaults : cell of prop/value pairs
            %       Any fields which may have missing values
            %       Example {'a',1,'b',2}
            %   add_missing : default false
            %       If a default field does not exist, this adds it to
            %       all entries with the default value.
            %   throw_missing_error : default false
            %       If a default field does not exist, this throws an error
            %       indicating which field is missing.
            %
            %   Example
            %   -------
            %   s1 = struct;
            %   s1.a = 1;
            %   s1.b = 2;
            % 
            %   s2 = struct;
            %   s2.a = 3;
            % 
            %   temp = sl.struct.concatenate(s1,s2);
            %   s3 = temp.getProcessedTable('defaults',{'c',4},'add_missing',true);
            % 
            %   s3 =
            % 
            %   2×3 table
            %     a     b     c
            %     _    ___    _
            %     1    [2]    4
            %     3    []     4
          
          	temp = obj.getProcessedStructureArray(varargin{:});
            output = struct2table(temp);
        end
    end
    
end

