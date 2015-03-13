function s = getSubplotAxesHandles(figure_handle)
%
%   s = sl.figure.getSubplotAxesHandles(figure_handle)
%
%   Output:
%   -------
%   s : struct - ideally this would be a class
%                   sl.figure.results.subplot_handles_info
%   .grid_handles :
%       A matrix of handles. How are empties handled? 
%              empty => GraphicsPlaceholder with no properties.
%       Shape represents the subplot shape.
%   .is_valid : logical mask
%           Not yet implemented, should identify non-GraphicsPlaceholders

%{
%Testing code
subplot(2,2,1)
plot(1:10)
xlabel('testing')
subplot(2,2,2)
plot(1:20)
subplot(2,2,3)
plot(1:30)
subplot(2,2,4)
plot(1:40)
xlabel('testing')
s = sl.hg.figure.getSubplotAxesHandles(gcf)


%In prerelease for 2015a this doesn't work, returns null for one of the
handles ...
%WTF ...
subplot(2,1,1)
plot(1:10)
xlabel('testing')
subplot(2,1,2)
plot(2:20)
xlabel('testing')
s = sl.hg.figure.getSubplotAxesHandles(gcf)


%}
  

%TODO: It looks like this doesn't return things in grid order ...
%wtf matlab ;asdfalsdfklaslkdfla;sdlkfals;dflk;

    s = struct;
    
    %This should work in 2014b, not sure if it works earlier ...
    %Works in 2014a
    %There is a bug in 2015a
    s.grid_handles = flipud(getappdata(figure_handle, 'SubplotGrid'));

    %TODO: Get all and compare against grid
    %return missing
    
    
    %temp = sl.figure.getAxes(fig_h);

%keyboard