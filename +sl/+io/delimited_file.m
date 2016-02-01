classdef delimited_file < sl.obj.display_class
    %
    %   Class:
    %   sl.io.delimited_file
    %
    %   See Also:
    %   ---------
    %   sl.io.readDelimitedFile
    
    %
    % see dba.GSK.cmg_expt
    % dba - Duke bladder analysis, package (+)
    % GSK - package (+)
    % @ = class
    %    class:
    %    sl.io.delimited_file
    %
    %{
    
        file_path = 'G:\repos\matlab_git\bladder_analysis\data_files\gsk_matlab_analysis\cmg_info\140414_C.csv'
        d = sl.io.readDelimitedFile(file_path,',', 'header_lines', 1, 'return_type', 'object')
        d.set_as_numeric({'File #','CMG #','Void Vol. (ml)','Resid. Vol. (ml)','Record','Fill Rate (ml/hr)','QP start','QP end','Start Pump','Stop Pump','Trial End'})
    
        s = struct
        s.cmg_id = d.c('CMG #', 'type', 'numeric')
        cmg_id = obj.raw_data(:, column_number)
    %}
    
    
    properties
        raw_data %the original data from the file
        processed_data
        extras %struct
        %A loosly defined structure from sl.io.readDelimitedFile
        
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
    end
    
    methods
        function obj = delimited_file(cell_data, extras)
            %
            %  sl.io.delimited_file(cell_data, extras)
            %
            %   See Also:
            %   ---------
            %   sl.io.readDelimitedFile
            
            obj.raw_data = cell_data;
            obj.processed_data = cell_data;
            obj.extras = extras;
            
            first_line = obj.extras.header_lines{1};
            obj.column_names = strtrim(regexp(first_line, ',', 'split'));
            if ~isempty(obj.column_names)
               obj.data_types = repmat({'string'},size(obj.column_names));
               obj.units = repmat({''},size(obj.column_names));
            end
        end
        function set_as_logical(obj,names)
           h__changeType(obj,names,@str2double) 
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
           h__changeType(obj,names,@str2double) 

        end
        function set_data_types(obj,varargin)
           %
           %    set_data_types(obj,varargin)
           %    
           %    Example:
           %    --------
           %    obj.set_data_types({'File #' 'CMG )
           
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
            
            in.type = [];
            in = sl.in.processVarargin(in,varargin);
            %             column_number = find(strcmp(requested_column_names, obj.column_names));
            %             column_data = obj.raw_data(:,column_number);
            [mask, loc] = ismember(requested_column_names, obj.column_names);
            % Todo: check all are present, see all() function
            column_data = obj.raw_data(:, loc);
            
            %             strlength = size(obj.column_names{1,1}) %size of column_names
            %             for i = 1: strlength
            %
            %             end
            keyboard
            
            
        end
    end
    
end

function h__changeType(obj,names,function_handle)

if ischar(names)
   names = {names};
end

[mask,loc] = ismember(names,obj.column_names);
if ~all(mask)
  error('Not all requested names were present') 
end

obj.data_types(loc) = {'double'};
obj.processed_data(:,loc) = cellfun(function_handle,obj.processed_data(:,loc),'un',0);

end
