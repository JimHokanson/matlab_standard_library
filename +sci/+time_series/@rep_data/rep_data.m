classdef rep_data < sl.obj.handle_light
    %
    %   Class:
    %   sci.time_series.rep_data
    %
    %   See Also
    %   --------
    %   sci.time_series.data
    
    properties
        d %[time x reps]
        time sci.time_series.time
        units
        channel_label
        y_label
        user_data
    end
    
    properties
       history = {}
       event_info
    end
    
  	properties (Dependent)
        event_names
        n_reps
        n_samples
        subset
        ftime
    end
    
    
  	methods
        function value = get.event_names(obj)
            value = obj.event_info.p__all_event_names;
        end
        function value = get.n_samples(obj)
            value = size(obj.d,1);
        end
        function value = get.n_reps(obj)
            value = size(obj.d,2);
        end
        function value = get.subset(obj)
            %This only works well for a single object
            %TODO: use input_name and check for single value ...
            %- throw error if not a single object ...
            %crap - but then we run into indexing problems ...
            value = sci.time_series.subset_retrieval(obj);
        end
        function value = get.ftime(obj)
            value = sci.time_series.time_functions(obj);
        end
    end
    
    methods (Static)
        function obj = fromData(d)
            %
            %   obj = sci.time_series.rep_data.fromData(d);
            %
            if d.n_channels ~= 1
                error('Code only supports a single channel')
            end
            raw_data = squeeze(d.d);
            if d.n_samples == 1
               raw_data = raw_data';
            end
            
            temp = d.channel_labels;
            if iscell(temp)
                chan_label = temp{1};
            else
                %Assuming string
                chan_label = temp;
            end
                
            %???? Transfer events?????
            %
            %   No ....
            %
            %   But we need to support adding events ...
            
            obj = sci.time_series.rep_data(raw_data,d.time,...
                'units',d.units,'y_label',d.y_label,...
                'channel_label',chan_label);
            
            obj.history = d.history;
            obj.addHistoryElements('changed object type from ''data'' to ''rep_data''');
        end
    end
    
    methods
        function obj = rep_data(raw_data,time,varargin)
            in.history = {};
            in.units   = 'Unknown';
            in.channel_label = ''; %TODO: If numeric, change to string ...
            in.events  = [];
            in.y_label = '';
            in = sl.in.processVarargin(in,varargin);
            
            obj.d = raw_data;
            obj.time = time;
            
            obj.units = in.units;
            obj.channel_label = in.channel_label;
            obj.y_label = in.y_label;
            obj.history = in.history;
            obj.user_data = struct();
            
            %Events - NYI
            
        end
        function new_objs = copy(old_objs,varargin)
            %x Creates a deep copy of the object
            %
            %   new_objs = copy(old_objs)
            %
            %   This allows someone to make changes to the properties
            %   without it also changing the original object.
            %
            %   Optional Inputs
            %   ---------------
            %   time : sci.time_series.time
            %       New time objects.
            %   raw_data : array or cell array of arrays
            %       NOTE, currently changing the # of channels is not
            %       supported with this approach or requires specifying
            %       a new time object as well.
            %   dt : scalar or array
            %       Inverse of the sampling rate
            %   new_start_offset : scalar or array
            %       AKA t0
            %
            %   See Also:
            %   ---------
            %   sci.time_series.events_holder
            %   sci.time_series.time
            
            in.time = [];
            in.units = {};
            in.raw_data = [];
            in.dt = [];
            in.new_start_offset = [];
            in = sl.in.processVarargin(in,varargin);
            
            n_objs    = length(old_objs);
            temp_objs = cell(1,n_objs);
            
            if isempty(in.raw_data)
                local_n_samples = [];
                raw_data = {old_objs.d};
            elseif iscell(in.raw_data)
                local_n_samples = cellfun('length',in.raw_data);
                raw_data = in.raw_data;
            else
                local_n_samples = length(in.raw_data);
                raw_data = {in.raw_data};
            end
            
            if isempty(in.units)
                local_units = {old_objs.units};
            elseif iscell(in.units)
                local_units = in.units;
            else
                local_units = repmat({in.units},1,n_objs);
            end
            
            old_time_objs = [old_objs.time];
            if ~isempty(in.time)
                new_time_objs = in.time;
            else
                new_time_objs = copy([old_objs.time],...
                'new_start_offset',in.new_start_offset,...
                'dt',in.dt,'n_samples',local_n_samples);
            end
            
            for iObj = 1:n_objs
                time_shift = old_time_objs(iObj).start_offset-new_time_objs(iObj).start_offset;
                cur_obj = old_objs(iObj);
