classdef test_fullfileCA < matlab.unittest.TestCase
    %
    %   Class:
    %   sl.dir.tests.test_fullfileCA
    %
    %   Tests:
    %   sl.dir.fullfileCA
    %
    %   
    %   How can we switch on alternative implementations ???
    
    properties
    end
    
    methods (Test)
        function test1(testCase)
           if ispc
              root = 'C:\home';
              expected_result = {'C:\home\next1' 'C:\home\next2'};
           else
              root = '/home';
              expected_result = {'/home/next1' '/home/next2'};
           end
           
           next_folders = {'next1','next2'};
           
           fcn_result = sl.dir.fullfileCA(root,next_folders);
           testCase.verifyEqual(fcn_result,expected_result) 
        end
    end
    
end

