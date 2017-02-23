classdef git
    %
    %   Class
    %   sl.git
    
    methods (Static)
        function flag = is_installed()
            %
            %   flag = sl.git.is_installed()
            persistent result
            if isempty(result)
                temp = sl.git.version();
                result = ~isempty(temp);
            end
            flag = result;
        end
        function version_string = version()
            %
            %   version_string = sl.git.version()
            
            [failed,result] = system('git --version');
            if failed
                version_string = '';
            else
                %TODO: parse this a bit more ...
                version_string = result;
            end
            %git version 1.9.5.msysgit.0
        end
        function clone(source_path,parent_path)
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
            command = sprintf('git clone %s.git', source_path);
            [failed,result] = system(command);

            cd(old_path);
            if failed
                error(result)
            end
        end
    end
    
end


%TODO: Write a caller ...
%http://stackoverflow.com/questions/6708760/non-blocking-call-to-external-program-without-losing-return-code
