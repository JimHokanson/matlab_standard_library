function sz = getScreenSize(monitor_id,throw_error)
%X Gets the resolution of the primary monitor
%
%   sz = sl.os.getScreenSize(*monitor_id, *throw_error)
%
% This is just a wrapper for get(0,'MonitorPosition') which returns an
% nMonitors x 4 matrix.  This is a problem for code that written on a
% dual-head setup that is transferred to a single monitor (and vice versa)
% because the dimensions on the returned matrix are not known until run
% time.
%
% It makes calls to monitor size portable by automatically grabbing the
% first row if the user asked for the second ( when throwError is false )
%
%   Inputs
%   ------
%   monitor_id  : (numeric) (default: 1 )
%       id of monitor to grab 
%   throw_error : (logical) (default: false )
%       Whether or not an error is thrown when 'monitor_id' is greater than
%       the # of monitors.  When false, and monitor_id > nMonitors, monitor
%       will be silently reset to 1. 
%
%   Outputs
%   -------
%   sz : (numeric) monitor size, pixels: [left bottom right top]
%
%   JAH NOTE: I didn't like the monitor switching logic and the querying
%   nature (give me this ID) so I added a second function
%
%   See Also
%   --------
%   sl.os.getScreenSizes

if nargin < 2
    throw_error = false;
    if nargin < 1
        monitor_id = 1;
    end    
end

sz = get(0,'MonitorPosition');
if monitor_id > size(sz,1)
    if throw_error
        error('getScreenSize: Attempted to access monitor #%d on a setup with %d monitors',monitor_id,size(sz,1))
    else
        monitor_id = 1;
    end
end

% CAA When the primary monitor is to the right of the secondary in windows
% the secondary shows up with negative pixel locations, but it comes first
% in the list. Flip them.
if sz(1) < 0
    monitor_id = 2-monitor_id+1;
end

sz = sz(monitor_id,:);

end