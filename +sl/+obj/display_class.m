classdef display_class < handle
    %
    %    Class:
    %    sl.obj.display_class
    %
    %    This is a copy of sl.obj.handle_light with additional support for
    %    displaying the class in more detail. I chose to copy handle_light
    %    to avoid high levels of inheritance.
    %
    %   See Also:
    %   sl.obj.handle_light   
    
    methods(Hidden)
        function disp(objs)
           %This is the new method that was added on from handle_light
           %to make this the display class.
           sl.obj.dispObject_v1(objs)
        end
        function str = datatipinfo(objs)
           %This gets called when mousing over an object
           
           %TODO: I think we want to change this behavior
           
           str = evalc('builtin(''disp'',objs)');
        end
    end
    
    methods (Hidden)
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