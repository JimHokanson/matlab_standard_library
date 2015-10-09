classdef delimited_file < sl.obj.display_class
  % 
  %    class:
  %    sl.io.delimited_file
  %    
    %{
    file_path =...
    'C:\Users\LyndseyGarcia\Documents\Repos\bladder_analysis\data_files\gsk_matlab_analysis\cmg_info\140414_C.csv'
    d = sl.io.readDelimitedFile(file_path,',', 'header_lines', 1, 'return_type', 'object')
    
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
        obj.column_names = obj.extras.header_lines;
        %obj.version = obj.column_names('Version');
        end
%         deliminator = strmatch(',', d.column_names);
        function column_data = getColumn(obj, column_names)
            [row column] = size(d.raw_data);
            strlength = size(d.extras.header_lines{1,1}) %size of column_names
            for i = 1: strlength
                
            end
           
        for k = 1:5 %number here depends on size
           version(1,1) = obj.raw_data(1,1);
           file_number(1,k) = d.raw_data(k,2);
           cmg_number(1,k) = d.raw_data(k,3);
           is_good(1,k) = d.raw_data(k,4);
           void_volume_ml(1,k) = d.raw_data(k,5);
           residual_volume_ml(1,k) = d.raw_data(k,6);
           record(1,k) = d.raw_data(k,7);
           fill_rate(1,k) = d.raw_data(k,8); %ml/hr
           qp_start(1,k) = d.raw_data(k,9);
           qp_end(1,k) = d.raw_data(k,10);
           start_pump(1,k) = d.raw_data(k,11);
           stop_pump(1,k) = d.raw_data(k,12);
           trial_end(1,k) = d.raw_data_(k,13);
           bladder_contraction_start(1,k) = d.raw_data(k,14);
           bladder_contraction_end(1,k) = d.raw_data(k,15);
           treatment(1,k) = d.raw_data(k,16);
        end
        end
    end
    
end

