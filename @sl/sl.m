classdef (Hidden) sl
    %
    %   Class:
    %   sl
    %
    %   sl => standard library
    
    properties (Constant)
       TEMP_DIR = fullfile(sl.getRoot,'temp_directory'); 
    end
    
    methods (Static,Hidden)
        %sl.initialize - in a separate file
        initialize()
        function root = getRoot()
           %This is needed as this call can't be resolved in a property
           %block
           root = sl.stack.getPackageRoot; 
        end
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

