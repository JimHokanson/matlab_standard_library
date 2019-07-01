classdef persistent_value < handle
    %
    %   Class:
    %   sl.obj.persistent_value
    %
    %   Basically this class has a property that can be used
    %   to maintain state across function calls. Unlike persistent 
    %   values in functions, this can be tied to the holder of the object.
    %   This allows a single function to work with multiple persistent
    %   values.
    %
    %   This was written for plotting callbacks which want to track the 
    %   last ylim or xlim values that are handled by the function.
    %
    %   Example
    %   -------
    %   pv = sl.obj.persistent_value;
    %   pv.value = ax.YLim;
	%   addlistener(ax.YRuler,'MarkedClean',@(src, evt)h__yZoom(line_handles,ax,in,pv));
    %
    %   %in function h__yZoom
    %   ax = gca;
    %   if ~isequal(pv.value,ax.YLim)
    %       %then do expensive computation
    %       %update persistent value so we don't have to redo next time
    %       pv.value = ax.YLim
    %   end
    %   
    %
    %   See Also
    %   --------
    %   sl.plot.type.verticalLines
    
    properties
        value %main value to use
        aux_value %auxillary value to take with main value
    end
    
    methods
    end
end

