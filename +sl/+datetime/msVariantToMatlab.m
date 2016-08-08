function time_out = msVariantToMatlab(time_in)
%
%   sl.datetime.msVariantToMatlab
%

%http://msdn.microsoft.com/en-us/library/aa912065.aspx
%The value 2.0 represents January 1, 1900; 3.0 represents January 2, 1900, and so on.
%
%  693960 = datestr(datenum('1900-01-01') - 2

time_out = time_in + 693960;