classdef time_functions < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.time_functions
    %
    %   This class was created as a place to have code that works based on 
    %   manipulating some aspect of data timing.
    %
    %   See Also
    %   --------
    %   sci.time_series.time
    
    %TODO: We're going to
    
    %{
              getDataAlignedToEvent . :Aligns subsets of the data to a time
    %
    %
   removeTimeGapsBetweenObjects . :Removes any time gaps between objects (for plotting)
                       resample . :Change the sampling frequency of the data
                zeroTimeByEvent . :Redefines time such that the time of event is now at time zero.
    
    %}
    
    properties
        %Currently this is always singular ...
        data_objects
    end
    
    methods
        function obj = time_functions(data_objects)
            obj.data_objects = data_objects;
        end
        function value = getRawTime(obj)
            value = obj.data_objects.time.getTimeArray();
        end
        function value = getProp(obj,prop_name)
            %x Retrieves a time property from the objects
            %
            %   Retrieves a property from the time objects. Values are
            %   concatenated together for all objects.
            %
            %   This method is meant to get around the problem of doing:
            %   data.time.fs
            %   Where data is an array of objects
            %
            %   Examples
            %   --------
            %   data.ftime.getProp('fs')
            %   data.ftime.getProp('elapsed_time')
            %
            %   See Also
            %   --------
            %   sci.time_series.time
            objs = obj.data_objects;
            time_objs = [objs.time];
            temp = {time_objs.(prop_name)};
            if ischar(temp{1})
                value = temp;
            else
                value = [temp{:}];
            end
        end
        function values = getValuesAtTimes(obj,times)
            
            transpose_out = size(times,2) > 1;
            if transpose_out
                times = times';
            end
            
            I1 = obj.getNearestIndices(times,'round_operator',@floor);
            I2 = obj.getNearestIndices(times,'round_operator',@ceil);
            
            t1 = obj.getTimesFromIndices(I1);
            t2 = obj.getTimesFromIndices(I2);
            
            d1 = times - t1;
            d2 = times - t2;
            
            v1 = obj.data_objects.d(I1);
            v2 = obj.data_objects.d(I2);
            
            values = v1 + (times-t1).*(v2-v1)./(t2-t1);
            mask = t1 == t2;
            values(mask) = v1(mask); 
            if transpose_out
               values = values'; 
            end
        end
        function varargout = getNearestIndices(obj,times,varargin)
            %x Given a set of times, return the closest indices
            %
            %   [indices,result] = getNearestIndices(obj,times)
            %
            %   Inputs
            %   ------
            %   times : array of numerices
            %
            %   Optional Inputs
            %   ---------------
            %   TODO: Describe
            %
            %   Outputs
            %   -------
            %   indices :
            %   result : sci.time_series.time.nearest_indices_result
            %
            %   Improvements
            %   ------------
            %   1) Add on a reference object to ensure the same offset
            %   and time units.
            
            dobj = obj.data_objects;
            if length(dobj) > 1
                error('unhandled case')
            end
            [varargout{1:nargout}] = dobj.time.getNearestIndices(times,varargin{:});
        end
        function times = getTimesFromIndices(obj,indices)
            dobj = obj.data_objects;
            if length(dobj) > 1
                error('unhandled case')
            end
            times = dobj.time.getTimesFromIndices(indices);
        end
        function n_samples = durationToNSamples(obj,duration,varargin)
            %
            %   n_samples = durationToNSamples(obj,duration)
            %
            %   Returns the number of samples in a given duration. This
            %   value does not include the first sample at the beginning
            %   of the duration.
            %
            %   e.g. for duration = 2.2 seconds with a dt of 0.5
            %       |-----------------| 2.2 seconds
            %   t = 0  0.5  1  1.5  2
            %       x   x   x   x   x  - samples
            %           1   2   3   4  - count
            %   n_samples => 4 (not including the first one)
            %
            %   Optional Inputs
            %   ---------------
            %   method : default @floor
            %       The conversion from time to samples will not always be
            %       exact. This specifes how to convert from time
            %       to samples.
            %
            %       - @floor
            %       - 'floor'
            %       - @ceil
            %       - 'ceil'
            %       - @round
            %       - 'round'
            
            in.method = @floor;
            in = sl.in.processVarargin(in,varargin);
            
            if ischar(in.method)
                switch lower(in.method)
                    case 'floor'
                        fh = @floor;
                    case 'ceil'
                        fh = @ceil;
                    case 'round'
                        fh = @round;
                end
            else
                fh = in.method;
            end
            
            dt = obj.getProp('dt');
            
            %JAH: Not sure why I have + 1 here as it is wrong and even goes 
            %against my documentation, removing 2018-03-19
            %
            %n_samples = fh(duration/dt) + 1;
            
            n_samples = fh(duration/dt);
        end
        function event_aligned_data = getReps(obj,start_times,new_time_range,varargin)
            %x Aligns subsets of the data to a time
            %
            %   event_aligned_data = getDataAlignedToEvent(obj,event_times,new_time_range,varargin)
            %
            %   This function is useful for things like stimulus triggered
            %   averaging.
            %
            %   Inputs:
            %   -------
            %   event_times :
            %   new_time_range : [min max] with 0 being the event times
            %       This specifies how much data to grab around the event.
            %
            %   Optional Inputs:
            %   ----------------
            %   allow_overlap:  Not yet implemented ...
            %
            %
            %   Outputs:
            %   --------
            %   event_aligned_data
            %
            %   TODO: Provide an example of using this function.
            %
            %   See Also:
            %   sci.time_series.data.zeroTimeByEvent()
            %   sci.time_series.data.getDataSubset()
            
            %--------------------------------------------------------------
            %TODO: This needs to be cleaned up ...
            %--------------------------------------------------------------
            
            %TODO: Build in multiple object support ...
            
            in.add_start_event = false;
            in.allow_overlap = true;
            in = sl.in.processVarargin(in,varargin);
            
            dobj = obj.data_objects;
            if length(dobj) > 1
                error('Multiple objects not yet supported')
            end
            
            %TODO: Add history support ...
            
            if size(dobj.d,3) ~= 1
                error('Unable to compute aligned data when the 3rd dimension is not of size 1')
            end
            
            %TODO: Check for no events ...
            
            %???? - how should we adjust for time offsets where our
            %event_times are occuring between samples ????
            
            %What options do we want to implement ...
            
            %We could allow time range
            
            %TODO: What if things are out of range ...
            
            [indices,time_errors] = dobj.time.getNearestIndices(start_times);
            
            
            %TODO: Use h__getNewTimeObject
            
            %Lazy fix for when first event is too close to start of data
            %...
