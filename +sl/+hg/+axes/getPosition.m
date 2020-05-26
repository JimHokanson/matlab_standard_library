function p = getPosition(h_axes,varargin)
%
%   p = sl.hg.axes.getPosition(h_axes,varargin)
%
%   Inputs
%   ------
%   h_axes : [1 x n] 
%
%   Optional Inputs
%   ---------------
%   add_legend : default false
%   add_color : default false
%   type : default 'tight'
%       'tight' 't'
%       'outer' 'o'
%       'inner' 'p'
%   as_struct : default false
%       
%   Outputs
%   -------
%   p : cell, struct, struct_array, array
%       When 2 or more axes are given, the result is a cell or struct
%       array. Toggling between array/cell and struct/struct_array is done
%       by the 'as_struct' option.
%   
%       Note, the struct has the following format:
%       .left
%       .bottom
%       .width
%       .height
%       .top
%       .right

%TODO: We need to respect different units

in.flatten_struct = false;
in.as_struct = false;
in.add_legend = false;
in.add_colorbar = false;
in.type = 'tight';
in = sl.in.processVarargin(in,varargin);

if length(h_axes) == 1
    p = h__getPosition(h_axes,in);
else
    p = arrayfun(@(x) h__getPosition(x,in),h_axes,'un',0);
    if in.as_struct
       p = [p{:}]; 
    end
    if in.flatten_struct
        s = struct('left',[p.left],...
            'bottom',[p.bottom],...
            'width',[p.width],...
            'height',[p.height],...
            'right',[p.right],...
            'top',[p.top]);  
        p = s;
    end
end

end

function p = h__getPosition(h_axes,in)

switch lower(in.type(1))
    case {'i' 'p'}
        %inner
        %position => inner position
        p = h_axes.Position;
    case 'o'
        %outer
        p = h_axes.OuterPosition;
    case 't'
        %tight
        p = h_axes.Position;
        inset = h_axes.TightInset;
        p(1) = p(1)-inset(1);
        p(2) = p(2)-inset(2);
        p(3) = p(3) + inset(1)+inset(3);
        p(4) = p(4) + inset(2)+inset(4);
    otherwise
        error('Code error, unrecognized type')
end

if in.add_colorbar
    h_color = sl.hg.axes.getColorbarHandle(h_axes);
    if ~isempty(h_color)
      	if ~strcmp(h_axes.Units,h_color.Units)
            error('Code doesn''t currently support different units') 
        end
        p_color = sl.hg.colorbar.getPosition(h_color,'type',in.type(1));
        p = h__mergeP(p,p_color);
    end
end

if in.add_legend
    error('Code not yet implemented')
end

if in.as_struct
    s = struct('left',p(1),'bottom',p(2),'width',p(3),'height',p(4),...
        'right',p(1)+p(3),'top',p(2)+p(4));
    p = s;
end

end

function p_new = h__mergeP(p1,p2)
    left1 = p1(1);
    right1 = left1 + p1(3);
    bottom1 = p1(2);
    top1 = bottom1 + p1(4);
    
    left2 = p2(1);
    right2 = left2 + p2(3);
    bottom2 = p2(2);
    top2 = bottom2 + p2(4);    
    
    if left1 < left2
        left = left1;
    else
        left = left2;
    end
    
    if right1 > right2
        right = right1;
    else
        right = right2;
    end
    
    if bottom1 < bottom2
        bottom = bottom1;
    else
        bottom = bottom2;
    end
    
    if top1 > top2
        top = top1;
    else
        top = top2;
    end
    
    width = right-left;
    height = top-bottom;
    p_new = [left bottom width height];
end
