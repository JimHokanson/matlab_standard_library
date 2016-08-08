function numeric_dim = getNumericDim(dim_input)
%
%
%   numeric_dim = sl.xyz.getNumericDim(dim_input)
%
%
%   TODO: This would be better off with other functions
%   under a package roughly titled 'dim_input_handler'
%   dim_input_handler.enforceNumerics

if ischar(dim_input)
    %TODO: Check char length
    numeric_dim = strfind('xyz',dim_input);
    if isempty(numeric_dim) || length(numeric_dim) > 1
        error('Input should be x, y, or z')
    end
else
    numeric_dim = dim_input;
end