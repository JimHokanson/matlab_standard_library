classdef mat_version
    %
    %   Class:
    %   sl.io.mat_version
    %
    %   http://www.mathworks.com/help/pdf_doc/matlab/matfile_format.pdf
    %

    
    %{
    wtf = 'testing';
    
    save('wtf_v73','-v7.3','wtf')
    save('wtf_v7','-v7','wtf')
    save('wtf_v6','-v6','wtf')
    save('wtf_v4','-v4','wtf')
    %}
    
    
    
    properties
        raw_str
        version_str %Currently either {7.3 or 5.0}
        %   Version Notes:
        %   --------------
        %   v7.3 uses HDF5
        %   v7 and v6 uses "Level 5" MAT-File format. They can not be 
        %   distinguished by the header.
        %   v4 uses "Level 4" MAT-File format. This class will currently
        %   not work with version 4.
        
        platform
        created_datenum
        created_str
        is_v7p3
        %corrected_version %NYI - would output a numeric of 7.3,7,6,or 4
    end
    
    methods
        function obj = mat_version(file_path)
            %
            %   obj = sl.io.mat_version(file_path)
            
            fid = fopen(file_path, 'r');
            
            %116 - see http://www.mathworks.com/help/pdf_doc/matlab/matfile_format.pdf
            %
            %NOTE: Incorrect for version 4
            str = fread(fid, [1 116], '*char');
            
            fclose(fid);
            %str = evalc(['type(''', file_path, ''')']);
            obj.raw_str = str;
            
            %From https://www.mathworks.com/matlabcentral/fileexchange/39566-mat-file-header-utilities
            tokens = regexp(str, ...
                'MATLAB (.*?) MAT-file, Platform: (.*?), Created on: (\w{3,3} \w{3,3}  ?\d{1,2} \d{2,2}:\d{2,2}:\d{2,2} \d{4,4})', ...
                'tokens','once');
            
            obj.version_str = tokens{1};
            obj.platform    = tokens{2};
            obj.created_datenum = datenum(tokens{3}, 'ddd mmm dd HH:MM:SS yyyy');
            obj.created_str = tokens{3};
            
            obj.is_v7p3 = strcmp(obj.version_str,'7.3');
        end
    end
    
end

