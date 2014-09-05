function sz = getScreenSize(monitorId,throwError)
% GETSCREENSIZE Gets the resolution of the primary monitor
%
% function sz = sl.os.getScreenSize(monitorId, *throwError)
%
% This is just a wrapper for get(0,'MonitorPosition') which returns an
% nMonitors x 4 matrix.  This is a problem for code that written on a dual-head setup
% that is transferred to a single monitor (and vice versa ) because the
% dimensions on the returned matrix are not known until run time.
%
% It makes calls to monitor size portable by automatically grabbing the
% first row if the user asked for the second ( when throwError is false )
%
% INPUTS
% =========================================================================
%   monitorId  - (numeric) id of monitor to grab (default: 1 )
%   throwError - (logical) whether or not an error is thrown when 'monitorId' is
%     greater.  When false, and monitorId > nMonitors, monitor will be silently
%     reset to 1. (default: false )
%
% OUTPUTS
% =========================================================================
% sz  - (numeric) monitor size, pixels: [ left bottom right top]

if nargin < 2
    throwError = false;
    if nargin < 1
        monitorId = 1;
    end    
end

sz = get(0,'MonitorPosition');
if monitorId > size(sz,1)
    if throwError
        error('getScreenSize: Attempted to access monitor #%d on a setup with %d monitors',monitorId,size(sz,1))
    else
        monitorId = 1;
    end
end

% CAA When the primary monitor is to the right of the secondary in windows
% the secondary shows up with negative pixel locations, but it comes first
% in the list. Flip them.
if sz(1) < 0
    monitorId = 2-monitorId+1;
end

sz = sz(monitorId,:);

end