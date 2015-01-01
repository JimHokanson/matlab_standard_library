classdef scrollbar < handle
    %
    %   Class:
    %   sl.gui.scrollbar
    %
    %
    %   Goal was to allow modifying the width of the slider of the
    %   scrollbar.
    %
    %
    %   NOTES:
    %   ------
    %   1) Changing the visible amount changes the value. Special steps
    %   were taken to reset the value to its appropriate location AND
    %   not to cause a callback during this process.
    %
    %   2) Changing the 'Value' via set(obj.m_handle,'Value',<new_value>)
    %   changes the scroll width. When we scroll however things are fine.
    %
    %
    %   Questions:
    %   ----------
    %   1) Does changing the j_value update the current_value????
    %
    %   TO FIX:
    %   -------
    %   1) Resizing the figure changes the width and the value ...
    %
    %   Tests:
    %   ------
    %   1) Change width
    
    
    %TODO: Allow updating value while sliding ...
    
    %Default slider:
    %{
                  Style: 'slider'
             String: ''
    BackgroundColor: [0.9400 0.9400 0.9400]
           Callback: ''
              Value: 0
           Position: [20 20 60 20]
              Units: 'pixels'

    
    %}
    
    properties
        m_handle %Matlab handle
        j_handle %Java handle
    end
    
    %TODO: Some of these should be observable ...
    properties (Dependent)
        value
        min
        max
        slider_width_pct
        slider_width %In user units
        
        %??? Will we use these?????
        minor_step %In user units
        major_step
        callback
    end
    properties (Hidden)
        user_callback %alias for callback
    end
    
    
    
    methods
        %Get Functions
        %--------------------------------------------
        function value = get.value(obj)
            %We rely on the Java value since the Matlab value is not
            %always in sync
            value = obj.min + (obj.max - obj.min)*obj.j_value_pct;
        end
        function value = get.min(obj)
            value = get(obj.m_handle,'Min');
        end
        function value = get.max(obj)
            value = get(obj.m_handle,'Max');
        end
        function value = get.slider_width_pct(obj)
            value = obj.j_visible_amount_pct;
        end
        function value = get.slider_width(obj)
            value = obj.j_visible_amount_pct*(obj.max - obj.min);
        end
        function value = get.callback(obj)
            value = obj.user_callback;
        end
        %Set Functions
        %--------------------------------------------
        function set.callback(obj,value)
            obj.user_callback = value;
        end
        function set.slider_width_pct(obj,value)
            %TODO: Enforce max and min ...
            obj.j_visible_amount_pct = value;
        end
        function set.minor_step(obj,value)
            obj.minor_step = value;
            temp = get(obj.m_handle,'SliderStep');
            temp(1) = value;
            set(obj.m_handle,'SliderStep',temp);
        end
    end
    
    %Hidden Java Stuffs
    properties
        d1 = '-------  Java Stuffs - Debug only ------'
    end
    properties (Dependent)
        j_value %The actual value associated with the slider
        j_value_pct  %This is how far along the slider we are, expressed
        %as a value from 0 to 1 where 0 indicates being all the way to
        %the left and 1 indicates being all the way to the right.
        j_centered_value
        j_minimum
        j_maximum
        j_range
        j_visible_amount
        %Settable
        j_visible_amount_pct
        %Settable
    end
    
    properties
        resize_fix_timer
        temp_callback_holder
        allow_running_callback = true
        lh %listener handles
        last_valid_j_centered
        last_valid_j_visible_amount
    end
    
    methods
        function delete(obj)
            delete(obj.lh)
            try %#ok<TRYNC>
                delete(obj.resize_fix_timer)
            end
        end
    end
    
    
    
    methods
        function handleSetRunningCallback(obj,value)
           %This was moved here to remove the mlint warnings when
           %it was in set.allow_running_callback
           if value
                if ~isempty(obj.temp_callback_holder)
                    set(obj.m_handle,'callback',obj.temp_callback_holder);
                    obj.temp_callback_holder = [];
                end
            else
                cb = get(obj.m_handle,'callback');
                if ~isempty(cb)
                    %This check is important as nested disables could set
                    %an already cleared callback to the temporary holding
                    %property, thus removing the actual callback
                    %
                    %    i.e. the following would be problamatic and would
                    %    occur with no isempty checks
                    %
                    %    obj.temp_callback_holder = real_callback
                    %    set(obj.m_handle,'callback','');
                    %    null_callback = get(obj.m_handle,'callback');
                    %    obj.temp_callback_holder = null_callback;
                    %
                    
                    obj.temp_callback_holder = cb;
                    set(obj.m_handle,'callback','');
                end
            end 
        end
        function set.allow_running_callback(obj,value)
            handleSetRunningCallback(obj,value) 
        end
        %Get methods
        %------------------------------------------------
        function value = get.j_value(obj)
            value = obj.j_handle.getValue;
        end
        function value = get.j_value_pct(obj)
            value = (obj.j_centered_value-obj.j_minimum)/obj.j_range;
        end
        function value = get.j_centered_value(obj)
            %The slider seems to be aligned to the left edge of the slider.
            %I want the value to correspond to the center of the slider.
            value = obj.j_value + 0.5*obj.j_visible_amount;
        end
        function value = get.j_minimum(obj)
            value = obj.j_handle.getMinimum;
        end
        function value = get.j_maximum(obj)
            value = obj.j_handle.getMaximum;
        end
        function value = get.j_range(obj)
            value = obj.j_maximum-obj.j_minimum;
        end
        function value = get.j_visible_amount(obj)
            value = obj.j_handle.getVisibleAmount;
        end
        function value = get.j_visible_amount_pct(obj)
            value = obj.j_visible_amount/obj.j_range;
        end
        %Set methods
        %-------------------------------------------------
        function set.j_value(obj,value)
            %Where does this get set ...
            %1) By anything setting this manually
            obj.j_handle.setValue(value);
            %This needs to occur after the setting has occured,
            %because we need the most up to date value from
            %get.j_value()
            obj.last_valid_j_centered = obj.j_centered_value;
        end
        function set.j_value_pct(obj,value)
            actual_value = value*obj.j_range + obj.j_minimum;
            obj.j_value = actual_value;
        end
        function set.j_centered_value(obj,value)
            left_value = value - 0.5*obj.j_visible_amount;
            obj.j_value = left_value;
        end
        function set.j_minimum(obj,value)
            %???? How does this change the slider value and
            %the width of the slider ????
            obj.j_handle.setMinimum(value);
        end
        function set.j_maximum(obj,value)
            obj.j_handle.setMaximum(value);
        end
        function set.j_visible_amount(obj,new_visible_amount)
            %The width expands left when we change it. Thus we set
            %the slider to the minimum, change the width, then reset
            %the value.
            %
            %If the width expands too much, then we need to adjust the
            %value as well.
            
            cur_centered_value = obj.j_centered_value;
            
            %Computed new value if width is too large
            %
            %   i.e. we can't have a 50% wide bar that is centered at 90%
            %   so we have to move to 75% so that +25% (1/2 of 50%) doesn't
            %   exceed 100%
            %-----------------------------------------
            new_visible_pct  = new_visible_amount/obj.j_range;
            cur_pct_location = obj.j_value_pct;
            if cur_pct_location + 0.5*new_visible_pct > 1
                %Shift left to accomodate
                value_changed = true;
                cur_centered_value = 1-0.5*new_visible_amount;
            elseif cur_pct_location - 0.5*new_visible_pct < 0
                %Shift right to accomodate
                value_changed = true;
                cur_centered_value = 0+0.5*new_visible_amount;
            else
                value_changed = false;
            end
            
            obj.allow_running_callback = false;
            obj.j_value = obj.j_minimum;
            
            %Make the actual change to the underlying java object
            obj.j_handle.setVisibleAmount(new_visible_amount);
            
            %These drawnow are important to prevent tons of callbacks
            %from running
            if value_changed
                drawnow
                obj.allow_running_callback = true;
                obj.j_centered_value = cur_centered_value;
            else
                obj.j_centered_value = cur_centered_value;
                drawnow
                obj.allow_running_callback = true;
            end
            
            obj.last_valid_j_visible_amount = new_visible_amount;
        end
        function set.j_visible_amount_pct(obj,value)
            value_to_set = round(value*obj.j_range);
            obj.j_visible_amount = value_to_set;
        end
    end
    
    %Constructor ----------------------------------------
    methods
        function obj = scrollbar(figure_handle,varargin)
            %
            %
            %    NOTE:
            
            %obj.figure_handle = figure_handle;
            
            if verLessThan('matlab', '8.4')
                size_cb = {'Position', 'PostSet'};
            else
                size_cb = {'SizeChanged'};
            end
            
            obj.lh = addlistener(figure_handle,size_cb{:},@(~,~)cb_figureSizeChanged(obj));
            
            obj.m_handle = uicontrol('style','slider',varargin{:});
            
            %We hold onto the user callback, then use our own. The user
            %can change the callback at any time by setting obj.callback
            %which is an alias for obj.user_callback
            obj.user_callback = get(obj.m_handle,'callback');
            set(obj.m_handle,'callback',@obj.cb_valueChanged);
            
            %Why is this sometimes an array????
            obj.j_handle = sl.java.findjobj(obj.m_handle);
            
            obj.last_valid_j_centered = obj.j_centered_value;
            obj.last_valid_j_visible_amount = obj.j_visible_amount;
            
        end
    end
    
    %Callbacks ------------------------------------------------------------
    methods
        function cb_valueChanged(obj,h,event,varargin)
            %
            %   We wrap the callback so that we can not run it in cases
            %   where we are doing something that would cause the callback
            %   to fire (that we can't stop) and where we don't really
            %   want the callback to run
            disp('Trying callback')
            if obj.allow_running_callback
                obj.last_valid_j_centered = obj.j_centered_value;
                h__execute_callback(obj.user_callback,h,event,varargin{:})
            end
        end
        function cb_figureSizeChanged(obj)
            %
            %   This took way too long to get somewhat working.
            %   Unfortunately I still don't understand how to properly fix
            %   the problem, I've only applied a hack which should
            %   hopefully work 99% of the time.
            
            TIMER_START_DELAY = 0.1;
            
            %Timer handling
            %--------------
            try %#ok<TRYNC>
                temp_timer = obj.resize_fix_timer;
                stop(temp_timer);
                delete(temp_timer)
                obj.resize_fix_timer = [];
            end
            
            t = timer;
            set(t,'StartDelay',TIMER_START_DELAY,'ExecutionMode','singleShot');
            set(t,'TimerFcn',@(~,~)obj.fixFigureResizeIssues)
            start(t)
            obj.resize_fix_timer = t;
        end
        function fixFigureResizeIssues(obj)
            obj.allow_running_callback = false;
            
            %Move back to value first, then adjust width
            %Reversing this order could mean that the width is too big
            %and that the value subsequently gets changed
            obj.j_centered_value = obj.last_valid_j_centered;
            obj.j_visible_amount = obj.last_valid_j_visible_amount;
            
            obj.allow_running_callback = true;
        end
    end
    
    
    
    methods (Hidden)
        
    end
    
end


function h__execute_callback(cb, h, event, varargin)
if ~isempty(cb)
    if isa(cb, 'function_handle')
        cb(h, event)
    elseif iscell(cb)
        cb(h, event, varargin{:})
    else
        eval(cb);
    end
end
end
