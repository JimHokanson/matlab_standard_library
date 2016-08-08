function addJavaJar(jar_path,varargin)
%
%
%   sl.path.addJavaJar
%
%   This function adds a java jar but only if it has not been added
%   previously. It also takes care of handling warning dumps about not 
%   clearing java classes that are still 
%
%
%   TODOS:
%   1) java path to entries function
%   2) handle warning display

error('Not yet finished')

%TODO: When reloading 

in.reload           = false; 
in.display_warnings = true;
in = sl.in.processVarargin(in,varargin);


%NOTE: The javaclasspath, like the other pathing functions
%has a large overhead ...

if in.reload
    %Might need a java clear call here ...
    javaaddpath(jar_path)
    return
end
    
p = javaclasspath('-dynamic');

%Warning:
%MATLAB:Java:DuplicateClass


%TEST IF IN PATH ...

javaaddpath(jar_path)

%NOTE: This could be a function too ...





%NOTE: Calling javaclasspath calls clear java
%to reload all java classes:
%
%   from javaaddpath ...
%
% % %    Example 1:
% % %    % Add a directory
% % %    javaaddpath D:/tools/javastuff 
% % %    % 'clear java' was used to reload modified Java classes


% In javaclasspath>doclear at 377
%   In javaclasspath>local_javapath at 194
%   In javaclasspath at 119
%   In javaaddpath at 71
%   In install at 24
%   In getJAHConstants>startupJAH at 117
%   In getJAHConstants>@()startupJAH(C) at 89
%   In startup at 128 