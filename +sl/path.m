classdef (Hidden) path
    %
    %   Class:
    %   sl.path
    %
    %   Class for hiding functions. I don't think you can hide normal
    %   functions in Matlab. However, if the functions are static methods
    %   of a class they can be hidden ... By placing them in a class it
    %   also provides a bit more convenient access for simple functions.
    %
    %   Functions that are in this class are typically not meant to be
    %   accessed directly by users.
    
    properties (Constant)
       LIBRARY_PARENT_PATH = sl.path.getLibraryParentPath(); %Points to folder
       %that contains the '+sl' folder
       LIBRARY_BETA_PATH   = sl.path.getBetaPath();
    end
    
    methods (Static)
        function reset()
           %x sl.path.reset 
           %
           %    This doesn't do what I want it to
           %    TODO: Build a hook into the initialization
           %    userpath('reset') 
        end
    end
    
    methods (Static,Hidden)
        function value = getBetaPath()
           value = fullfile(sl.path.LIBRARY_PARENT_PATH,'beta_code');
        end
        function value = getLibraryParentPath()
           %%??? - when is the class definition loaded? On first call?
           %
           %or, when added to the path?
           %
           %If the latter, this would cause problems
           %
           %
           value = sl.stack.getPackageRoot();
        end
        %NOTE: I had thought about creating a GUI which would toggle
        %beta code being on the path or not.
        function addBeta()
           addpath(sl.path.LIBRARY_BETA_PATH);
        end
        function removeBeta()
           rmpath(sl.path.LIBRARY_BETA_PATH);
        end
        function [base_path,file_name,ext] = fileparts()
            %This is only meant to be used on files
            %Goal is to provide something that handles packages
            %
            %   This will probably need to be renamed.
            %
            %   This should probably be in sl.dir
            %
            %   i.e. I wanted something like:
            %   my_path\+sl\+test\file.m
            %
            %  base_path = my_path
            %  file_name = sl.test.file
            %  ext       = .m
        end
        function subs_mask = matchSubdirectories(path_entries,base_path)
            %matchSubdirectories  Match subdirectories of a given base_path
            %
            %   subs_mask = sl.path.matchSubdirectories(path_entries,base_path)
            %
            %   Currently only subdirectories are matched
            %
            %   INPUTS
            %   ===========================================================
            %   path_entries : (cell array)
            %   base_path    : (char) path of root folder
            %
            %   IMPROVEMENTS
            %   ===========================================================
            %   1) Allow multiple base paths as an input
            %   2) Allow matching the base path as well
            %
            %   See Also:
            %   
            
            %in.include_base_path
            %in = sl.in.processVarargin(in,varargin);
            
            %This is critical to match only subdirectories ...
            if base_path(end) ~= filesep
                base_path = [base_path filesep]; 
            end
            
            subs_mask = strncmp(base_path,path_entries,length(base_path)); 
            
            %{
            @TEST_CODE
            
            %Still working out details on how I want to do testing ...
            
                path_entries = 
                subs_mask    = sl.path.matchSubdirectories(path_entries,base_path)
            
            
            %}
        end
    end
    
    methods (Static)
        
    end
    
end

