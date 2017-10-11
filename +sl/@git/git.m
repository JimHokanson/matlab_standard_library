classdef git
    %
    %   Class
    %   sl.git
    %
    %   TODO:
    %   We should allow setting a persistent path
    
    %Windows Git Path
    %-----------------
    %C:\Program Files (x86)\Git\bin
    
    methods (Static)
        function flag = is_installed()
            %
            %   flag = sl.git.is_installed()
            
            version_string = sl.git.runGitCommand('--version',false);
            flag = ~isempty(version_string);
        end
        function version_string = version()
            %
            %   version_string = sl.git.version()
                        
            version_string = sl.git.runGitCommand('--version');
            %git version 1.9.5.msysgit.0
            %git version 2.10.1 (Apple Git-78)
        end
        function result = clone(source_path,parent_path)
            %
            %https://git-scm.com/docs/git-clone
            %
            %   Options not yet implemented ...
            %
            %   TODO: Support renaming the downloaded folder ...
            %
            %   TODO: Allow for soft errors
            %       i.e. show error text but
            
            %go to parent directory
            old_path = cd;
            cd(parent_path)
            command_string = sprintf('clone %s.git', source_path);
            try
                result = sl.git.runGitCommand(command_string);
            catch ME
                cd(old_path)
                rethrow(ME)
            end
        end
        function [result,success_flag] = runGitCommand(command_string,throw_error)
           persistent git_string
           
           if nargin == 1
              throw_error = true; 
           end
           
           %Not sure if this will work, this is for github
           %C:\Users\Jim\AppData\Local\GitHub\GitHub.appref-ms --open-shell
           
           if isempty(git_string)
               if ispc
                   GIT_STRINGS_TRY = {'git' '"C:\Program Files (x86)\Git\bin\git.exe"' '"C:\Program Files\Git\bin\git.exe"' '"C:\Program Files\Git\cmd\git.exe"'};
               else
                   GIT_STRINGS_TRY = {'git'};
               end
               
               found_string = false;
               for iString = 1:length(GIT_STRINGS_TRY)
                   cur_string = GIT_STRINGS_TRY{iString};
                   [failed,result] = system([cur_string ' --version']);
                   if ~failed
                      found_string = true;
                      git_string = cur_string;
                   end
               end
               if ~found_string && throw_error
                  error('Unable to find git') 
               end
           end
           
           if ~isempty(git_string)
               %TODO: Now the command
               [failed,result] = system([git_string ' ' command_string]);
               if failed && throw_error
                  error('git failure calling: "%s"',command_string);
               else
                   success_flag = ~failed;
               end
           else
               %Note, we would have already thrown an error above
               %if we wanted to
               result = [];
               success_flag = false;
           end
           
        end
    end
    
end


%TODO: Write a caller ...
%http://stackoverflow.com/questions/6708760/non-blocking-call-to-external-program-without-losing-return-code
