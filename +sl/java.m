classdef java
    %
    %
    %   TODO: Determine class conflicts with Matlab version
    %
    %   http://stackoverflow.com/questions/1096148/how-to-check-the-jdk-version-used-to-compile-a-class-file
    
    properties
    end
    
    methods (Static)
        function output = getMLVersion()
            %
            %   sl.java.getMLVersion
            %
            %   Example Output:
            %   ---------------
            %   output = 
            %         major: '6'
            %         minor: '0_17-b04'
            %         major_num: 6
            
            temp = version('-java');
            
            %Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) 64-Bit Server VM mixed mode 
            wtf = regexp(temp,'Java 1\.(\d)\.([^\s]*)','tokens','once');
            
            output.major = wtf{1};
            output.minor = wtf{2};
            output.major_num = str2double(output.major);
            
            %TODOO
           %version -java 
           
        end
    end
    
end

