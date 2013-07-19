function mask = missing_dims(dim_str)
%
%   mask = sl.xyz.str.missing_dims(dim_str)
%   

%NOTE: I'd like to figure out how to generalize this ...

mask = false(1,3);
xyz  = 'xyz';
for iDim = 1:3
   mask(iDim) = any(dim_str == xyz(iDim));
end

