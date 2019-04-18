classdef menu < handle
    %
    %   Class:
    %   sl.plot.uimenu.menu
    %
    %   Written to handle adding menus and submenus without having
    %   redundant entries
    
    properties
        text_field_name
        parent %handle to parent
        h %handle to Matlab menu
    end
    
    methods (Static)
        function obj = fromHandle(h)
            %
            %   obj = sl.plot.uimenu.menu.fromHandle(h)
            
            if sl.ml.verLessThan('2017b')
                TEXT = 'Label';
            else
                TEXT = 'Text';
            end
           
           obj = sl.plot.uimenu.menu(h.(TEXT),h.Parent);
        end
    end
    
    methods
        function obj = menu(menu_text,parent)
            %
            %   m = sl.plot.uimenu.menu(menu_text,parent)
            %
            %   Example
            %   -------
            %      
            
            if nargin == 0
                parent = gcf;
            end
            
            %In 2017b uimenu's switched from 'Label' to 'Text' fields for the display
            %string :/
            if sl.ml.verLessThan('2017b')
                obj.text_field_name = 'Label';
            else
                obj.text_field_name = 'Text';
            end
            
            TEXT = obj.text_field_name;

            c = get(parent,'Children');
            is_menu_class = arrayfun(@(x) isa(x,'matlab.ui.container.Menu'),c);

            c_menu = c(is_menu_class);
            
            if isempty(c_menu)
                I = [];
            else
                
                I = find(strcmp({c_menu.(TEXT)},menu_text),1);
            end
            
            if isempty(I)
                obj.h = uimenu(parent,TEXT,menu_text);
            else
                obj.h = c_menu(I);
            end
        end
        function h2 = addChild(obj,child_text,varargin)
            %TODO: Look through parent to see if child text already exists 
            %....
            %
            %   Improvements
            %   -------------
            %   1) allow alpha sorting
            %   2) allow adding line to seperate into sections ...
            %   3) Second output to indicate if added or not
            
            TEXT = obj.text_field_name;
            
        	c2 = get(obj.h,'Children');
            if ~isempty(c2)
                I = find(strcmp({c2.(TEXT)},child_text),1);
                add_menu = isempty(I);
                if ~isempty(I)
                   h = c2(I); 
                end
            else
                add_menu = true;
            end
            
            if add_menu
                h = uimenu(obj.h,TEXT,child_text,varargin{:});
            end
            
            h2 = sl.plot.uimenu.menu.fromHandle(h);
        end
    end
end

