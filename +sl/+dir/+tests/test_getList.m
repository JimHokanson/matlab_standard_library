classdef test_getList < matlab.unittest.TestCase
    %
    %   Class:
    %   sl.dir.tests.test_getList
    %
    %   Tests:
    %   sl.dir.getList
    %
    %   
    %   How can we switch on alternative implementations ???
    
    properties
    end
    
    methods (Test)
        function test_dotnetFolderList(testCase)
           temp = sl.dir.getList(matlabroot,'search_type','folders','recursive',true);
        end
    end
    
end

