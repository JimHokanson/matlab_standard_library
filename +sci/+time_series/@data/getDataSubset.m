function data_subset_objs = getDataSubset(objs,varargin)
%
%   Returns a new object that only has a subset of the data.
%
%   data_subset_objs = getDataSubset(objs,varargin)
%
%   There are many ways of calling this function. See:
%       "Specifying the Data Range" 
%   below for more details.
%   
%   Specifying the Data Range:
%   --------------------------
%   This function is meant to simplify data retrieval of a subset of data.
%   To get a subset a start and stop sample must be specified. There are
%   numerous ways of doing this. For example one could literally specify a
%   start and a stop sample, or alternatively, specify a start and a stop
%   time which are then internally converted to samples. Since this class
%   has events associated with it, one can also specify events from which
%   times are defined.
%
%   Events:
%   -------
%   Class events are kept within the 'event_info' property. The name of
%   events can be seen in the 'event_names' property. Events come in 2
%   types:
%       - discrete events
%       - epoch events
%
%   Discrete events occur at a single time point whereas epochs are defined
%   by a span of time from a start time to a stop time.
%
%   Discrete events can be resolved into single start or stop times whereas
%   epoch events specify both a start and stop time.
%
%   In order to resolve to a given time point, an event index must be
%   given, as an event object can have multiple events. This index is often
%   1 to indicate that 
%
%
%   Start Inputs:
%   -------------
%   <start_event_name>,<event_indices or 'all'> Requires Stop Input
%           'start_e','qp_start',1
%           'start_e','bladder_contraction_starts','all'
%   <start_event_name>,<event_indices or 'all'>,'-t_win',<window_values>
%   <start_event_name>,<event_indices or 'all'>,'-s_win',<window_values>
%   <start_event_name>,<event_indices or 'all'>,'-t_dur',<time duration>
%   <start_event_name>,<event_indices or 'all'>,'-s_dur',<sample duration>
%
%   <epoch_name>,<event_indices or 'all'>
%           'fill',1
%   <epoch_name>,<event_indices or 'all'>,'-pct',<pct grab>
%           'fill',1,'-pct',[0.20 0.80]
%   <epoch_name>,<event_indices or 'all'>,'-t_win',<time window values>
%           'fill',1,'-t_win',[10 -10]
%   <epoch_name>,<event_indices or 'all'>,'-s_win',<sample window values>
%
%
%   Stop Inputs:
%   ------------
%   <event_name>,<event_indices or 'all'>
%
%
%   Optional Inputs:
%   ----------------
%   align_time_to_start : logical (default false)
%       If this value is true, the start time is set to the
%       time of the first sample in the subset, rather than
%       the first sample in the original data set
%   un : logical (default true)
%       'un' is really short for 'UniformOutput'. In Matlab, cellfun() and
%       arrayfun() will concatenate outputs into a single vector. If
%       however multiple outputs come from a single iteration (or in  this
%       case, per object), then the output must be a cell array. In order
%       to not have the output type dynamically change, the user must
%       acknowledge the output will ALWAYS be a cell array by passing in:
%   
%           'UniformOutput', false
%       These functions however only check for the first two characters
%       being 'un' so it is much more succint to enter 'un',0 instead.
%
%       NOTE: If we wanted, we could also alias this with a longer optional
%       input name that does the same thing but I don't want to use
%       'UniformOutput', perhaps 'collapse'?
%
%   Examples:
%   ---------
%   Some setup:
%       c = dba.GSK.cmg_expt('140806_C');
%       p = c.getData('pres');
%
%   1) Retrieve data over the 1st 'fill' epoch
%
%       p_fill = p.getDataSubset('fill',1);
%
%
%   2) " " from 20% to 80% of the 1st 'fill' epoch   
%
%       p_fillp = p.getDataSubset('fill',1,'-pct',[0.2 0.8]);
%
%
%   3) Get all bladder contractions (NOTE: 'un',0) is required since
%   there could be multiple contractions per 'p' instance.
%
%       p_bc = p.getDataSubset('bladder_contraction','all','un',0);
%
%
%   Examples:
%    ---------------
%   see dba.GSK.cmg_analysis
%   obj.pres_data_handle.getDataSubset('bladder_contraction_starts', 1,'bladder_contraction_ends', 1)
%   first input  - string form character form, second input
%   numerical integer indicates the which iteration of the
%   property you would like to begin at. and the latter, the iteration of
%   the ending property you'd like to end at.
%
%   See Also:
%   sci.time_series.data.getDataAlignedToEvent()
%   sci.time_series.data.zeroTimeByEvent()

