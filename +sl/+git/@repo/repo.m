classdef repo < handle
    %
    %   Class:
    %   sl.git.repo
    %
    %   TODO: We should allow registering repos so that we can later do
    %   things with them ... (open to? sync?) (not sure what things I might
    %   want to do just yet)
    
    %{
    clear all
    repo_path = 'C:\D\repos\matlab_git\mat_std_lib';
    obj = sl.git.repo(repo_path)
    %}
    
    properties
        repo_path
        h   %org.eclipse.jgit.internal.storage.file.FileRepository
        git %org.eclipse.jgit.api.Git
        %http://download.eclipse.org/jgit/docs/latest/apidocs/org/eclipse/jgit/api/Git.html
    end
    
    properties (Dependent)
        branch
        full_branch
        repository_state
        %DOC: http://download.eclipse.org/jgit/docs/latest/apidocs/org/eclipse/jgit/lib/RepositoryState.html
        can_commit %From repository state
        remote_names
    end
    
    methods
        function value = get.branch(obj)
           value = char(obj.h.getBranch);
        end
        function value = get.full_branch(obj)
            value = char(obj.h.getFullBranch);
        end
        function value = get.repository_state(obj)
           value = char(obj.h.getRepositoryState); 
        end
        function value = get.can_commit(obj)
           temp  = obj.h.getRepositoryState;
           value = temp.canCommit; 
        end
        function value = get.remote_names(obj)
           temp = obj.h.getRemoteNames(); 
           value = cell(1,length(temp));
           for iValue = 1:length(temp)
              value{iValue} = char(temp(iValue)); 
           end
        end
    end
    
    methods
        function obj = repo(repo_path)
            %
            %   repo = sl.git.repo(repo_path)

            obj.repo_path = repo_path;
            
           %Get repo object from path and "repo builder" 
           j_repo_builder = org.eclipse.jgit.storage.file.FileRepositoryBuilder();
           repo_j_file = java.io.File(repo_path);
           j_repo_builder.setWorkTree(repo_j_file);
           
           obj.h   = j_repo_builder.build();
           obj.git = org.eclipse.jgit.api.Git(obj.h);
        end
        function pull_result = pull(obj)
            %
            %
            %   Outputs:
            %   --------
            %   pull_result: sl.git.pull_result
            %
            
           temp = obj.git.pull; %org.eclipse.jgit.api.PullCommand
           
           %TODO: We can do a password setup before the call.
           %???? - how do we know if this is necessary
           
           j_pull_result = temp.call();
           
           pull_result = sl.git.pull_result(j_pull_result);
           %getFetchResult
           %getFetchedFrom
           %getMergeResult
           %getRebaseResult
           %isSuccessful
        end
        function getCommits(obj)
           %TODO: Build an interface to the log_requestor
           log_requestor = sl.git.log_requestor(obj.git.log);
           keyboard
        end
    end
    
end

