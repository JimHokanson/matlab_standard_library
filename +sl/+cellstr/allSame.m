function result = allSame(data)
%
%   sl.cellstr.allSame


result = all(strcmp(data,data{1}));

end