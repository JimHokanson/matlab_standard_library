function time_out = msBase1601ToMatlab(time_in)
%
%   
%   time_out = sl.datetime.msBase1601ToMatlab(time_in)
%
%   Is there a better source on this?
%   http://msdn.microsoft.com/en-us/library/windows/desktop/ms675098(v=vs.85).aspx
%
%   Outputs:
%   -----------------------------------------------------------------------
%   time_out : (double), Matlab representation of time, the time zone.
%
%       CAREFUL! The time zone is currently shifted based on where 
%       the code is evaluated.
%
%   Inputs:
%   -----------------------------------------------------------------------
%   time_in : (uint64)
%       - 1 = 100 nanoseconds
%       - base time: 1601-01-01
%       - relative to: UTC
%
%
%   IMPROVEMENTS:
%   -----------------------------------------------------------------------
%   1) Allow a non-standard matlab time output
%        - seconds
%        - datestr
%        - datestr as cell
%   2) Optionally specify time zone shift

if ~isa(time_in,'uint64')
    error('The input to this function must of uint64')
end

%datenum(1601,1,1) = 584755
%
%100 nanoseconds to days = 1/8.64e11

time_since_1601_s = double(time_in)/8.64e11;

time_out = 584755 + time_since_1601_s + sl.datetime.getTimeZone;
