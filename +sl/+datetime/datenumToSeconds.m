function datenum_as_seconds = datenumToSeconds(datenum_value)
%
%   datenum_as_seconds = sl.datetime.datenumToSeconds(datenum_value)

%This should really call a conversion function that converts days
%to seconds but we'll do it locally for now ...

%1 day 
%24 hours
%3600 seconds per hour
%86400 seconds per day

datenum_as_seconds = datenum_value*86400;

end