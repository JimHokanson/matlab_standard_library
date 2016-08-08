function mask = isField(cellstruct,field_name)
%x Returns mask indicating whether or not each structure contains a field
%
%   mask = sl.cellstruct.isField(cellstruct,field_name);
%
%   Inputs:
%   -------
%   cellstruct : cellstruct
%   field_name : string
%
%   Outputs:
%   --------
%   mask : logical
%
%   Example:
%   --------
%   s1.a = 1;
%   s2 = struct;
%   cs = {s1 s2};
%   mask = sl.cellstruct.isField(cs,'a');
%   mask => [1 0]

mask = cellfun(@(x) isfield(x,field_name),cellstruct);

end