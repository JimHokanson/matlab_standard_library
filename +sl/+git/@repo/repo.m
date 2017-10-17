classdef repo
    %
    %   Class:
    %   sl.git.repo
    
    %{
    f = '/Users/jim/Documents/repos/matlab_git/matlab_standard_library'
    
    git --git-dir=/home/repo/.git log
    
    r = sl.git.repo(f);
    
    Commands
    --------
    log
    %}
    
    properties
        path
    end
    
    methods
        function obj = repo(path)
            obj.path = path;
        end
    end
    
end

