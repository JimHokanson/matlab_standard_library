classdef event_and_listener_info
    %
    %   Class:
    %   sl.hg.event_and_listener_info
    %
    %  The goal of this class is to manage information on events and
    %  listeners that are available (or set?) for a given graphics object
    %
    %
    %   Improvements:
    %   -------------
    %   1) Implement information on properties that can be observed
    %   2) Allow extraction of additional callbacks using findjobj
    %   3) Start explicit documentation of events to supplement publically
    %   available documentation - e.g. ActionEvent vs ContinuousValueChange
    %   4) Provide information on what values have been set (e.g. what
    %   callbacks have been set and what listeners exist)
    
    
    %http://www.mathworks.com/matlabcentral/answers/159763-list-of-event-listeners-for-handle-graphics
    %http://www.mathworks.com/matlabcentral/answers/94346-how-can-i-remove-a-callback-function-from-my-uicontrol-in-matlab-7-10-r2010a
    %http://www.mathworks.com/matlabcentral/answers/56325-where-is-a-list-of-eventtypes-for-listeners
    
    %http://undocumentedmatlab.com/blog/introduction-to-udd/
    %http://undocumentedmatlab.com/blog/udd-events-and-listeners
    %http://undocumentedmatlab.com/blog/udd-and-java
    %http://undocumentedmatlab.com/blog/uicontrol-callbacks
    %http://undocumentedmatlab.com/blog/matlab-hg2
    
    %-hgVersion 2
    %"C:\Program Files\MATLAB\R2014a\bin\matlab.exe" - hgVersion 2
    %feature( 'HGUsingMATLABClasses' ) - read only
    %set(0,'HideUndocumented','off');
    %{
    
    %hg2utils.HGCustomMetaClass NOT 
    temp = ?matlab.graphics.axis.Axes %works in 2013a
    But this seems to be refering to the hg2 object, not an hg object
    
    %}
    
    properties
       event_names
       %What should we do about properties ?????
    end
    
    methods
        function obj = event_and_listener_info(graphics_handle)
            %
            %
            %    obj = sl.hg.event_and_listener_info(graphics_handle)
            %
            %    Example:
            %    --------
            %    obj = sl.hg.event_and_listener_info(gca)
            %    h = uicontrol('style','slider')
            %    obj = sl.hg.event_and_listener_info(h)
            
            if isnumeric(graphics_handle)
                use_hg1 = true;
            else
                class_info = metaclass(graphics_handle);
                use_hg1 = isempty(class_info);
            end
            
            if use_hg1
                if isnumeric(graphics_handle)
                    class_info = classhandle(handle(graphics_handle));
                elseif ishghandle(graphics_handle)
                    class_info = classhandle(graphics_handle);
                    %TODO: Check for schema.class
                    if ~isa(class_info,'schema.class')
                       error('Unexpected type') 
                    end
                else
                    error('Unrecognized graphics handle type')
                end
                
                %class_info : schema.class
                %
                %
                %TODO: Populate properties as well ...
                
                events = class_info.Events;
                
                event_names_local = cell(1,length(events));
                for iEvent = 1:length(events)
                    event_names_local{iEvent} = events(iEvent).Name;
                end
                
            else
                %Already set from call above
                %class_info : matlab.graphics.internal.GraphicsMetaClass
                event_names_local = {class_info.EventList.Name};
                %NotifyAccess public
                %ListenAccess public
            end
            
            obj.event_names = event_names_local;
        end
    end
    
end

