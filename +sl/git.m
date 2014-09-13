classdef git
    %
    %   sl.git
    %
    %   http://git-scm.com/docs
    %
    %   The goal of this is to provide a bit more of an intuitive interface
    %   to git via Matlab than other submissions that I have seen.
    %
    %   http://www.eclipse.org/jgit/download/
    %
    %   Interesting link:
    %   http://markashleybell.com/portable-git-windows-setting-home-environment-variable.html
    %
    %   Other git works:
    %   ----------------
    %   https://github.com/slayton/matlab-git/blob/master/git.m
    %   https://github.com/manur/MATLAB-git/blob/master/git.m
    %   https://github.com/mikofski/JGit4MATLAB
    
    %[status,result] = system('"C:\Program Files (x86)\Git\bin\sh.exe" -help')
    
    properties
    end
    
    methods (Static)
        function version()
            
        end
    end
    
    methods (Hidden)
        function execute()
        end
    end
    
    methods (Hidden,Static)
        function jar_base_path = getJarBasePath()
            %sl.git.getJarBasePath
            temp = fileparts(sl.stack.getMyBasePath);
            %-3.4.1.201406201815-r
            jar_base_path = fullfile(temp,'src','java','org.eclipse.jgit.jar');
        end
    end
end

function h__testingCode()
%
%   http://www.gnu.org/software/bash/manual/bash.html#Invoking-Bash
%

%"C:\Program Files (x86)\Git\bin\sh.exe" --login -i

git_path = 'C:\Program Files (x86)\Git\bin\sh.exe';

%cmd_array = {git_path '-c' [getCygwinPath(paths_obj.exe_path) ' -nobanner']};

%??? - what does --login do????

%--login - Shows login info:
% Welcome to Git (version 1.8.1.2-preview20130201)
%
%
% Run 'git help git' to display the help index.
% Run 'git help <command>' to display help for specific commands.
%
%

cmd_array = {git_path '--login' '-i'};

%cmd_array = {git_path '--login'};


temp_process_builder = java.lang.ProcessBuilder(cmd_array);

j_process       = temp_process_builder.start();

j_error_stream  = j_process.getErrorStream;
j_input_stream  = j_process.getInputStream;
j_output_stream = j_process.getOutputStream;

out = j_output_stream;

str_to_write = 'cd /c';

%This causes the following error
str_to_write = 'cd /c/Program Files';
% cd /c/Program Files
% sh.exe": cd: /c/Program: No such file or directory
% [0m[32mRNEL@TURTLE [33m/c[0m
%
% $

%This causes the following "error"
str_to_write = 'cd "/c/Program Files"';
% cd "/c/Program Files"
% [0m[32mRNEL@TURTLE [33m/c/Program Files[0m
%
% $



str_to_write = 'ls';

str = java.lang.String([str_to_write char(10)]);
%On writing we need to pass in a byte array. Hence the use of
%a Java string above and using the getBytes method
out.write(str.getBytes,0,length(str));

%NOTE: Remember to flush!
out.flush;

j_error_stream.available
j_input_stream.available

output = sl.java.read_buffered_stream(j_error_stream)
output = sl.java.read_buffered_stream(j_input_stream)


if isjava(j_process)
    j_process.destroy;
end

end
