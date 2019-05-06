function matlab_time = msToMatlab(ms_time,varargin)
%x Convert MS time to Matlab time (datenum)
%
%   matlab_time = sl.datetime.msToMatlab(ms_time)
%
%   Outputs
%   -------
%   matlab_time : datenum
%
%   Inputs
%   ------
%   ms_time : [int64] 
%       This is the # of 100 ns increments since January 1, 0 AD
%
%   Example
%   -------
%   %1) Calls .NET 
%   ms_time = System.DateTime.Now
%   matlab_time = sl.datetime.msToMatlab(ms_time.Ticks);
%   datestr(matlab_time)

%These options are not yet implemented ...
in.is_utc = false;
in.as_utc = false;
in = sl.in.processVarargin(in,varargin);

%{
%This seems to work properly, i.e. 
%This is a call to .NET
wtf = System.DateTime.Now;
matlab_time = sl.datetime.msToMatlab(wtf.Ticks);
datestr(matlab_time)
%}

%{
byte_code = uint8([143 215 89 154 200 0 226 0]);
tick_value_us = typecast(byte_code,'int64');
matlab_time = sl.datetime.msToMatlab(tick_value_us*10) %to 100 ns
datestr(matlab_time)
%}

%TODO: Check class
%int64 - we could allow uint64 as well ...

ns100_in_days = 8.64e11;
ticks_1900_1_1 = 599266080000000000; %System.DateTime(1900,1,1).Ticks
days_since_1900_1_1 = (double(ms_time) - ticks_1900_1_1)./ns100_in_days;
matlab_time = days_since_1900_1_1 + datenum(1900,1,1); 
% + sl.datetime.getTimeZone/24;


end