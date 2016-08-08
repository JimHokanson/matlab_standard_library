classdef log_requestor < handle
    %
    %   Class:
    %   sl.git.log_requestor
    %
    %      
    
    properties
       max_count = 'all'
       skip = 0
    end
    
    properties
       h %org.eclipse.jgit.api.LogCommand
    end
    
    methods
        function obj = log_requestor(j_log)
            %
            %   Inputs:
            %   -------
            %   j_log: org.eclipse.jgit.api.LogCommand
            %       
            obj.h = j_log;
        end
        function commits = getCommits(obj)
           commits = sl.git.commit.create(obj.h.call);
        end
    end
    
end

