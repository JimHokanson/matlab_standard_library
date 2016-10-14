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
%   output : ?
%       The output from the structure ...
%
%   Optional Inputs
%   ---------------
%   un : logical (default false)
%       If true, the results will be concatenated. If false, values
%       will be returned as a cell array.
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
%   Improvements
%   ------------
%   1) Build in support for a default missing value if the field is not
%      present.

in.un = false;
in = sl.in.processVarargin(in,varargin);

output = cellfun(@(x) x.(field_name),cellstruct,'un',in.un);



end