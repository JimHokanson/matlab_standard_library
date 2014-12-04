function s = getSubplotAxesHandles(fig_h)
%
%   sl.figure.getSubplotAxesHandles(fig_h)
%
%   Output:
%   -------
%   s : struct - ideally this would be a class
%                   sl.figure.results.subplot_handles_info
%   .grid_handles :
%       A matrix of handles. How are empties handled? Shape represents
%       the subplot shape.
  
    s = struct;
    
    %This should work in 2014b, not sure if it works earlier ...
    s.grid_handles = getappdata(fig_h, 'SubplotGrid');

    %TODO: Get all and compare against grid
    %return missing
    
    
    %temp = sl.figure.getAxes(fig_h);

%keyboard