%{
%NOT YET IMPLEMENTED
%   'start_t',<start_times>
%           'start_t',5.323
%           'stop_t',[5.3 20 50 100]  %???? 1 per object or all per object
%   'start_s',<start_samples>
%           'start_s',10


%}

%TODO: If 
%{
    c = dba.GSK.cmg_expt('140806_C');
    p = c.getData('pres');
    p_fill = p.getDataSubset('fill',1);
    p_fillp = p.getDataSubset('fill',1,'-pct',[0.2 0.8]);
    p_fillt = p.getDataSubset('fill',1,'-t_win',[10 -10]);
    p_fills = p.getDataSubset('fill',1,'-s_win',[20*1000 -20*1000]);


    p_fillse = p.getDataSubset('start_pump',1,'stop_pump',1);

    p_fills1 = p.getDataSubset('start_pump',1,'-t_win',[10 300]);
    p_fills2 = p.getDataSubset('start_pump',1,'-s_win',[100 30000]);


%   <start_event_name>,<event_indices or 'all'>,'-t_win',<window_values>
%   <start_event_name>,<event_indices or 'all'>,'-s_win',<window_values>
%   <start_event_name>,<event_indices or 'all'>,'-t_dur',<time duration>
%   <start_event_name>,<event_indices or 'all'>,'-s_dur',<sample duration>
    p_bc   = p.getDataSubset('bladder_contraction','all','un',0);


    plot(p_fill)
    hold on
    plot(p_fillp,'Color','k')
    hold off


%}
[start_samples,stop_samples,varargin] = h__handleInput(objs,varargin{:});

h__checkValiditySamples(start_samples,stop_samples);

%start_samples : cell
%stop_samples : cell

in.un = true; %UniformOutput
in.align_time_to_start = false;
in = sl.in.processVarargin(in,varargin);

return_as_cell = ~in.un;
%TODO: Error check that we can do this ...

if ~return_as_cell
   if any(cellfun('length',start_samples)~= 1)
      error('Sorry, please add ,''un'',0 at the end of the to the input (output will be a cell array, 1 entry per object') 
   end
end

if in.align_time_to_start
    first_sample_time = 0;
else
    %This basically means keep the first sample at whatever
    %time it currently is
    first_sample_time = [];
end

n_objs = length(start_samples);
temp_objs_1 = cell(1,n_objs);
for iObj = 1:n_objs
    cur_obj = objs(iObj);
        
    cur_start_samples = start_samples{iObj};
    cur_stop_samples = stop_samples{iObj};
    n_spans = length(cur_start_samples);
    
    temp_objs_2 = cell(1,n_spans);
    for iSpan = 1:n_spans
        start_I  = cur_start_samples(iSpan);
        stop_I    = cur_stop_samples(iSpan);
        new_data = cur_obj.d(start_I:stop_I,:,:);
        new_time = h__getNewTimeObjectForDataSubset(cur_obj,start_I,stop_I,...
            'first_sample_time',first_sample_time);
    
        temp_objs_2{iSpan} = h__createNewDataFromOld(cur_obj,new_data,new_time);
    end
    
    %We can always collapse these objects. It is just across objects that
    %we might not be able to collapse
    temp_objs_1{iObj} = [temp_objs_2{:}];
end

if return_as_cell
    data_subset_objs = temp_objs_1;
else
    data_subset_objs = [temp_objs_1{:}];
end


end

function [start_samples,stop_samples,varargin] = h__handleInput(objs,varargin)
%
%
%   Output:
%   -------
%   start_samples : cell 
%       cell for each object, array for each element
%   stop_samples : " "
%   varargin: varargin input, trimmed to handle inputs

%   'start_e','qp_start',1,'stop_e','qp_end',1
%   'start_t',value,'stop_t',value
%   'start_s',value,'stop_s',value
%   'epoch','fill'
%   'start_e','qp_start',1,'duration_s',10 %duration in seconds
%   'start_e','qp_start',1,'window',[-10 10] %20 seconds around a given start event
%   'epoch','fill',[20 80]

