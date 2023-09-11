function args = toPythonArgs(s)
%X Converts struct to pyargs object
%
%   args = sl.struct.toPythonArgs(s)
%
%   

%TODO: Might want to shadow this in sl.struct
name_value_cell = sl.in.structToPropValuePairs(s);

%Also: namedargs2cell works as well but this is fairly recent (2019?)

%pyargs : matlab built-in
args = pyargs(name_value_cell{:});

end