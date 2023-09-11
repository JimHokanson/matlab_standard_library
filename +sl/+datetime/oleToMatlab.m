function value = oleToMatlab(data)
%
%
%   value = sl.datetime.oleToMatlab(data)
%
%
%   data : double

%   https://learn.microsoft.com/en-us/dotnet/api/system.datetime.tooadate?view=net-8.0


%Format:
%
%   days since 30 Dec 1899
%
%   fractions: day/24

%MATLAB format:
%   
%   - days since Jan 1, 0000

    if isa(data,'uint8')
        %TODO: check length
        data = typecast(data,'double');
    end

    value = data - datenum([1899 12 30 0 0 0 ]); %#ok<DATNM> 

end