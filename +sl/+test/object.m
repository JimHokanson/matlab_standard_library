classdef object < matlab.unittest.TestCase
    %
    %   Class:
    %   sl.test.object
    %
    %   Not sure if I want to eventually add more here ...
    %
    %   I wanted to add documentation examples here ...
    %
    %   Interesting Read:
    %   http://blogs.mathworks.com/steve/2013/03/12/matlab-software-testing-tools-old-and-new-r2013a/
    %
    %   IMPORTANT CLASSES:
    %   ===================================================================
    %   matlab.unittest.TestCase
    %       
    %
    %   METHODS of matlab.unittest.TestCase
    %   http://www.mathworks.com/help/matlab/ref/matlab.unittest.testcaseclass.html
    %   
    %   Method Attributes:
    %   Test	Method block to contain test methods.
    %   TestMethodSetup	Method block to contain setup code.
    %   TestMethodTeardown	Method block to contain teardown code.
    %   TestClassSetup	Method block to contain class level setup code.
    %   TestClassTeardown	Method block to contain class level teardown code.
    
    
    
    
    
    
    %TestClassSetup
%     methods (TestClassSetup)
%     function doSomethingBeforeAllTestMethodsAreExecuted(testCase)
%         disp('Hi, Mom!')
%     end
%     end



%     methods (Test)
%         function testRealSolution(testCase)
%             actSolution = quadraticSolver(1,-3,2);
%             expSolution = [2,1];
%             testCase.verifyEqual(actSolution,expSolution);
%         end
%         function testImaginarySolution(testCase)
%             actSolution = quadraticSolver(1,2,10);
%             expSolution = [-1+3i, -1-3i];
%             testCase.verifyEqual(actSolution,expSolution);
%         end
%     end    
    
    

% properties
%     TestFigure
% end
% methods(TestMethodSetup)
%     function createFigure(testCase)
%         %comment
%         testCase.TestFigure = figure;
%     end
% end
% methods(TestMethodTeardown)
%     function closeFigure(testCase)
%         close(testCase.TestFigure);
%     end
% end
    
    properties
    end
    
    methods
    end
    
end

