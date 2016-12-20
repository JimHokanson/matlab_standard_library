function data_subset_objs = getDataSubset(objs,varargin)
%x  Returns a new object that only has a subset of the data.
%   
%   data_subset_objs = getDataSubset(objs,varargin)
%
%   
%
%   This function is meant to simplify data retrieval of a subset of data.
%   To get a subset, a start and stop sample must be specified. There are
%   numerous ways of doing this. See "Calling Forms" and "Examples" below.
%
%   Events:
%   -------
%   Events are kept within the 'event_info' property. The name of events 
%   can be seen in the 'event_names' property. Events come in 2 types:
%       - discrete events - occur as a single time point
%       - epoch events - occurs as a start and stop time
%
%   In order to resolve to a given time point, an event index must be
%   given, as an event object can have multiple events. This index is often
%   1 to indicate that the first value should be used.
%
%   Calling Forms:
%   --------------
%   0) options --> accessed via: sci.time_series.subset_options.()
%
%   1) '-samples'           <samples>
%   2) '-times'             <times>
%   3) <start_event_name>   <event_indices or 'all'>    <stop_event_name>   <event_indices or 'all'>
%   4) <start_event_name>   <event_indices or 'all'>    '-t_win'    <window_values>
%   5) <start_event_name>   <event_indices or 'all'>    '-s_win'    <window_values>
%   6) <start_event_name>   <event_indices or 'all'>    '-t_dur'    <time duration>
%   7) <start_event_name>   <event_indices or 'all'>    '-s_dur'    <sample duration>
%   8) <epoch_name>         <event_indices or 'all'>
%   9) <epoch_name>         <event_indices or 'all'>    '-pct',     <pct grab>
%  10) <epoch_name>         <event_indices or 'all'>    '-s_win',   <window_values>
%  11) <epoch_name>         <event_indices or 'all'>    '-t_win',   <window_values>
%
%   Examples:
%   ---------
%   1) getDataSubset('-samples',[1 100]) - Grab from sample 1 to sample 100
%   2) getDataSubset('-times','[1.3 2.6]) - Grab from 1.3 to 2.6 seconds
%   3) getDataSubset('start_pump',1,'stop_pump',1)
%   4) getDataSubset('start_pump',1,'-t_win',[-1 2]) - Grab 1 second before
%                   and 2 seconds after the first 'start_pump' event
%   TODO 5 - 7
%   8) getDataSubset('fill',1) %Grab the first fill epoch
%   9) getDataSubset('fill',1,'-pct',[0.20 0.80]) %Grab from 20% to 80% of the fill epoch
%
%   p = trial.getData('pres');
%   p_fill  = p.getDataSubset('fill_to_first_bc',1);
%   p_fillp = p.getDataSubset('fill',1,'-pct',[0.2 0.8]);
%   %We need 'un',0 to handle multiple contractions
%   p_bc = p.getDataSubset('bladder_contraction','all','un',0);
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
%       being 'un' so it is much more succinct to enter 'un',0 instead.
%
%       NOTE: If we wanted, we could also alias this with a longer optional
%       input name that does the same thing but I don't want to use
%       'UniformOutput', perhaps 'collapse'?
%
%   Improvement:
%   Allow splitting ..., 'splits',n_splits or pct splits
%       This would only be allowed with a singular thing ...
%
%   See Also:
%   sci.time_series.subset_options
%   sci.time_series.data.getDataAlignedToEvent()
%   sci.time_series.data.zeroTimeByEvent()

