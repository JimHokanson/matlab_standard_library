classdef delimited_file < sl.obj.display_class
    %
    %   Class:
    %   sl.io.delimited_file
    %
    %   This is a result class from reading a delimited file. It is meant
    %   to facilitate extracting certain types of information from the
    %   parsed file.
    %
    %   ??? TODO: Change name to data_table_file?????
    %
    %   TODO: This class is a bit of a mess and needs to be cleaned up and
    %   documented
    %
    %
    %   See Also:
    %   ---------
    %   sl.io.readDelimitedFile
    %
    %
    %   TODO:
    %   ----
    %   1) Build in support for missing fields
    
    %
    % see dba.GSK.cmg_expt
    % dba - Duke bladder analysis, package (+)
    % GSK - package (+)
    % @ = class
    %    class:
    %    sl.io.delimited_file
    %
    %{
    
        #Local test code
    
        file_path = 'D:\repos\matlab_git\bladder_analysis\data_files\gsk_matlab_analysis\cmg_info\140414_C.csv'
        d = sl.io.readDelimitedFile(file_path,',', 'header_lines', 1, 'return_type', 'object')
        
    
        %name,required,type,default_value
        %info = {...
        %  'File #',1,'numeric','';
        %  'CMG #',
    
    
        d.set_as_numeric({'File #','CMG #','Void Vol. (ml)','Resid. Vol. (ml)','Record','Fill Rate (ml/hr)','QP start','QP end','Start Pump','Stop Pump','Trial End'})
        d.set_as_logical('is_good')
    
        s = struct
        s.cmg_id = d.c('CMG #', 'type', 'numeric')
        cmg_id = obj.raw_data(:, column_number)
    %}
    
    
    properties
        n_rows
        raw_data %the original data from the file
        processed_data
        extras %struct
        %A loosly defined structure from sl.io.readDelimitedFile
        
        optional_column_names = {} %Only populated when specs was specified
        optional_default_values
        optional_data_types
        
        column_names %Names of each column. This may not be valid
        %if the file does not contain header lines.
        
        data_types %cellstr
        %   Possible types include:
        %   - String
        %   - Double (set also via numeric)
        %   - Logical
        %   - Categorical %NYI
        %   - arrays
        
        units
        specs %sl.io.column_type_specs
    end
    
    methods
        function obj = delimited_file(cell_data, extras, specs)
            %
            %   obj = sl.io.delimited_file(cell_data, extras, specs)
            %
            %   Inputs
            %   ------
            %   cell_data
            %   extras
            %   specs : sl.io.column_type_specs
            %
            %   See Also:
            %   ---------
            %   sl.io.readDelimitedFile
            
            obj.specs = specs;
            
            obj.raw_data = cell_data;
            obj.n_rows = size(cell_data,1);
            
            obj.processed_data = cell_data;
            obj.extras = extras;
            
            obj.column_names = obj.extras.column_labels;
            %first_line = obj.extras.header_lines{1};
            %obj.column_names = strtrim(regexp(first_line, ',', 'split'));
            if ~isempty(obj.column_names)
                obj.data_types = repmat({'string'},size(obj.column_names));
                obj.units = repmat({''},size(obj.column_names));
            end
            if isobject(specs)
                obj.apply_specs(specs);
            end
        end
        function apply_specs(obj,specs)
            %
            %    Inputs
            %    ------
            %    specs  : sl.io.column_type_specs
            
            spec_names = specs.name;
            [mask,loc] = ismember(spec_names,obj.column_names);
            
            %TODO: Speed up name to location lookup (when casting)
            required = specs.required;
            missing_required = any(required(~mask));
            if missing_required
                %TODO: Provide more details
                error('Some required columns are missing')
            end
            
            if any(~required)
                obj.optional_column_names = spec_names(~required);

                %TODO: Eventually we will need to respect the default ...
                %For each, get their default values
                types = specs.type(~required);
                
                obj.optional_data_types = types;
                
                n_optional = length(types);
                default_values = cell(1,n_optional);
                
                for iType = 1:n_optional
                    cur_data_type = types{iType};
                    switch cur_data_type
                        case 'numeric'
                            default_value = NaN;
                        case 'string'
                            default_value = '';
                        case 'logical'
                            %TODO: This especially needs a user default
                            default_value = false;
                        case 'numeric array'
                            default_value = [];
                        otherwise
                            error('Unrecognized option: %s',cur_data_type)
                    end
                    default_values{iType} = default_value;
                end
                obj.optional_default_values = default_values;
            end
            
            for iCol = 1:length(spec_names)
                if mask(iCol)
                    cur_loc = loc(iCol);
                    
                    cur_name = spec_names{iCol};
                    data_type = specs.type{iCol};
                    obj.units{cur_loc} = specs.units{iCol};
                    
                    %TODO: Description
                    switch data_type
                        case 'numeric'
                            obj.set_as_numeric(cur_name);
                        case 'string'
                            %Do nothing
                        case 'logical'
                            obj.set_as_logical(cur_name);
                        case 'numeric array'
                            delimiter = specs.delimiter{iCol};
                            obj.set_as_array(cur_name,'delimiter',delimiter);
                        otherwise
                            error('Unrecognized option: %s',data_type)
                    end
                end
            end
        end
        function set_as_array(obj,names,varargin)
            in.delimiter = ',';
            in.type = 'numeric';
            in = sl.in.processVarargin(in,varargin);
            
            if strcmp(in.type,'numeric')
                h__changeType(obj,names,@(x)h__splitNumericArray(x,in.delimiter),'numeric array')
            else
                error('Unhandled type')
            end
        end
        function set_as_logical(obj,names)
            h__changeType(obj,names,@sl.str.toLogical,'logical')
        end
        function set_as_numeric(obj,names)
            %
            %
            %    set_as_numeric(obj,names)
            %
            %    Example:
            %    --------
            %    obj.set_as_numeric({'File #','CMG #','Void Vol. (ml)','Resid. Vol. (ml)','Record','Fill Rate (ml/hr)','QP start','QP end','Start Pump','Stop Pump','Trial End'}
            
            %TODO: Call generic with function handle
            h__changeType(obj,names,@str2double,'numeric')
        end
        function column_data = c(obj, requested_column_names, varargin)
            %
            %
            %   Input/output mapping
            %
            %   Inputs:
            %   -------
            %   requested_column_names :
            %
            %   Optional Inputs:
            %   ----------------
            %   defaults_ok : logical (default true)
            %
            
            %Single vs multiple requests
            %char => single, collapse if possible
            %cellstr => multiple, no collapsing
            
            in.defaults_ok = true;
            in = sl.in.processVarargin(in,varargin);
            
            %in.type = [];
            %in = sl.in.processVarargin(in,varargin);
            %             column_number = find(strcmp(requested_column_names, obj.column_names));
            %             column_data = obj.raw_data(:,column_number);
            
            if ischar(requested_column_names)
                collapse_if_possible = true;
                requested_column_names = {requested_column_names};
            else
                collapse_if_possible = false;
            end
            
            [mask, loc] = ismember(requested_column_names, obj.column_names);
            
            
            %TODO: Now check for optional columns
            
            n_names = length(requested_column_names);
            column_data = cell(obj.n_rows,n_names);
            for iCol = 1:n_names
                if mask(iCol)
                    column_data(:,iCol) = obj.processed_data(:,loc(iCol));
                end
            end
            
            if ~all(mask)
                %Try to load all missing via defaults
                %------------------------------------
                if in.defaults_ok
                    I = find(~mask);
                    missing_names = requested_column_names(I);
                    %Try to replace all missing with defaults
                    for iMissing = 1:length(missing_names)
                        cur_column_I = I(iMissing);
                        cur_misssing_name = missing_names{iMissing};
                        I2 = find(strcmp(cur_misssing_name,obj.optional_column_names));
                        if isempty(I2)
                            error('Requested name: %s, is missing and was not found to be optional',cur_misssing_name)
                        else
                            cur_optional_data_type = obj.optional_data_types{I2};
                            default_value = obj.optional_default_values{I2};
                            column_data(:,cur_column_I) = repmat({default_value},[obj.n_rows, 1]);
                        end
                    end
                else
                    %TODO: This error type comes up a lot, let's make a nice
                    %display handler for it
                    %
                    %other cases:
                    %   - handling optional input arguments that are spelled
                    %   incorrectly
                    %
                    missing_column_names = requested_column_names(~mask);
                    fprintf(2,'Missing some column names:\n');
                    disp(missing_column_names)
                    error('Some requested column names are missing')
                end
            end
            
            if collapse_if_possible
                if loc == 0
                    cur_data_type = cur_optional_data_type;
                else
                    %Currently assuming a single data type
                    cur_data_type = obj.data_types{loc};
                end
                if any(strcmp(cur_data_type,{'logical','numeric'}))
                    
                    %Let's keep as a column vector. Transpose output
                    column_data = [column_data{:}]';
                end
            end
            
        end
        
        %Apparently this doesn't work with invalid variable names
        % % %         function output = get_table(obj)
        % % %            %x Retrieve dataframe (table)
        % % %            %
        % % %            %    Introduced in 2013b
        % % %
        % % %
        % % %            n_columns = length(obj.column_names);
        % % %            temp_values = cell(1,n_columns);
        % % %            for iCol = 1:n_columns
        % % %               temp_values{iCol} = obj.processed_data(:,iCol);
        % % %            end
        % % %
        % % %            output = table(temp_values{:},'VariableNames',obj.column_names);
        % % %
        % % %         end
        function disp_info(obj)
            %to display
            %----------
            %1) column names
            %2) data type
            n_columns = length(obj.column_names);
            c = cell(n_columns,3);
            c(:,1) = obj.column_names;
            c(:,2) = obj.data_types;
            c(:,3) = obj.units;
            %TODO: Eventually it would be nice to call a display function here
            disp(c)
        end
    end
    
end

function output = h__splitNumericArray(input_string,delimiter)
output = str2double(regexp(input_string,['\s*' delimiter '\s*'],'split'));
end

function h__changeType(obj,names,function_handle,type_string)
%
%   Inputs
%   ------
%   names : char or cellstr
%       Column names to change
%   function_handle :
%       Takes in the current value and outputs the new value
%   type_string

if ischar(names)
    names = {names};
end

[mask,loc] = ismember(names,obj.column_names);
if ~all(mask)
    error('Not all requested names were present')
end

obj.data_types(loc) = {type_string};
obj.processed_data(:,loc) = cellfun(function_handle,obj.processed_data(:,loc),'un',0);

end
