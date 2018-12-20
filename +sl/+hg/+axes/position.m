classdef (Hidden) position < handle
    %
    %   Class:
    %   sl.hg.axes.position
    %
    %   This class is meant to help with interfacing to a position
    %   property.
    %
    %   position, vs outerposition, vs tightinset
    %
    %   See Also:
    %   sl.hg.axes
    
    %{
    subplot(3,3,5);
    plot(1:10)
    a = sl.hg.axes(gca);
    p = a.p;
    %Adjust p as desired
    p.right = 0.8;
    p.left = 0.6;
    p.top = 0.9;
    p.bottom = 0.1;
    
    %}
    
    
    properties
        h %handle to the axes
        
        type
        %Either:
        %    - 'position'
        %    - 'outerposition'
        %    - 'tightinset'
    end
    
    %TODO: I'd like to be able to set these ...
    properties (Dependent)
        %Read & Write
        raw_position
        
        %Currently read only
        ll %[x,y] pairs, lower left
        lr %lower right
        ul %upper left
        ur %upper right
        
        %Read & Write
        top
        bottom
        left
        right
        center_y
        center_x
    end
    
    methods
        %TODO: These should be wrapped with try/catch ...
        function value = get.center_x(obj)
            value = obj.left + 0.5*(obj.right - obj.left);
        end
        function value = get.center_y(obj)
            value = obj.bottom + 0.5*(obj.top - obj.bottom);
        end
        %TODO: Implement set functions for center_x and center_y ...
        function value = get.raw_position(obj)
            value = get(obj.h,obj.type);
        end
        function set.raw_position(obj,value)
            set(obj.h,obj.type,value);
        end
        function value = get.ll(obj)
            temp = obj.raw_position;
            value = [temp(1),temp(2)];
        end
        function value = get.lr(obj)
            temp = obj.raw_position;
            value = [temp(1)+temp(3),temp(2)];
        end
        function value = get.ul(obj)
            temp = obj.raw_position;
            value = [temp(1),temp(2)+temp(4)];
        end
        function value = get.ur(obj)
            temp = obj.raw_position;
            value = [temp(1)+temp(3),temp(2)+temp(4)];
        end
        function value = get.top(obj)
            temp = obj.raw_position;
            value = temp(2)+temp(4);
        end
        function value = get.bottom(obj)
            temp = obj.raw_position;
            value = temp(2);
        end
        function value = get.left(obj)
            temp = obj.raw_position;
            value = temp(1);
        end
        function value = get.right(obj)
            temp = obj.raw_position;
            value = temp(1)+temp(3);
        end
        %We'll keep everything else the same
        function set.top(obj,value)
            temp = obj.raw_position;
            new_height = value - temp(2);
            temp(4) = new_height;
            obj.raw_position = temp;
        end
        function set.bottom(obj,value)
            temp    = obj.raw_position;
            new_height = obj.top - value;
            temp(2) = value;
            temp(4) = new_height;
            obj.raw_position = temp;
        end
        function set.left(obj,value)
            temp = obj.raw_position;
            new_width = obj.right - value;
            temp(1) = value;
            temp(3) = new_width;
            obj.raw_position = temp;
        end
        function set.right(obj,value)
            temp = obj.raw_position;
            new_width = value - temp(1);
            temp(3) = new_width;
            obj.raw_position = temp;
        end
    end
    
    methods
        function obj = position(h,type)
            %
            %   obj = position(h,type)
            %
            %   Inputs:
            %   -------
            %   type: {'position','outerposition','tightinset'}
            
            obj.h = h;
            obj.type = type;
        end
        function setTopAndBottom(obj,top,bottom)
            %We can't always set these independently because then we might
            %get a negative height between the two calls
            temp = obj.raw_position;
            new_height = top - bottom;
            temp(2) = bottom;
            temp(4) = new_height;
            obj.raw_position = temp;
        end
        % % % % %         function changePosition(obj,varargin)
        % % % % %             %
        % % % % %             %   How do I want this function to work ...
        % % % % %             in.ll = obj.ll;
        % % % % %             in.lr = obj.lr;
        % % % % %             in.ul = obj.ul;
        % % % % %             in.ur = obj.ur;
        % % % % %             in = sl.in.processVarargin(in,varargin);
        % % % % %         end
    end
    
end

