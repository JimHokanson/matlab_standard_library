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
            
            version_string = strtrim(sl.git.runGitCommand('--version'));
            %git version 1.9.5.msysgit.0
            %git version 2.10.1 (Apple Git-78)
            %git version 2.11.1.windows.1
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
        function git_path = get_git_path(throw_error)
            
            persistent git_string
            
            if nargin == 1
                throw_error = true;
            end
            
            
            if isempty(git_string)
                if ispc
                    %TODO: for Github look in somewhere like:
                    %C:\Users\RNEL\AppData\Local\GitHubDesktop\app-2.6.3\resources\app\git\mingw64\bin
                    %
                    %    start here:
                    %    C:\Users\RNEL\AppData\Local\GitHubDesktop
                    
                    user_path = char(System.Environment.GetEnvironmentVariable("USERPROFILE"));
                    github_root = fullfile(user_path,'AppData','Local','GitHubDesktop');
                    
                    
                    
                    if exist(github_root,'dir')
                        s = dir(fullfile(github_root,'app-*'));
                        
                        if length(s) > 1
                            last_date = s(1).datenum;
                            %Technically we would be better off sorting names
                            %using natural sort ...
                            cur_I = 1;
                            for i = 2:length(s)
                                if s(i).datenum > last_date
                                    cur_I = i;
                                    last_date = s(i).datenum;
                                end
                            end
                            best_path = fullfile(github_root,s(cur_I).name);
                            s = dir(fullfile(best_path,'**/git.exe'));
                            if length(s) > 1
                                exe_size = s(1).bytes;
                                cur_I = 1;
                                for i = 2:length(s)
                                    if s(i).bytes > exe_size
                                        cur_I = i;
                                        exe_size = s(i).bytes;
                                    end
                                end
                                folder_use = s(cur_I).folder;
                                github_exe_path = fullfile(folder_use,'git.exe');
                            end
                        end
                    end
                    
                    %C:\Users\RNEL\AppData\Local\GitHubDesktop\app-2.9.0\resources\app\git\cmd
                    
                    %;
                    
                    
                    GIT_STRINGS_TRY = {'git' '"C:\Program Files (x86)\Git\bin\git.exe"' '"C:\Program Files\Git\bin\git.exe"' '"C:\Program Files\Git\cmd\git.exe"'};
                    
                    if ~isempty(github_exe_path)
                        GIT_STRINGS_TRY = [{github_exe_path} GIT_STRINGS_TRY];
                    end
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
                        break
                    end
                end
                if ~found_string && throw_error
                    error('Unable to find git')
                end
            end
            
            git_path = git_string;
            
        end
        function [result,success_flag] = runGitCommand(command_string,throw_error)
            
            if nargin == 1
                throw_error = true;
            end
            
            git_string = sl.git.get_git_path(throw_error);
            
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
