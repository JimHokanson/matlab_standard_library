function output = getField(cellstruct,field_name,varargin)
%x Returns values from a field of structures inside a cell array
%
%   output = sl.cellstruct.getField(cellstruct,field_name);
%
%   Inputs
%   ------
%   cellstruct : cellstruct
%   field_name : string
%
%   Outputs
%   -------
%   output : array or cell array
%       The output from the structure ...
%
%   Optional Inputs
%   ---------------
%   un : logical (default false)
%       If true, the results will be concatenated. If false, values
%       will be returned as a cell array.
%   missing_value : (default, throw an error)
%       If this value is specified, the missing entry will be replaced
%       with this missing_value
%
%   Examples
%   --------
%   s1.a = 1;
%   s2.a = 2;
%   cs = {s1 s2};
%   a = sl.cellstruct.getField(cs,'a');
%   disp(a) %a => {[1],[2]}
%   a = sl.cellstruct.getField(cs,'a','un',1);
%   disp(a) %a => [1,2]
%
%   s1.a = 1;
%   s2.a = 2;
%   s3.b = 3;
%   cs = {s1 s2 s3};
%   a = sl.cellstruct.getField(cs,'a','missing_value',NaN) %3rd value
%   %becomes NaN since s3 doesn't have an 'a' field
%   a = sl.cellstruct.getField(cs,'a'); %Should throw an error
%   

in.un = false;
in.missing_value = sl.in.NULL;
in = sl.in.processVarargin(in,varargin);

try
    output = cellfun(@(x) x.(field_name),cellstruct,'un',in.un);
catch ME
    if isa(in.missing_value,'sl.in.NULL')
        rethrow(ME)
    else
       output = cell(size(cellstruct));
       
       %TODO: This may throw an error if not all values are a structure
       %    i.e., it isn't a cellstruct
       %    It would be good to clarify this error
       has_field = cellfun(@(x) isfield(x,field_name),cellstruct,'un',1);
       
       output(has_field) = cellfun(@(x) x.(field_name),cellstruct(has_field),'un',in.un);
       output(~has_field) = {in.missing_value};
    end
end


end