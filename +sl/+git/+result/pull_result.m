classdef pull_result < handle
    %
    %   Class:
    %   sl.git.result.pull_result
    %
    %   This object should be returned from a pull request made to a repo.
    %
    %   Java documentation at:
    %   http://download.eclipse.org/jgit/docs/latest/apidocs/org/eclipse/jgit/api/PullResult.html
    %
    %   Status: Done
    %
    %   See Also:
    %   sl.git.repo
    
    properties
        success
        fetched_from
    end
    
    properties (Hidden)
        j_pull_result
    end
    
    properties (Dependent)
        fetch_result
        merge_result
    end
    
    methods
        function value = get.fetch_result(obj)
            value = obj.j_pull_result.getFetchResult();
        end
        function value = get.merge_result(obj)
            value = obj.j_pull_result.getMergeResult();
        end
    end
    
    methods
        function obj = pull_result(j_pull_result)
            %
            %   obj = sl.git.pull_result(j_pull_result)
            %
            %   Inputs:
            %   -------
            %   j_pull_result : org.eclipse.jgit.api.PullResult
            
            obj.j_pull_result = j_pull_result;
            
            obj.success = j_pull_result.isSuccessful;
            obj.fetched_from = char(j_pull_result.getFetchedFrom);
            
        end
    end
    
end

