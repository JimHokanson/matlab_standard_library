classdef filepartsx < sl.test.object
    %
    %   Class:
    %   sl.dir.test.filepartsx
    %
    %   Tests:
    %   sl.dir.filepartsx
    
    properties
    end
    
    methods (Test)
        function basicTest(obj)
           my_path = 'C:/folder_1/folder_2';
           obj.assertEqual(...
               fileparts(fileparts(my_path)),...
               sl.dir.filepartsx(my_path,2));
        end
    end
    
end

