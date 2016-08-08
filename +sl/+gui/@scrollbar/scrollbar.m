classdef scrollbar < handle
    %
    %   Class:
    %   sl.gui.scrollbar
    %
    %   This class wraps the uicontrol('style','slider') object. Unlike
    %   that version, this one supports modification of the slider width.
    %
    %   Development Notes:
    %   ------------------
    %   1) Changing the slider width changes the value. Special steps
    %   were taken to reset the value to its appropriate location AND
    %   not to cause a callback during this process.
    %
    %   2) Changing the 'Value' via set(obj.m_handle,'Value',<new_value>)
    %   changes the scroll width. When we scroll however the scroll width
    %   does not change. Since this change occurs, we only work with the
    %   underlying Java value, instead of making the above call to the
    %   Matlab value.
    %
    %
    %   Questions:
    %   ----------
    %   1) Does changing the j_value update the current_value????
    %
    %       It doesn't matter, since we rely on the Java value to give us
    %       the correct value. It does not currently throw a callback
    %       event.
    %
    %   TO FIX:
    %   -------
    %   1) FIXED Resizing the figure changes the width and the value ...
    %
    %   Tests:
    %   ------
    %   1) Change width
    %   2) Resize figure, does width and value stay the same????
    %
    %   Improvements:
    %   -------------
    %   1) allow updating value while sliding
    %
    %
    %   Callback behavior:
    %   ------------------
    %   1) Thrown when setting value
    %   2) Not thrown for width, unless value unexpectedly changes
    %   3) Not thrown when setting span
    
    %
    %   Resizing Problem
    %   ----------------
    %   1) On resize, width and value are lost
    %   2) ResizeFcn callback doesn't work
    %       - it seems to after adding a drawnow
    %   3) Single shot timer after callback is inconsistent
    %   4) Continuous timer prevents value from being updated properly
    %       when the user is interacting with it
    
    %{
    clear all
    close all
    plot(0:100)
    p = get(gca,'position');
    set(gca,'xlim',[0 100])
    s = sl.gui.scrollbar(gcf,...
                'units','normalized',...
                'position',[p(1) 0.02 p(3) 0.03],...
                'Value',50,...
                'min',0,...
                'max',100,...
                'callback',@(~,~)disp('callback ran'));
    
    s.slider_width_pct = 0.4;
    s.slider_width = 60;
    s.j_visible_amount = 1;
    s.j_visible_amount = 0.00001; %This is apparently fine
    s.value_span = [10 70];
    
    %TODO: Try testing changing max and mins
    
    %}
    
    %Matlab and Java handles ----------------------------------------------
    properties (Hidden)
        %In general the user of this class should never manipulate these
        %values
        m_handle %Matlab handle
        j_handle %Java handle
    end
    
    properties
        update_value_when_sliding
    end
    
    %TODO: Some of these should be observable ...
    %Main properties to edit/interact with --------------------------------
    properties (Dependent)
        value %We're relating this to j_centered_value
        value_span
        min
        max
        slider_width_pct
        slider_width %In user units
        
        %??? Will we use these?????
        minor_step %In user units
        major_step
        callback
        continuous_callback
    end
    
    properties (Hidden)
        user_callback %alias for callback
        user_quick_callback
    end
    
    %Get & Set methods for above properties -------------------------------
    methods
        %Get Functions
        %--------------------------------------------
        function value = get.value(obj)
            %We rely on the Java value since the Matlab value is not
            %always in sync
            value = obj.min + (obj.max - obj.min)*obj.j_centered_value_pct;
        end
        function value = get.value_span(obj)
            
            j_centered_local = obj.j_centered_value;
            j_visible_local = obj.j_visible_amount;
            j_values = [...
                j_centered_local - 0.5*j_visible_local ...
                j_centered_local + 0.5*j_visible_local];
            value = h__jValuesToValues(obj,j_values);
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
        function value = get.continuous_callback(obj)
            value = obj.user_quick_callback;
        end
        %Set Functions
        %--------------------------------------------
        function set.value(obj,new_value)
            %NOTE: Our value range is limited by the width
            %of the slider
            half_range = 0.5*(obj.max - obj.min);
            if new_value - half_range < obj.min
                %NOPE
                disp('too left')
            elseif new_value + half_range > obj.min
                %NOPE
                disp('too right')
            end
            temp = h__valuesToJValues(obj,new_value);
            obj.j_centered_value = temp;
        end
        function set.value_span(obj,value)
            
            %TODO: Check span values - 2, 2nd is greater than the first
            
            %Design Decision: We won't throw the callback when this is set
            %...
            
            width = value(2)-value(1);
            centered_value = value(1)+0.5*width;
            
            %We need to adjust the value and width. The order of these calls
            %is chosen very carefully
            obj.slider_width_pct = 0.00001; %very small so that any value
            %is hopefully valid
            obj.allow_running_callback = false;
            obj.j_centered_value = h__valuesToJValues(obj,centered_value);
            obj.allow_running_callback = true;
            obj.slider_width = width;
        end
        function set.callback(obj,value)
            obj.user_callback = value;
        end
        function set.continuous_callback(obj,value)
            obj.user_quick_callback = value;
        end
        function set.slider_width_pct(obj,value)
            %This value isn't super critical, as Java has a check
            %as well for too small values
            MIN_SLIDER_PCT = 0.00001;
            
            if value > 1
                %TODO: Throw warning
                value = 1;
            elseif value < MIN_SLIDER_PCT
                if value < 0
                    %TODO: throw warning
                end
                value = MIN_SLIDER_PCT;
            end
            obj.j_visible_amount_pct = value;
        end
        function set.slider_width(obj,value)
            obj.slider_width_pct = value/(obj.max - obj.min);
        end
        function set.minor_step(obj,value)
            obj.minor_step = value;
            temp = get(obj.m_handle,'SliderStep');
            temp(1) = value;
            set(obj.m_handle,'SliderStep',temp);
        end
    end
    
    %Java Stuffs ---------------------------------------------------
    properties
        d1 = '-------  Java Stuffs - Debug only ------'
    end
    properties (Dependent)
        j_value %The actual value associated with the slider
        
        %The above value is aligned to the left of the slider, these are
        %based on the center of the slider.
        
        j_centered_value
        j_centered_value_pct
        
        j_min
        j_max
        j_range
        
        %Slider widths:
        j_visible_amount
        %Settable
        j_visible_amount_pct
        %Settable
    end
    
    %Get & Set methods for Java properties -------------------------------
    methods
        %         function handleSetRunningCallback(obj,value)
        %             %This was moved here to remove the mlint warnings when
        %             %it was in set.allow_running_callback
        %             if value
        %                 if ~isempty(obj.temp_callback_holder)
        %                     set(obj.m_handle,'callback',obj.temp_callback_holder);
        %                     obj.temp_callback_holder = [];
        %                 end
        %             else
        %                 cb = get(obj.m_handle,'callback');
        %                 if ~isempty(cb)
        %                     %This check is important as nested disables could set
        %                     %an already cleared callback to the temporary holding
        %                     %property, thus removing the actual callback
        %                     %
        %                     %    i.e. the following would be problamatic and would
        %                     %    occur with no isempty checks
        %                     %
        %                     %    obj.temp_callback_holder = real_callback
        %                     %    set(obj.m_handle,'callback','');
        %                     %    null_callback = get(obj.m_handle,'callback');
        %                     %    obj.temp_callback_holder = null_callback;
        %                     %
        %
        %                     obj.temp_callback_holder = cb;
        %                     set(obj.m_handle,'callback','');
        %                 end
        %             end
        %         end
        %         function set.allow_running_callback(obj,value)
        %             handleSetRunningCallback(obj,value)
        %         end
        %Get methods
        %------------------------------------------------
        function value = get.j_value(obj)
            value = obj.j_handle.getValue;
        end
        %         function value = get.j_value_pct(obj)
        %             value = (obj.j_value-obj.j_min)/obj.j_range;
        %         end
        function value = get.j_centered_value(obj)
            %The slider seems to be aligned to the left edge of the slider.
            %I want the value to correspond to the center of the slider.
            value = obj.j_value + 0.5*obj.j_visible_amount;
        end
        function value = get.j_centered_value_pct(obj)
            value = (obj.j_centered_value-obj.j_min)/obj.j_range;
        end
        function value = get.j_min(obj)
            value = obj.j_handle.getMinimum;
        end
        function value = get.j_max(obj)
            value = obj.j_handle.getMaximum;
        end
        function value = get.j_range(obj)
            value = obj.j_max-obj.j_min;
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
            obj.j_handle.setValue(value);
            
            %This needs to occur after the setting has occured,
            %because we need the most up to date value from
            %get.j_value()
            obj.last_valid_j_centered = obj.j_centered_value;
        end
        function set.j_centered_value(obj,value)
            left_value = value - 0.5*obj.j_visible_amount;
            obj.j_value = left_value;
        end
        function set.j_centered_value_pct(obj,value)
            obj.j_centered_value = value*obj.j_range + obj.j_min;
        end
        function set.j_min(obj,value)
            %???? How does this change the slider value and
            %the width of the slider ????
            obj.j_handle.setMinimum(value);
        end
        function set.j_max(obj,value)
            obj.j_handle.setMaximum(value);
        end
        function set.j_visible_amount(obj,new_visible_amount)
            %The width expands left when we change it. Thus we set
            %the slider to the minimum, change the width, then reset
            %the value.
            %
            %If the width expands too much, then we need to adjust the
            %value as well.
            
            cur_pct_location = obj.j_centered_value_pct;
            
            %Computed new value if width is too large
            %
            %   i.e. we can't have a 50% wide bar that is centered at 90%
            %   so we have to move to 75% so that +25% (1/2 of 50%) doesn't
            %   exceed 100%
            %-----------------------------------------
            new_visible_pct  = new_visible_amount/obj.j_range;
            if cur_pct_location + 0.5*new_visible_pct > 1
                %Shift left to accomodate
                value_changed = true;
                cur_pct_location = 1-0.5*new_visible_pct;
            elseif cur_pct_location - 0.5*new_visible_pct < 0
                %Shift right to accomodate
                value_changed = true;
                cur_pct_location = 0+0.5*new_visible_pct;
            else
                value_changed = false;
            end
            
            obj.allow_running_callback = false;
            obj.j_value = obj.j_min;
            
            %Make the actual change to the underlying java object
            obj.j_handle.setVisibleAmount(new_visible_amount);
            
            %These drawnow are important to prevent tons of callbacks
            %from running
            if value_changed
                drawnow
                obj.allow_running_callback = true;
                obj.j_centered_value_pct = cur_pct_location;
            else
                obj.j_centered_value_pct = cur_pct_location;
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
    
    %Internal Properties  --------------------------------------
    properties
        d2 = '------   Internal Properties - Debug Only --------'
        % % % %         resize_fix_timer %Holds a timer so that the timer stays in scope.
        % % % %         %The timer fixes what Matlab breaks after the function is resized
        % % % %         temp_callback_holder
        allow_running_callback = true %We can this to be false when
        %we are doing things that we know will cause the callback to run
        %(such as adjusting the slider width).
        %
        %Callbacks should check this value before throwing the callback.
        last_resize_time = now
        last_valid_j_centered
        last_valid_j_visible_amount
    end
    
    %Constructor & Delete ----------------------------------
    methods
        function obj = scrollbar(h_figure,varargin)
            %
            %   obj = sl.gui.scrollbar(h_figure,varargin)
            %
            %   Optional Inputs:
            %   ----------------
            %   All optional inputs are passed to the uicontrol input
            %
            %   Example:
            %   --------
            %       obj.s = sl.gui.scrollbar(h_figure,...
            %           'units','normalized',...
            %           'position',DEFAULT_POSITION,...
            %           'Value',0.5*diff(xlim_temp) + xlim_temp(1),...
            %           'min',xlim_temp(1),...
            %           'max',xlim_temp(2),...
            %           'callback',@(~,~)obj.CB_sliderValueChanged());
            %
            
            
            %obj.figure_handle = figure_handle;
            
            set(h_figure,'ResizeFcn',@(~,~)cb_figureSizeChanged(obj));
            
            obj.m_handle = uicontrol('style','slider',varargin{:});
            
            %We hold onto the user callback, then use our own. The user
            %can change the callback at any time by setting obj.callback
            %which is an alias for obj.user_callback
            obj.user_callback = get(obj.m_handle,'callback');
            set(obj.m_handle,'callback',@obj.cb_valueChanged);
            
            %Why is this sometimes an array????
            %I think because it does position matching for filtering
            %and if we create two instances of the scrollbar then we get
            %two results
            %
            %TODO: We should do an explicit check for a found result
            obj.j_handle = sl.java.findjobj(obj.m_handle);
            
            %This allows callbacks to be thrown while the slider is being
            %dragged, not just when it stops
            %http://undocumentedmatlab.com/blog/continuous-slider-callback
            obj.j_handle.AdjustmentValueChangedCallback = @obj.cb_quickValueChanged;
            
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
            %   want the callback to run.
            %
            %   One example of this is when we resize the scrollbar width.
            %
            %
            if obj.allow_running_callback
                %I added this to try and prevent the resize from preventing
                %value changes from occuring ...
                %disp('Slow callback ran')
                obj.allow_running_callback = false;
                obj.last_valid_j_centered = obj.j_centered_value;
                h__execute_callback(obj.user_callback,h,event,varargin{:})
                obj.allow_running_callback = true;
            end
        end
        function cb_quickValueChanged(obj,varargin)
            %
            %
            %   This runs whenever we drag the slider
            
            MIN_WAIT_FOLLOWING_RESIZE = 0.3; %in seconds
            %This gets executed whenever the
            if obj.allow_running_callback
                if now - obj.last_resize_time > MIN_WAIT_FOLLOWING_RESIZE/86400
                    %disp('Quick callback ran')
                    obj.allow_running_callback = false;
                    %NO: DONT SET THIS HERE
                    %obj.last_valid_j_centered = obj.j_centered_value;
                    h__execute_callback(obj.user_quick_callback,varargin{:})
                    obj.allow_running_callback = true;
                end
            end
        end
        function cb_figureSizeChanged(obj,varargin)
            
            obj.last_resize_time = now;
            %I think this is critical for ensuring that any changes to the
            %slider made by Matlab come before the corrections that I am
            %trying to make in this function
            %disp('Fixin figure')
            drawnow
            
            obj.allow_running_callback = false;
            %Move back to value first, then adjust width
            %Reversing this order could mean that the width is too big
            %and that the value subsequently gets changed
            obj.j_centered_value = obj.last_valid_j_centered;
            obj.j_visible_amount = obj.last_valid_j_visible_amount;
            
            obj.allow_running_callback = true;
            
        end
    end
    
end


function h__execute_callback(cb, h, event, varargin)
%Borrowed from LinePlotReducer
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
function j_values = h__valuesToJValues(obj,values)
value_pct = (values - obj.min)/(obj.max - obj.min);
j_values = obj.j_min + value_pct*obj.j_range;
end
function values = h__jValuesToValues(obj,j_values)
j_value_pcts = (j_values - obj.j_min)/obj.j_range;
values = obj.min + j_value_pcts*(obj.max - obj.min);
end
