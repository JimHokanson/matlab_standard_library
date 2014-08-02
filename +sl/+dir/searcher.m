classdef (Hidden) searcher < sl.obj.handle_light
    %
    %   Class:
    %   sl.dir.searcher
    %
    %   I completely forgot how this class was supposed to be used. This
    %   needs to be clarified and most likely refactored to be more
    %   obvious.
    %
    %   Implementations:
    %   sl.dir.searcher.folder_default
    %   
    %
    %   Search subdirectories ....
    %
    %   See Also:
    %   sl.dir.list_methods
    %   sl.dir.filter_methods
    %   sl.dir.filter_options
    
    properties (Abstract,Constant)
       OPTIONS 
       %Column 1: Listing option
       %Column 2: filtering option  
       %Column 3: # (for display purposes only)
    end
    
    properties (Abstract)
       filter_method_use
       list_method_use
    end
    
    properties
       filter_options 
    end
    
    methods
        function obj = searcher()
           
           %Handle class, instantiate in constructor to have unique instance
           obj.filter_options = sl.dir.filter_options;
        end
        function changeOption(obj,option_number)
           list_option   = obj.OPTIONS{option_number,1};
           obj.list_method_use = str2func(['sl.dir.list_methods.' list_option]); 
           filter_option = obj.OPTIONS{option_number,2};
           obj.filter_method_use   = str2func(['sl.dir.filter_methods.' filter_option]);
        end
    end
end

