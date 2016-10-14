classdef column_specs
    %
    %   Class
    %   sl.io.delimited.column_specs
    %
    %   This class was written to facilitate specifying instructions for 
    %   parsing dataframe like 'table' files.
    %
    %   See Also:
    %   ---------
    %   sl.io.readDelimitedFile
    %
    %   Usage:
    %   ------
    %   TODO: Finish documentation
    %   1) load file
    %   2) show extra params for sl.io.readDelimitedFile
    %
    %   FORMAT
    %   ------
    %   Name
    %   Required
    %   Type
    %   Delimiter
    %   Units
    %   Default
    %   Description
    %
    %   What's Missing
    %   --------------
    %   1) Validation code
    %   2) custom functions
    
    %{
    file_path = 'D:\repos\matlab_git\bladder_analysis\data_files\gsk_matlab_analysis\cmg_info\specs.txt'
    s = sl.io.column_type_specs(file_path)
    
    %}
    
    properties (Constant)
       KNOWN_TYPES = {'string','numeric','numeric array','logical'}; 
    end
    
    properties
       name
       variable_name
       required
       
       type
       %known types:
       %- string
       %- numeric
       %- numeric array
       
       delimiter
       units
       default
       description
    end
    
    %TODO: Implement a table display for this class
    %Perhaps just convert to a table?
    
    methods
        function obj = column_specs(file_path,varargin)
            %
            %   
            %   obj = sl.io.delimited.column_specs(file_path,varargin)
            
            
            in.delimiter = sprintf('\t'); %tab
            in = sl.in.processVarargin(in,varargin);
            
            f = sl.io.delimited.readFile(file_path,in.delimiter, 'has_column_labels', true, 'return_type', 'object');
            
            f.set_as_logical('Required')
            
            %TODO:
            %-----
            %1) Check types against known types
            
            
            obj.name        = f.c('Name');
            obj.variable_name = f.c('Variable_Name');
            obj.required    = f.c('Required');
            obj.type        = f.c('Type');
            
            mask = ~ismember(obj.type,obj.KNOWN_TYPES);
            if any(mask)
                fprintf(2,'The invalid type row #s are:\n');
                disp(find(mask)+1)
                error('One of the specified type values does not match any entry in the list of known types')
            end
            
            obj.delimiter   = f.c('Delimiter');
            obj.units       = f.c('Units');
            obj.default     = f.c('Default');
            obj.description = f.c('Description');
        end
    end
    
end

