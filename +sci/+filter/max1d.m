function maxdata = max1d(data,win_size)
%
%
%   maxdata = sci.filter.max1d(data,win_size)

%Modified from example in:
%http://www.mathworks.com/matlabcentral/fileexchange/24705-minmax-filter
n_data   = length(data);
maxdata = zeros(1,n_data);
m = max(data(1:win_size)); 
for k = 1:length(data)-win_size
    maxdata(k) = m;
    if data(k) < m
        m = max(m, data(k+win_size));
    else
        m = data(1+k);
        for ii = k+2:k+win_size
            if data(ii)>m
                m = data(ii);
            end
        end
    end
end
for k = k+1:n_data-1
    maxdata(k) = m;
    if data(k) > m
        m = data(1+k);
        for ii = k+2:n_data
            if data(ii)>m
                m = data(ii);
            end
        end
    end
end
maxdata(end) = m;