%             try
                start_index_1 = h__timeToSamples(dobj,start_times(1)+new_time_range(1));
                end_index_1   = h__timeToSamples(dobj,start_times(1)+new_time_range(2));
%             catch
%                 start_index_1 = h__timeToSamples(dobj,start_times(2)+new_time_range(1));
%                 end_index_1   = h__timeToSamples(dobj,start_times(2)+new_time_range(2));    
%             end
            
            dStart_index = indices(1) - start_index_1;
            dEnd_index   = end_index_1 - indices(1);
            
            n_samples_new = dEnd_index + dStart_index + 1;
            
            data_start_indices = indices - dStart_index;
            data_end_indices   = indices + dEnd_index;
            
            n_events = length(start_times);
            
            new_data = zeros(n_samples_new,dobj.n_channels,n_events,'like',dobj.d);
            cur_data = dobj.d;
            
            %TODO: Is this is a rate limiting step, should we mex it ????
            for iEvent = 1:n_events
                cur_start = data_start_indices(iEvent);
                cur_end   = data_end_indices(iEvent);
                new_data(:,:,iEvent) = cur_data(cur_start:cur_end,:);
            end
            
            %TODO: This needs to be cleaned up ...
            %Ideally we could call a copy object method ...
            %add some history as well
            
            %Creation of the new data object
            %-------------------------------
            new_time_object = dobj.time.getNewTimeObjectForDataSubset(...
                new_time_range(1),n_samples_new,'first_sample_time',new_time_range(1));
            
            event_aligned_data = sci.time_series.data(new_data,new_time_object,...
                'units',dobj.units,'y_label',dobj.y_label);
            
            prop_name = 'rep_start_times';
            %If we ever do filtering above we should filter here ...
            times = start_times;
            ev = sci.time_series.discrete_events(prop_name,times);
            event_aligned_data.event_info.addEvents(ev);
            
            old_history = dobj.history;
            
            event_aligned_data.addHistoryElements([old_history; {'new object with reps created from old object'}]);
            
        end
        function removeOffset(obj)
            d = obj.data_objects;
            for i = 1:length(d)
                cur_d = d(i);
                %Hold onto this for shifting events/epochs
                offset = cur_d.time.start_offset;
                cur_d.time.start_offset = 0;
                %Fix times for events/epochs
                cur_d.event_info.shiftTimes(offset);
            end
        end
        function setOffset(obj,value)
            d = obj.data_objects;
            for i = 1:length(d)
                cur_d = d(i);
                offset = cur_d.time.start_offset;
                
                %At 20, go to 5, subtract 15
                
                time_to_subtract = offset - value;
                
                cur_d.time.start_offset = value;
                
                cur_d.event_info.shiftTimes(time_to_subtract);
            end 
        end
        function zeroTimeByEvent(obj,event_name)
            %
            % Sets the time of the event(event_name) to be at t = 0
            %
            
            % data starts at 300
            % event occurs at 350
            % 
            d = obj.data_objects;
            for i = 1:length(d)
                cur_d = d(i);
                ev = cur_d.event_info.(event_name);
                
                %Hold onto this for shifting events/epochs
                start_offset = cur_d.time.start_offset;
                event_time = ev.times(1);
                cur_d.time.start_offset = start_offset-event_time;
                %Fix times for events/epochs
                cur_d.event_info.shiftTimes(event_time);
            end
        end
        function resample(obj)
            error('Not yet implemented')
        end
    end
    
end

function samples = h__timeToSamples(obj,times)
samples = obj.time.getNearestIndices(times);
end
