classdef test_filepartsx < matlab.unittest.TestCase
    %
    %   Class:
    %   sl.dir.test.filepartsx
    %
    %   Tests:
    %   sl.dir.filepartsx
    
    properties
    end
    
    methods (Test)
        function basicTest(testCase)
           my_path = 'C:/folder_1/folder_2';
           testCase.verifyEqual(...
               fileparts(fileparts(my_path)),...
               sl.dir.filepartsx(my_path,2));
        end
    end
    
end

