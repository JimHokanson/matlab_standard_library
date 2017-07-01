function output = toMatrix(data,varargin)
%
%   output = sl.cellarr.toMatrix(data,varargin);
%
%   Optional Inputs
%   ---------------
%   default_value : default 0
%   as_rows : logical, default true
%
%   Example
%   -------
%   output = sl.cellarr.toMatrix({1 [2,3] [4,5,6]})
%
%     %   output =>
%     %      1     0     0
%     %      2     3     0
%     %      4     5     6

in.default_value = 0;
in.as_rows = true;
in = sl.in.processVarargin(in,varargin);

array_lengths = cellfun('length',data);
max_array_length = max(array_lengths);

n_arrays = length(array_lengths);

%TODO

if in.as_rows
    output = zeros(n_arrays,max_array_length);
    output(:) = in.default_value;
    for i = 1:n_arrays
        cur_length = array_lengths(i);
        output(i,1:cur_length) = data{i};
    end
    
    
else
    output = zeros(max_array_length,n_arrays);
    output(:) = in.default_value;
    for i = 1:n_arrays
        cur_length = array_lengths(i);
        output(1:cur_length,i) = data{i};
    end     
end


end