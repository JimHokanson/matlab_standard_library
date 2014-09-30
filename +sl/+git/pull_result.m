classdef pull_result < handle
    %
    %   sl.git.pull_result
    %
    %   Java documentation at:
    %   http://download.eclipse.org/jgit/docs/latest/apidocs/org/eclipse/jgit/api/PullResult.html
    %
    %   This isn't complete ....
    
    properties
       success
       fetched_from
       %fetch_result
       %merge_result
    end
    
    methods
        function obj = pull_result(j_pull_result)
            %
            %   obj = sl.git.pull_result(j_pull_result)
            %
            %   Inputs:
            %   -------
            %   j_pull_result : 
            
           obj.success = j_pull_result.isSuccessful;
           obj.fetched_from = char(j_pull_result.getFetchedFrom);
        end
    end
    
end

