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
       LIBRARY_BETA_PATH   = sl.path.getBetaPath()
       %The thought with beta code was that it could be a set of functions
       %that are in progress but not yet ready for general usage that could
       %be added relatively easily to the path with:
       %    sl.path.addBeta()
       LIBRARY_REF_PATH    = sl.path.getRefPath()
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
        function value = getRefPath()
           value = fullfile(sl.path.LIBRARY_PARENT_PATH,'ref_code'); 
        end
        function value = getLibraryParentPath()
            %x 
            %
            %   Returns the folder that contains the standard library (+sl)
            %   package.
            %
            value = sl.stack.getPackageRoot();
        end
        %NOTE: I had thought about creating a GUI which would toggle
        %beta code being on the path or not.
        function addBeta()
            %
            %   sl.path.addBeta
           addpath(sl.path.LIBRARY_BETA_PATH);
        end
        function removeBeta()
            %
            %   sl.path.removeBeta
           rmpath(sl.path.LIBRARY_BETA_PATH);
        end
        function addRef()
           %It might be nice to make a GUI for selecting particular folders
           %and subfolders
           addpath(sl.path.LIBRARY_REF_PATH);
           initializeRefCode();
        end
        function removeRef()
           %TODO: Build in removal
            
        end
        function path_entries = toCellstr(path_string)
        %x  Parses a path string into a cellstr.
        %
        %   path_cell_array = sl.path.toCellstr(path_string)
        %
        %   This is really a helper function for the class. The more useful
        %   function is probably sl.path.asCellstr
        %
        %   Input:
        %   ------
        %   path_string : string
        %       The raw path string
        %
        %   Output:
        %   -------
        %   path_cell_array : {n x 1}, cellstr
        %       Each entry is a directory in the Matlab path
        %
        %   Example:
        %   --------
        %   path_entries = sl.path.toCellstr(path())
        %
        %   See Also:
        %   sl.path.asCellstr
        %   path

        path_entries = regexp(path_string,pathsep,'split')';
        if isempty(path_entries(end))
            path_entries(end) = [];
        end

        end
        
        
% % % %         function [base_path,file_name,ext] = fileparts()
% % % %             %This is only meant to be used on files
% % % %             %Goal is to provide something that handles packages
% % % %             %
% % % %             %   This will probably need to be renamed.
% % % %             %
% % % %             %   This should probably be in sl.dir
% % % %             %
% % % %             %   i.e. I wanted something like:
% % % %             %   my_path\+sl\+test\file.m
% % % %             %
% % % %             %  base_path = my_path
% % % %             %  file_name = sl.test.file
% % % %             %  ext       = .m
% % % %         end

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
    
end

