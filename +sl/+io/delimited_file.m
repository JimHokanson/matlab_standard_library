classdef delimited_file < sl.obj.display_class
  % see dba.GSK.cmg_expt
  % dba - Duke bladder analysis, package (+)
  % GSK - package (+)
  % @ = class 
  %    class:
  %    sl.io.delimited_file
  %    
    %{
    file_path =...
    'C:\Users\LyndseyGarcia\Documents\Repos\bladder_analysis\data_files\gsk_matlab_analysis\cmg_info\140414_C.csv'
    d = sl.io.readDelimitedFile(file_path,',', 'header_lines', 1, 'return_type', 'object')
    s = struct
  s.cmg_id = d.getColumn('CMG #', 'type', 'numeric')
  cmg_id = obj.raw_data(:, column_number)
    %}
    
    
    properties
        raw_data 
        extras
        column_names
    end
    
    methods
        function obj = delimited_file(cell_data, extras)
            %  sl.io.delimited_file(cell_data, extras)
        obj.raw_data = cell_data;
        obj.extras = extras;
        first_line = obj.extras.header_lines{1};
        obj.column_names = strtrim(regexp(first_line, ',', 'split'));
        
        end
%         deliminator = strmatch(',', d.column_names);
        function column_data = getColumn(obj, requested_column_names, varargin)
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