first_name = varargin{1};
if first_name(1) == '-'
   %TODO: How would we handle the ambigious case of multiple values
   %- are these values by object or within object? - we can guess
   %based on size but we want to be sure all of the time
   error('Not yet implemented') 
else
   events = objs.getEvent(first_name); 
   if isa(events,'sci.time_series.epochs')
       [start_samples,stop_samples,varargin] = h__handleEpochInput(objs,events,varargin{2:end});
       return
   else
       [start_samples,stop_samples,varargin] = h__handleDiscreteEventInput(objs,true,events,varargin{2:end});
       if ~isempty(stop_samples)
           return
       end
   end
end

%Currently the only option at this point is for a closing event ...
event_name = varargin{1};
events = objs.getEvent(event_name); 
[~,stop_samples,varargin] = h__handleDiscreteEventInput(objs,false,events,varargin{2:end});

end

function h__checkValiditySamples(start_samples,stop_samples)
%

%Here we are checking that all stop samples come after the start samples
for iObj = 1:length(start_samples)
    obj_start_samples = start_samples{iObj};
    obj_stop_samples  = stop_samples{iObj};
    if any(obj_stop_samples < obj_start_samples)
       error('Invalid range requested for object %d',iObj)
    end
end

end

function [start_samples,stop_samples,varargin] = h__handleDiscreteEventInput(objs,is_start,events,varargin)

start_samples = [];
stop_samples = [];

%Grab the times based on the discrete events
%--------------------------------------------
I = varargin{1};
varargin(1) = [];
n_events = length(events);
times = cell(1,n_events);
if ischar(I)
    for iEvent = 1:n_events
       times{iEvent} = events(iEvent).times;
    end
else
    for iEvent = 1:n_events
       times{iEvent} = events(iEvent).times(I);
    end    
end

if is_start
    start_times = times;
    stop_times = [];
else
    start_times = [];
    stop_times = times;
end

%Handle optional inputs that are not events
%-------------------------------------------
implement_sample_window = false;
implement_sample_duration = false;
if ~isempty(varargin) && ischar(varargin{1}) && varargin{1}(1) == '-'
   if ~is_start
      error('Options are only supported following a start event') 
   end
   option = varargin{1};
   value  = varargin{2};
   switch option
       case '-t_win'
           stop_times  = cellfun(@(x) x + value(2),start_times,'un',0);
           start_times = cellfun(@(x) x + value(1),start_times,'un',0);
       case '-s_win'
           implement_sample_window = true;
       case '-t_dur'
            stop_times  = cellfun(@(x) x + value,start_times,'un',0);
       case '-s_dur'
           implement_sample_duration = true;
   end
   varargin(1:2) = [];
end

%Conversion from times to samples
%--------------------------------
if ~isempty(start_times)
    start_samples = h__timeToSamples(objs,start_times);
end

if ~isempty(stop_times)
    stop_samples = h__timeToSamples(objs,stop_times);
end

%Processing now that we are working with samples
%-----------------------------------------------
if implement_sample_window
   stop_samples  = cellfun(@(x) x + value(2),start_samples,'un',0);
   start_samples = cellfun(@(x) x + value(1),start_samples,'un',0);
elseif implement_sample_duration
   sample_duration = value;
   if sample_duration < 0
       stop_samples  = start_samples;
       start_samples = cellfun(@(x) x + sample_duration,start_samples,'un',0);
   else
       stop_samples  = cellfun(@(x) x + sample_duration,start_samples,'un',0);
   end
end

end

function [start_samples,stop_samples,varargin] = h__handleEpochInput(objs,events,varargin)
%

%Grab the times based on the epoch events
%----------------------------------------
I = varargin{1};
varargin(1) = [];
n_events = length(events);
start_times = cell(1,n_events);
stop_times  = cell(1,n_events);

if ischar(I)
    for iEvent = 1:n_events
       start_times{iEvent} = events(iEvent).start_times;
       stop_times{iEvent}  = events(iEvent).stop_times;
    end
else
    for iEvent = 1:n_events
       start_times{iEvent} = events(iEvent).start_times(I);
       stop_times{iEvent}  = events(iEvent).stop_times(I);
    end    
