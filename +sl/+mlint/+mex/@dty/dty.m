classdef dty < sl.mlint
    %
    %   Class:
    %   sl.mlint.mex.dty
    %

    
    properties
        function_list
        call_names
        call_line_numbers %{1 x n}
        first_line_number
    end
    
    methods
        function obj = dty(file_path)
            
            
            %   obj = sl.mlint.mex.dty(which('sl.plot.subplotter'))
            
            %-dty invalid in 2019a :/
            
            obj.file_path      = file_path;
            obj.raw_mex_string = mlintmex(file_path,'-dty','-m3');
            
            keyboard
            
        end
    end
    
end

function array_out = h__toInt(string_in)
array_out = sscanf(string_in,'%d');
end

