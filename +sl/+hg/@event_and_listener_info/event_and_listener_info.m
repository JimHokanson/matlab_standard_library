classdef event_and_listener_info
    %
    %   Class:
    %   sl.hg.event_and_listener_info
    %
    %  
    
    %http://www.mathworks.com/matlabcentral/answers/94346-how-can-i-remove-a-callback-function-from-my-uicontrol-in-matlab-7-10-r2010a
    %http://www.mathworks.com/matlabcentral/answers/56325-where-is-a-list-of-eventtypes-for-listeners
    
    %{
    Old:
    matlab.graphics.axis.Axes - how would we know this???
    This was originally noted by getting the class from 2014b
    class(gca) %in 2014b
    temp = ?matlab.graphics.axis.Axes %works in 2013a
    %}
    
    properties
    end
    
    methods
       %TODO: One approach, brute force test set and get observable on properties
       %TODO: Try and get java object,
    end
    
end

