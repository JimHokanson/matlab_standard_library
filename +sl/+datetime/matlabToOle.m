function value = matlabToOle(d)
%
%   value = sl.datetime.matlabToOle(d)

    value = d + datenum([1899 12 30 0 0 0]); %#ok<DATNM> 


end