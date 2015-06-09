classdef (Hidden) sl
    %
    %   Class:
    %   sl
    %
    %   sl => standard library
    
    
    methods (Static,Hidden)
        %sl.initialize
        initialize()
        function runTests()
           %
           %    sl.runTests()
           %
           %    Run this function to run all tests in this directory
           %
           %    Improvements:
           %    -------------
           %    1) Add http://www.mathworks.com/help/matlab/ref/matlab.unittest.plugins.codecoverageplugin-class.html
           %    2) allow silent failure
           %    3) perhaps return a result class of our own that summarizes
           %    failures
           
           %http://www.mathworks.com/help/matlab/ref/matlab.unittest.testcase-class.html
           %http://www.mathworks.com/help/matlab/matlab_prog/types-of-qualifications.html
           
           suite = matlab.unittest.TestSuite.fromPackage('sl','IncludingSubpackages',true); %#ok<NASGU>
           
           [~,r] = evalc('suite.run()');
           failed = [r.Failed];
           if any(failed)
              %TODO: Make this optional 
              error('Something failed')
           else
              disp(r); 
           end
        end
    end
    
end