end



%Handle optional windowing
%-------------------------
use_sample_window = false;

if ~isempty(varargin) && ischar(varargin{1}) && (varargin{1}(1) == '-')
   
   type =  varargin{1};
   switch type
       case '-t_win'
           window_times = varargin{2};
           start_times = cellfun(@(x) x + window_times(1),start_times,'un',0);
           stop_times  = cellfun(@(x) x + window_times(2),stop_times,'un',0);
       case '-s_win'
           window_samples = varargin{2};
           use_sample_window = true;
       case '-pct'
           pct_window = varargin{2};
           range = cellfun(@(x,y) x-y,stop_times,start_times,'un',0);
           %NOTE: stop_times must come first before we redefine start_times
           stop_times   = cellfun(@(x,y) x + pct_window(2)*y,start_times,range,'un',0);
           start_times = cellfun(@(x,y) x + pct_window(1)*y,start_times,range,'un',0);
           
   end
   varargin(1:2) = [];
end

%Change times to samples
%-----------------------
start_samples = h__timeToSamples(objs,start_times);
stop_samples  = h__timeToSamples(objs,stop_times);


%Implement sample based window
%-----------------------------
if use_sample_window
   start_samples = cellfun(@(x) x + window_samples(1),start_samples,'un',0);
   stop_samples   = cellfun(@(x) x + window_samples(2),stop_samples,'un',0);
end

end

%=================================================================
function samples = h__timeToSamples(objs,times)
%
%   samples = h__timeToSamples(objs,times)
%
%   Inputs:
%   -------
%   times : cell
%
    n_objs = length(objs);
    samples = cell(1,n_objs);
    for iObj = 1:n_objs
        cur_obj = objs(iObj);
        cur_times = times{iObj};
        %TODO: Introduce a bounds error check in getNearestIndices
        samples{iObj} = cur_obj.time.getNearestIndices(cur_times);
    end
end

function new_data_obj = h__createNewDataFromOld(obj,new_data,new_time_object)
%
%   This should be used internally when creating a new data object.
%
%   Inputs:
%   -------
%   new_data : array
%       The actual data from the new object.
%   new_time_object : sci.time_series.time

new_data_obj   = copy(obj);
new_data_obj.d = new_data;
new_data_obj.time = new_time_object;
end

function new_time_object = h__getNewTimeObjectForDataSubset(obj,first_sample,last_sample,varargin)
%
%
%   Optional Inputs:
%   ----------------

in.first_sample_time = [];
%empty - keeps its time
%0 - first value will be zero
in = sl.in.processVarargin(in,varargin);

n_samples = last_sample - first_sample + 1;
new_time_object = obj.time.getNewTimeObjectForDataSubset(first_sample,n_samples,...
    'first_sample_time',in.first_sample_time);

end

%{
if in.align_time_to_start
    first_sample_time = 0;
else
    %This basically means keep the first sample at whatever
    %time it currently is
    first_sample_time = [];
end

n_objs = length(objs);
all_start_times = zeros(1,n_objs);
temp_objs_ca = cell(1,n_objs);
for iObj = 1:n_objs
    cur_obj = objs(iObj);
    
    if ischar(start_event)
        evh = cur_obj.event_info; %event holder
        start_time = evh.(start_event).times(start_event_index);
        stop_time   = evh.(stop_event).times(stop_event_index);
    else
        start_time = start_event(iObj);
        stop_time   = stop_event(iObj);
    end
    
    if ~in.times_are_samples
        %TODO: Make this a function ...
        %??? - what a function ????
        start_index = h__timeToSamples(cur_obj,start_time);
        stop_index   = h__timeToSamples(cur_obj,stop_time);
    else
        start_index = start_event;
        stop_index  = stop_event;
    end
    
    new_data        = cur_obj.d(start_index:stop_index,:,:);
    
    new_time_object = h__getNewTimeObjectForDataSubset(cur_obj,start_index,stop_index,'first_sample_time',first_sample_time);
    
    temp_objs_ca{iObj} = h__createNewDataFromOld(cur_obj,new_data,new_time_object);
end

data_subset_objs = [temp_objs_ca{:}];

if in.align_time_to_start
    data_subset_objs.zeroTimeByEvent(all_start_times);
end
%}
