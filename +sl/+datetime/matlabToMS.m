function ms_time = matlabToMS(matlab_time)
%
%   ms_time = sl.datetime.matlabToMS(matlab_time);
%
%   See Also
%   --------
%   sl.datetime.msToMatlab

%{
    x = now;
    ms_time = sl.datetime.matlabToMS(x);
    y = sl.datetime.msToMatlab(ms_time);
    ms_time2 = sl.datetime.matlabToMS(y);
    x - y
    ms_time - ms_time2

    

%}

% % % ns100_in_days = 8.64e11;
% % % ticks_1900_1_1 = 599266080000000000; %System.DateTime(1900,1,1).Ticks
% % % days_since_1900_1_1 = (double(ms_time) - ticks_1900_1_1)./ns100_in_days;
% % % matlab_time = days_since_1900_1_1 + datenum(1900,1,1); 
% % % 
% % % x = y + z;
% % % y = (double(w) - g)/h

ns100_in_days = 8.64e11; %1e7*3600*24
ticks_1900_1_1 = 599266080000000000; %System.DateTime(1900,1,1).Ticks

days_since_1900_1_1 = matlab_time - datenum(1900,1,1);

temp = days_since_1900_1_1*ns100_in_days + ticks_1900_1_1;

ms_time = int64(temp);


end