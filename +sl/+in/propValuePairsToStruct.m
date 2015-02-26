function struct_output = propValuePairsToStruct(cell_input)
%
%   sl.in.propValuePairsToStruct
%
    v = cell_input(:)'; %Ensure row vector 
    struct_output = cell2struct(v(2:2:end),v(1:2:end),2);


end