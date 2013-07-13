classdef explain
    %
    %   This class is meant to help in explaining errors more thorougly.
    %
    %   This can/should be done in two ways:
    %   -------------------------------------------------------------------
    %   1) Providing a better explanation of what exactly the error means,
    %   and in what circumstances this might occur. This might be done
    %   via a short summary along with a link to a longer diatribe on the
    %   topic.
    %   2) Providing further analysis of the situation in particular. In
    %   other words, in this particular case, how might the problem be
    %   solved.
    %   
    %
    %   Things:
    %   -------------------------------------------------------------------
    %   1) Auto log new errors that are not yet handled
    %   2) Create method to determine what errors are handled
    %
    %   Design Questions/Decisions
    %   -------------------------------------------------------------------
    %   1) How to handle user-specific error messages?
    %           - how can they be registered?
    %   
    %   Design Decisions
    %   -------------------------------------------------------------------
    %   1) Expose useful functions through links in a helper class
    %   2) Create a class that is specifically meant to handle logging errors
    %
    %   Simplified Access
    %   -------------------------------------------------------------------
    %   explain - This function simplifies access to this class
    %
    %   See Also:
    %   explain
    
    %Useful functions
    %----------------------------------------------------------------------
    %
    
    properties (Constant)
       ALLOW_ERROR_REGISTRATION = true %The idea with this variable is
       %that we can log errors that we are not familiar with into a 
       %file for later processing.
    end
    
    properties
    end
    
    methods
        function obj = explain(ME)
           %Display identifier
           
           
           
        end
    end
    
end

