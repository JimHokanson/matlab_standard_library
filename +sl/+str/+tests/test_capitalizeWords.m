classdef test_capitalizeWords < matlab.unittest.TestCase
    %
    %   Class:
    %   sl.str.tests.test_capitalizeWords
    %   
    
    properties
    end
    
    methods (Test)
        function test1(testCase)
           str_out = sl.str.capitalizeWords('input string');
           testCase.verifyEqual(str_out,'Input String','capitalization error')
        end
    end
    
end

