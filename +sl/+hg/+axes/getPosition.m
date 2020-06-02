function p = getPosition(h_axes,varargin)
%x retrieves position information for axes handles
%
%   p = sl.hg.axes.getPosition(h_axes,varargin)
%
%   This function exists for a couple of reasons:
%   1) To return position information as a struct rather than an array. The
%   default position is an array where you need to remember what each
%   element corresponds to, rather than labeled properties (e.g. left,
%   bottom)
%   2) To take into account a colorbar or legend as part of the position.
%
%   https://www.mathworks.com/help/matlab/creating_plots/automatic-axes-resize.html
%   
%   Inputs
%   ------
%   h_axes : [1 n] or {1 n}
%
%   Optional Inputs
%   ---------------
%   add_legend : default false NYI
%       If true the extents of the axes are extended to include the legend
%   add_colorbar : default false
%       If true the extents of the axes are extended to include the
%       colorbar
%   type : default 'tight'
%       'tight' 't' - axes + text
%       'outer' 'o' - axes + text + ?? margins
%       'inner' 'p' - axes only
%   as_struct : default false
%       TODO: I think true would be preferable, where is this being used in
%       the code base????
%       
%   Outputs
%   -------
%   p : cell, struct, struct_array, array
%       When 2 or more axes are given, the result is a cell or struct
%       array. Toggling between array/cell and struct/struct_array is done
%       by the 'as_struct' option.
%
%       1 axes
%           array - as_struct=false
%           struct - as_struct=true
%       2+ axes
%           {array} - as_struct=false
%           struct_array - as_struct=true
%           struct - as_struct=true
%
%   
%       Note, the struct has the following format:
%       .left
%       .bottom
%       .width
%       .height
%       .top
%       .right
%
%   Examples
%   --------
%   sp = 
%
%
%   See Also
%   --------
%   sl.hg.figure.getPosition
%   sl.plot.subplotter
%   sl.hg.axes.drawPositionBox

%TODO: We need to respect different units

in.flatten_struct = false;
in.as_struct = true;
in.add_legend = false;
in.add_colorbar = false;
in.type = 'tight';
in = sl.in.processVarargin(in,varargin);

if in.flatten_struct
    in.as_struct = true;
end

if length(h_axes) == 1
    p = h__getPosition(h_axes,in);
elseif iscell(h_axes)
    p = arrayfun(@(x) h__getPosition(x,in),h_axes,'un',0);
else
    p = arrayfun(@(x) h__getPosition(x,in),h_axes,'un',0);
end

if in.as_struct && iscell(p)
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
    %The -1 assumes pixel position
    %TODO: Remove this assumption ...
    s = struct('left',p(1),'bottom',p(2),'width',p(3),'height',p(4),...
        'right',p(1)+p(3)-1,'top',p(2)+p(4)-1);
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
