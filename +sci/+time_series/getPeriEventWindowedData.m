function [t,windowed_data,valid_events] = getPeriEventWindowedData(events,time_object,data,window,varargin)
% getPeriEventWindowedData - Return windowed data about an event
% 
%   [t,windowed_data,valid_events] = sci.time_series.getPeriEventWindowedData(...
%                                   events,time_object,data,window,varargin)
%
% Inputs:
%   events :
%       Either these are indices or they are times.
%   time_object : sci.time_series.time
%       
%
%   TODO: Redo documentation to match code
%
%       - time (seconds) events about which to grab the windows
%   time        - time (seconds) of each data sample, with constant frequency
%   data        - the data, in columns, with each row is a sample
%   window      - the window about the event; may be defined in one of two ways
%       1: a vector of at least 3 indices of data you'd like about the
%       event, e.g. [-1 0 1]
%       2: a 2-elt time (seconds) vector with the start and end of the window
% 
% Outputs:
%   Returns the time base of the window, the windowed data, and the indices of
%   event_times that were valid to use (ie, within the bounds of data).
% 
%   The returned windowed_data is a 3-dimensional vector m x n x p, where
%       m = number of valid_events
%       n = length of each window
%       p = number of columns of data (can be 1, making windowed_data 2d)
% 

in.events_are_times = false;
in = sl.in.processVarargin(in,varargin);

dt = time_object.dt;

% Argument checks; convert window to samples if needed
if length(window) == 2
    %Then the window units are times ...
    min_window_time = window(1);
    max_window_time = window(2);
    window_indices = ceil(window(1)/dt):floor(window(2)/dt); 
else
    %units of window are samples
    min_window_time = min(window)/dt;
    max_window_time = max(window)/dt;
    window_indices = window;
    assert(all(round(window_indices) == window_indices),...
    'When defined with more than 2 elements, window must be in integer samples');
end

assert(length(window_indices) > 1,...
    ['Window must have at least two elements.' ...
    'Use sci.time_series.computeNearestIndices if you only want one element']);


% The (rather simple) algorithm
%----------------------------------
if in.events_are_times
    event_times   = events;
    event_indices = computeNearestIndices(time,event_times(:));
    
    min_event_times = event_times + min_window_time;
    max_event_times = event_times + max_window_time;
    valid_events = min_event_times >= time_object.start_time & max_event_times <= time_object.end_time;
else
    event_indices = events;
    
    min_event_indices = event_indices + min(window_indices);
    max_event_indices = event_indices + max(window_indices);
    valid_events = min_event_indices >= 1 & max_event_indices <= length(data);
    
end

event_indices(~valid_events) = [];

data_indices_to_grab = bsxfun(@plus,event_indices(:),window_indices(:)');
windowed_data = data(data_indices_to_grab);
t = window_indices*dt;
