function out = t32BitWindowsToMatlab(b)
%x 
%
%   sl.datetime.t32BitWindowsToMatlab(b)
%   
%   Format found at:
%   https://docs.microsoft.com/en-us/cpp/c-runtime-library/32-bit-windows-time-date-formats

%This might not be right ...

%{
    out = sl.datetime.t32BitWindowsToMatlab(uint8([152 4 6 64]))
%}

if isa(b,'uint16')
    %TODO: Check length of 2
elseif isa(b,'uint8')
    %TODO: Check length of 4
    b = typecast(b,'uint16'); 
else
   error('Unexpected input type') 
end

%------------------------------------------------

h = sl.io.tc.getBitNumber(b(1),1,5);
min = sl.io.tc.getBitNumber(b(1),6,11);

%I think we need to multiply by 2, i.e. that 1 is 2 seconds elapsed
s = 2*sl.io.tc.getBitNumber(b(1),12,16);

y = 1980 + sl.io.tc.getBitNumber(b(2),1,7);
month = sl.io.tc.getBitNumber(b(2),8,11);
day = sl.io.tc.getBitNumber(b(2),12,16);

d = @double;
out = datenum(d(y),d(month),d(day),d(h),d(min),d(s));

end