%                 new_event_obj = copy(cur_obj.event_info,new_time_objs(iObj),...
%                     'time_shift',time_shift);
                temp_objs{iObj} = sci.time_series.rep_data(...
                    raw_data{iObj},...
                    new_time_objs(iObj),...
                    'history',      cur_obj.history,...
                    'units',        local_units{iObj},...
                    'channel_label',cur_obj.channel_label,...
                    'events',       [],...
                    'y_label',      cur_obj.y_label);
                
                temp_objs{iObj}.user_data = cur_obj.user_data;
            end
            
            new_objs = [temp_objs{:}];
        end
        function plot(obj,varargin)
            
            in.x_units = 'ms';
            in = sl.in.processVarargin(in,varargin);
            
            [t,x_str] = h__changeXUnits(obj.time.getTimeArray,in);
            
            plot(t,obj.d)
            hold on
            plot(t,mean(obj.d,2),'k','Linewidth',3);
            hold off
            ylabel(sprintf('%s (%s)',obj.y_label,obj.units));
            xlabel(x_str);
        end
        function plotAvg(obj,varargin)
            
            in.x_units = 'ms';
            [in,new_units] = sl.in.processVararginWithRemainder(in,varargin);
            
            [t,x_str] = h__changeXUnits(obj.time.getTimeArray,in);
            
            plot(t,mean(obj.d,2),new_units{:});
            ylabel(sprintf('%s (%s)',obj.y_label,obj.units));
            xlabel(x_str);
        end
        function varargout = dropEvenReps(obj)
            if nargout
                temp = copy(obj);
            else
                temp = obj;
            end
            
            temp.dropReps(2:2:obj.n_reps,'dropping odd reps');
            
            if nargout
                varargout{1} = temp;
            end
        end
        function varargout = dropOddReps(obj)
            if nargout
                temp = copy(obj);
            else
                temp = obj;
            end
            
            temp.dropReps(1:2:obj.n_reps,'dropping odd reps');
            
            if nargout
                varargout{1} = temp;
            end
        end
        function varargout = dropReps(obj,indices,msg)
            
            if nargout
                temp = copy(obj);
            else
                temp = obj;
            end

            n_reps_old = temp.n_reps;
            
            temp.d(:,indices) = [];
            
            n_reps_new = temp.n_reps;            
            n_dropped = n_reps_old - n_reps_new;
            
            if nargin == 2
                msg = sprintf('dropping %d reps, from %d to %d',n_dropped,min(indices),max(indices));
            end
            
            temp.addHistoryElements(msg);
            
            if nargout
                varargout{1} = temp;
            end
            
        end
    	function out_objs = mean(objs,dim,varargin)
            %
            %
            %   Improvements
            %   ------------
            %   Support returning an object from this ...
            
            if nargin == 1 || isempty(dim)
                dim = 1;
            end
            n_objs = length(objs);
            output = cell(1,n_objs);
            
            for iObj = 1:length(objs)
                output{iObj} = mean(objs(iObj).d,dim);
            end
            
            out_objs = [output{:}];
            
        end
    	function out_objs = minus(A,B)
            %x Performs the minus operation
            %
            %   out_objs = minus(A,B)
            %
            %   out_objs = A - B;
            %
            %   Note, this function currently always makes a copy. The copy
            %   operation in the dual object case is a bit ambiguous, as
            %   both object have history and names. Currently the first
            %   objects properties are copied in this case.
            %
            %
            
            %NOTE: We are supporting either a 1:1 length match for objects
            %or the case where A or B is an object or array of objects, and
            %the other input is an array.
            
            if isobject(A) && isobject(B)
                out_objs = copy(A);
                for iObj = 1:length(A)
                    out_objs(iObj).d = A(iObj).d - B(iObj).d;
                end
            elseif isobject(A)
                out_objs = copy(A);
                for iObj = 1:length(A)
                    out_objs(iObj).d = A(iObj).d - B;
                end
            else
                out_objs = copy(B);
                for iObj = 1:length(A)
                    out_objs(iObj).d = A - B(iObj).d;
                end
            end
            
        end
    	function addHistoryElements(obj,history_elements)
            %x Adds history elements (processing summaries) to the object
            %
            %   addHistoryElements(obj,history_elements)
            %
            %   Inputs:
            %   -------
            %   history_elements : cell or string
            %       See definition of the 'history' property in this class
            %
            if iscell(history_elements)
                if size(history_elements,2) > 1
                    history_elements = history_elements';
                end
            elseif ischar(history_elements)
                history_elements = {history_elements};
            else
                error('Invalid history element type')
            end
            
            obj.history = [obj.history; history_elements];
        end
        function changeUnits(objs,new_units,varargin)
            %x Given the new units, scales/converts the data accordingly
            %
            %
            %
            %   HIGHLY EXPERIMENTAL
            %   Relies on sci.units.getConversionFunction which is woefully
            %   incomplete and is basically only hardcoded for the values
            %   I'm using.
            %
            %   Inputs
            %   ------
            %   new_units : string
            %
            %   Optional Inputs
            %   ---------------
            %   rename_only : default false
            %       If true no scaling is done, the units are simply
            %       renamed.
            %
            %   Example:
            %   --------
            %   raw_data = sci.time_series.data(ones(100,1),1,'units','V')
            %   plot(raw_data)
            %   raw_data.changeUnits('mV')
            %   hold all
            %   plot(raw_data) %This will be 1000x larger
            %
            %
            %
            %
            %   See Also:
            %   sci.units.getConversionFunction
            
            in.rename_only = false;
            in = sl.in.processVarargin(in,varargin);
            
            %TODO: We could allow new_units to be a cellstr as well
            if in.rename_only
                 for iObj = 1:length(objs)
                    cur_obj = objs(iObj);

                    cur_units = cur_obj.units;
                    cur_obj.units = new_units;

                    history_str   = sprintf('Units changed from %s to %s, data not scaled',cur_units,new_units);
                    cur_obj.addHistoryElements({history_str})
                end
            else
                if ~all(strcmp({objs.units},objs(1).units))
                    error('Not all units are the same as the first object')
                end

                cur_units = objs(1).units;

                if ~strcmp(cur_units,new_units)
                    fh = sci.units.getConversionFunction(cur_units,new_units);

                    for iObj = 1:length(objs)
                        cur_obj = objs(iObj);

                        cur_obj.d     = fh(cur_obj.d);
                        cur_obj.units = new_units;

                        history_str   = sprintf('Units changed from %s to %s, data scaled appropriately',cur_units,new_units);
                        cur_obj.addHistoryElements({history_str})
                    end
                end
            end
        end
    end
end

function [out,x_str] = h__changeXUnits(t,in)
    %in.x_units
    
    switch in.x_units
        case {'','s'}
            out = t;
            x_str = 'time (s)';
        case 'ms'
            out = t*1000;
            x_str = 'time (ms)';
    end
end