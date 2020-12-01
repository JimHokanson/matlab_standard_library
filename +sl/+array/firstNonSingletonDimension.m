function dim = firstNonSingletonDimension(data)
%
%   dim = sl.array.firstNonSingletonDimension(data)
%
%   TODO: Finish documentation ...

dim = find(size(data) > 1,1);
if isempty(dim)
    dim = 1;
end

end