classdef handle_light < handle
   %
   %    Class:
   %    sl.obj.handle_light
   %
   %    This class hides methods from handle, with the exception of
   %    isvalid which is sealed. This is useful for removing method
   %    clutter when doing tab completion.
   %
   %    Potential peformance issue:
   %    -------------------------------------------------------------------
   %    This class creates significant overhead when
   %    dealing with many thousands of objects. Normally this is not
   %    the case, and the benefits of improved code interfacing with
   %    tab completion outweighs the slight performance penalty per object,
   %    but that might now always be the case.
   %
   %    Rought estimate: 50 microseconds per object
   %    -> 40000 objects -> 2 second delay
   %
   %    NOTE: In general the more levels of inheritance the slower things
   %    will generally tend to go.
   
   methods(Hidden)
      function lh = addlistener(varargin)
         lh = addlistener@handle(varargin{:});
      end
      function notify(varargin)
         notify@handle(varargin{:});
      end
      function delete(varargin)
          try
              delete@handle(varargin{:});
          catch ME
          %This appears to occur after the class has been edited
          %while in debug mode.
              
%               formattedWarning('WHAT THE HECK')
%               keyboard
          end
      end
      function Hmatch = findobj(varargin)
         Hmatch = findobj@handle(varargin{:});
      end
      function p = findprop(varargin)
         p = findprop@handle(varargin{:});
      end
      function TF = eq(varargin)
         TF = eq@handle(varargin{:});
      end
      function TF = ne(varargin)
         TF = ne@handle(varargin{:});
      end
      function TF = lt(varargin)
         TF = lt@handle(varargin{:});
      end
      function TF = le(varargin)
         TF = le@handle(varargin{:});
      end
      function TF = gt(varargin)
         TF = gt@handle(varargin{:});
      end
      function TF = ge(varargin)
         TF = ge@handle(varargin{:});
      end
   end
end