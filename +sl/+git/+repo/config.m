classdef config < handle
    %
    %   Class:
    %   sl.git.repo.config
    %
    %   Status: A work in progress
    %
    %   The JGIT interface to the config is VERY generic. I'd like this
    %   class to make it a bit less generic ...
    %
    %   http://git-scm.com/docs/git-config
    
    properties
        h %org.eclipse.jgit.storage.file.FileBasedConfig
        sections %cellstr
        %Names of each section
        
    end
    
    properties (Dependent)
       raw_text %string
       %There seems to be a bug in the code where raw_text is not complete
       is_outdated 
    end
    
    methods
        function value = get.raw_text(obj)
           value = obj.h.toText; 
        end
        function value = get.is_outdated(obj)
           value = obj.h.isOutdated(); 
        end
    end
    
    methods
        function obj = config(j_config)
           obj.h = j_config;
           
           %keyboard
           
           
           temp = obj.h.getSections();
           
           obj.sections = cell(temp.toArray());
        end
        function getSection(name)
            %TODO: Should verify section exists ...
           s = sl.git.repo.config.section(h,name); 
        end
    end
    
end

%{
FileBasedConfig    getBoolean         getNames           isOutdated         setEnum            toText             
addChangeListener  getClass           getSections        load               setInt             uncache            
clear              getEnum            getString          notify             setLong            unset              
equals             getFile            getStringList      notifyAll          setString          unsetSection       
fromText           getInt             getSubsections     save               setStringList      wait               
get                getLong            hashCode           setBoolean         toString    



            String url = storedConfig.getString("remote", remoteName, "url");
            System.out.println(remoteName + " " + url);

[core]
	repositoryformatversion = 0
	filemode = false
	bare = false
	logallrefupdates = true
	symlinks = false
	ignorecase = true
	hideDotFiles = dotGitOnly
[remote "origin"]
	url = https://github.com/JimHokanson/matlab_standard_library.git
	fetch = +refs/heads/*:refs/remotes/origin/*
	puttykeyfile = 
[branch "master"]
	remote = origin
	merge = refs/heads/master
[user]
	name = Jim Hokanson
	email = jim.hokanson@gmail.com
[submodule "+sl/+io/matlab-json-cp"]
	url = https://github.com/christianpanton/matlab-json.git
[gui]
	wmstate = normal
	geometry = 887x427+325+325 171 192





%}