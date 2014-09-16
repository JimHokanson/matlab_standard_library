classdef repo
    %
    %   Class:
    %   sl.git.repo
    %
    %   TODO: We should allow registering repos so that we can later do
    %   things with them ... (open to? sync?) (not sure what things I might
    %   want to do just yet)
    
    %{
    repo_path = 'C:\D\repos\matlab_git\mat_std_lib';
    
    %}
    
    properties
        repo_path
    end
    
    methods
        function obj = repo(repo_path)

           %Get repo object from path and "repo builder" 
           j_repo_builder = org.eclipse.jgit.storage.file.FileRepositoryBuilder();
           repo_j_file = java.io.File(repo_path);
           j_repo_builder.setWorkTree(repo_j_file);
           h = j_repo_builder.build();
        end
    end
    
end