%{
%NOT YET IMPLEMENTED
%   'start_t',<start_times>
%           'start_t',5.323
%           'stop_t',[5.3 20 50 100]  %???? 1 per object or all per object
%           Would need to default to all per object, with cells to
%           distinguish between objects
%   
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

%start_samples & stop_samples : {1 x n_objects}[1 x n_times]

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

% if in.align_time_to_start
%     first_sample_time = 0;
% else
%     %This basically means keep the first sample at whatever
%     %time it currently is
%     first_sample_time = [];
% end

n_objs = length(start_samples);
temp_objs_1 = cell(1,n_objs);
for iObj = 1:n_objs
    cur_obj = objs(iObj);
    
    cur_start_samples = start_samples{iObj};
    cur_stop_samples = stop_samples{iObj};
    n_spans = length(cur_start_samples);
    
    new_time_objs = cell(1,n_spans);
    temp_objs_2 = cell(1,n_spans);
    for iSpan = 1:n_spans
        start_I  = cur_start_samples(iSpan);
        stop_I   = cur_stop_samples(iSpan);
        
        %TODO: Decide if this is what we want to do ...
        if stop_I > cur_obj.n_samples
            stop_I = cur_obj.n_samples;
        end
        new_data = cur_obj.d(start_I:stop_I,:,:);
        
        
        n_samples = stop_I - start_I + 1;
        new_time = cur_obj.time.getNewTimeObjectForDataSubset(start_I,n_samples);
        new_time_objs{iSpan} = new_time;
        
        
        new_obj = h__createNewDataFromOld(cur_obj,new_data,new_time);
        %new_obj.event_info.shiftTimes(new_obj.time.start_offset - cur_obj.time.start_offset)
        temp_objs_2{iSpan} = new_obj;
    end
    
    %objs.zeroTimeByEvent(event_times)
    
    %We can always collapse these objects. 
    %*** It is just across objects that we might not be able to collapse
    new_time_objs = [new_time_objs{:}];
    temp_objs_2_array = [temp_objs_2{:}];
    if in.align_time_to_start
        temp_objs_2_array.zeroTimeByEvent([new_time_objs.start_offset]);
    end
    
    temp_objs_1{iObj} = temp_objs_2_array;
end

if return_as_cell
    data_subset_objs = temp_objs_1;
else
    data_subset_objs = [temp_objs_1{:}];
end


end

function [start_samples,stop_samples,varargin] = h__handleInput(objs,varargin)
%
%   This function is called at the beginning of the main function to
%   resolve which samples should be retrieved based on the complicated
%   # of input options
%
%   Output:
%   -------
%   start_samples : cell
%       cell for each object, array for each element
%   stop_samples : cell
%       cell for each object, array for each element
%   varargin: varargin input, trimmed to handle inputs

%   'start_e','qp_start',1,'stop_e','qp_end',1
%   'start_t',value,'stop_t',value
%   'start_s',value,'stop_s',value
%   'epoch','fill'
%   'start_e','qp_start',1,'duration_s',10 %duration in seconds
%   'start_e','qp_start',1,'window',[-10 10] %20 seconds around a given start event
%   'epoch','fill',[20 80]

%TODO: Move all the code into the options processors
%Have functions that translate from varargin to an options object

if isobject(varargin{1})
    [start_samples,stop_samples,varargin] = varargin{1}.getStartAndStopSamples(objs);
    return
end

first_name = varargin{1};
if first_name(1) == '-'
    %See details of this case in the help under start events
    values = varargin{2};
    varargin(1:2) = [];
    n_objs = length(objs);
    
    switch first_name(2:end)
        case 'samples'
            start_samples = sl.cell.initialize(n_objs,values(1));
            stop_samples  = sl.cell.initialize(n_objs,values(2));
        case 'times'
            start_samples = h__timeToSamples(objs,values(1));
            stop_samples  = h__timeToSamples(objs,values(2));
        otherwise
            error('Option %s not recognized')
    end
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
    
    %Currently the only option at this point is for a closing event ...
    event_name = varargin{1};
    events = objs.getEvent(event_name);
    [~,stop_samples,varargin] = h__handleDiscreteEventInput(objs,false,events,varargin{2:end});
    
end



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
        otherwise
            error('Unrecognized option: %s',option)
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
%   times : cell or array
%       When an array, the values are replicated for each object

if ~iscell(times)
    times = sl.cell.initialize(length(objs),times);
end

n_objs = length(objs);
samples = cell(1,n_objs);
for iObj = 1:n_objs
    cur_obj = objs(iObj);
    cur_times = times{iObj};
    %TODO: Introduce a bounds error check in getNearestIndices
    samples{iObj} = cur_obj.time.getNearestIndices(cur_times);
end
end

function new_data_obj = h__createNewDataFromOld(old_obj,new_data,new_time_object)
%
%   This should be used internally when creating a new data object.
%
%   Inputs:
%   -------
%   new_data : array
%       The actual data from the new object.
%   new_time_object : sci.time_series.time

new_data_obj   = copy(old_obj);
new_data_obj.d = new_data;
new_data_obj.time = new_time_object;
%new_data_obj.event_info.shiftTimes(new_data_obj.time.start_offset - old_obj.time.start_offset)
end

% % % % function new_time_object = h__getNewTimeObjectForDataSubset(obj,first_sample,last_sample,varargin)
% % % % %
% % % % %
% % % % %   Optional Inputs:
% % % % %   ----------------
% % % % 
% % % % in.first_sample_time = [];
% % % % %empty - keeps its time
% % % % %0 - first value will be zero
% % % % in = sl.in.processVarargin(in,varargin);
% % % % 
% % % % n_samples = last_sample - first_sample + 1;
% % % % new_time_object = obj.time.getNewTimeObjectForDataSubset(first_sample,n_samples,...
% % % %     'first_sample_time',in.first_sample_time);
% % % % 
% % % % end

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
