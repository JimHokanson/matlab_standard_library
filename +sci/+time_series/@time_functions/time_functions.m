classdef time_functions
    %
    %   Class:
    %   sci.time_series.time_functions
    
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
        data_objects
    end
    
    methods
        function obj = time_functions(data_objects)
            obj.data_objects = data_objects;
        end
        function value = getProp(obj,prop_name)
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
        function n_samples = durationToNSamples(obj,duration)
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
            
            dt = obj.getProp('dt');
            n_samples = floor(duration/dt) + 1;
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
            %       This specifies how far left
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
            
            start_index_1 = h__timeToSamples(dobj,start_times(1)+new_time_range(1));
            end_index_1   = h__timeToSamples(dobj,start_times(1)+new_time_range(2));
            
            dStart_index = indices(1) - start_index_1;
            dEnd_index   = end_index_1 - indices(1);
            
            n_samples_new = dEnd_index + dStart_index + 1;
            
            data_start_indices = indices - dStart_index;
            data_end_indices   = indices + dEnd_index;
            
            n_events = length(start_times);
            
            new_data = zeros(n_samples_new,dobj.n_channels,n_events,'like',dobj.d);
            cur_data = dobj.d;
            %TODO: Is this is rate limiting step, should we mex it ????
            for iEvent = 1:n_events
                cur_start = data_start_indices(iEvent);
                cur_end   = data_end_indices(iEvent);
                new_data(:,:,iEvent) = cur_data(cur_start:cur_end,:);
            end
            
            %TODO: This needs to be cleaned up ...
            %Ideally we could call a copy object method ...
            
            new_time_object = dobj.time.getNewTimeObjectForDataSubset(new_time_range(1),n_samples_new,'first_sample_time',new_time_range(1));
            
            event_aligned_data = sci.time_series.data(new_data,new_time_object);  
        end
        function removeOffset(obj)
           %TODO 
        end
        function zeroTimeByEvent(obj)
            
        end
        function resample(obj)
            
        end
    end
    
end

function samples = h__timeToSamples(obj,times)
samples = obj.time.getNearestIndices(times);
end
