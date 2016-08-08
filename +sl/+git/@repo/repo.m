classdef repo < sl.obj.display_class
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
    r = sl.git.repo(repo_path)
    
    repo_path = 'C:\D\repos\matlab_git\bladder_analysis';
    r = sl.git.repo(repo_path)
    
    repo_path = '/Users/jameshokanson/repos/mat_std_lib'
    %}
    
    properties
        repo_path
        h   %org.eclipse.jgit.internal.storage.file.FileRepository
        git %org.eclipse.jgit.api.Git
        %http://download.eclipse.org/jgit/docs/latest/apidocs/org/eclipse/jgit/api/Git.html
        config %sl.git.repo.config
    end
    
    properties (Dependent)
        branch
        full_branch   %string
        
        repository_state
        %DOC: http://download.eclipse.org/jgit/docs/latest/apidocs/org/eclipse/jgit/lib/RepositoryState.html
        
        can_commit  %From repository state
        %Why wouldn't we be able to commit????
        
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
           
           obj.config = sl.git.repo.config(obj.h.getConfig());
        end
        function pull_result = pull(obj)
            %
            %
            %   Outputs:
            %   --------
            %   pull_result: sl.git.pull_result
            %
            
           temp = obj.git.pull; %org.eclipse.jgit.api.PullCommand
           %setCredentialsProvider
           %setProgressMonitor - I think this would
           %    allow setting up some sort of visual callback ...
           %setRebase
           %setRemote
           %setRemoteBranchName
           
           
           %TODO: We can do a password setup before the call.
           %???? - how do we know if this is necessary
           
           %j_pull_result : org.eclipse.jgit.api.PullResult
           j_pull_result = temp.call();
           
           pull_result = sl.git.result.pull_result(j_pull_result);
           %getFetchResult
           %getFetchedFrom
           %getMergeResult
           %getRebaseResult
           %isSuccessful
           keyboard
        end
        function getCommits(obj)
           %TODO: Build an interface to the log_requestor
           log_requestor = sl.git.log_requestor(obj.git.log);
           keyboard
        end
    end
    
end

%{

methods of obj.h

    'FileRepository'
    'close'
    'create'
    'equals'
    'fireEvent'
    'getAdditionalHaves'
    'getAllRefs'
    'getAllRefsByPeeledObjectId'
    'getBranch'
    'getClass'
    'getConfig'     org.eclipse.jgit.storage.file.FileBasedConfig
    'getDirectory'
    'getFS'   %get filesystem
    'getFullBranch'  %string
    'getGlobalListenerList'
    'getIndexFile'
    'getListenerList'
    'getObjectDatabase'     %org.eclipse.jgit.internal.storage.file.ObjectDirectory
    'getObjectsDirectory'   %org.eclipse.jgit.internal.storage.file.ObjectDirectory
    'getRef'
    'getRefDatabase'
    'getReflogReader'
    'getRepositoryState'
    'getTags'
    'getWorkTree'
    'hasObject'
    'hashCode'
    'incrementOpen'
    'isBare'
    'isValidRefName'
    'lockDirCache'
    'newObjectInserter'
    'newObjectReader'
    'notify'
    'notifyAll'
    'notifyIndexChanged'
    'open'
    'openPack'
    'peel'
    'readCherryPickHead'
    'readDirCache'
    'readMergeCommitMsg'
    'readMergeHeads'
    'readOrigHead'
    'readRebaseTodo'
    'readRevertHead'
    'readSquashCommitMsg'
    'renameRef'
    'resolve'
    'scanForRepoChanges'
    'shortenRefName'
    'simplify'
    'stripWorkDir'
    'toString'
    'updateRef'
    'wait'
    'writeCherryPickHead'
    'writeMergeCommitMsg'
    'writeMergeHeads'
    'writeOrigHead'
    'writeRebaseTodoFile'
    'writeRevertHead'
    'writeSquashCommitMsg'

%}

%{
methods of obj.git

    'Git'
    'add'
    'apply'
    'archive'
    'blame'
    'branchCreate'
    'branchDelete'
    'branchList'
    'branchRename'
    'checkout'
    'cherryPick'
    'clean'
    'cloneRepository'
    'close'
    'commit'
    'describe'
    'diff'
    'equals'
    'fetch'
    'gc'
    'getClass'
    'getRepository'
    'hashCode'
    'init'
    'log'
    'lsRemote'
    'lsRemoteRepository'
    'merge'
    'nameRev'
    'notesAdd'
    'notesList'
    'notesRemove'
    'notesShow'
    'notify'
    'notifyAll'
    'open'
    'pull'
    'push'
    'rebase'
    'reflog'
    'reset'
    'revert'
    'rm'
    'stashApply'
    'stashCreate'
    'stashDrop'
    'stashList'
    'status'
    'submoduleAdd'
    'submoduleInit'
    'submoduleStatus'
    'submoduleSync'
    'submoduleUpdate'
    'tag'
    'tagDelete'
    'tagList'
    'toString'
    'wait'
    'wrap'

%}
