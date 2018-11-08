function s = initialize(field_names,size)
%x Initialize a structure array
%
%   s = sl.struct.initialize(field_names,size)
%
%   Inputs
%   ------
%   field_names : 
%   size : 
%
%   Examples
%   --------
%   s = sl.struct.initialize({'cheese','top'},[1 4]);
%
%   s =>
%       1×4 struct array with fields:
% 
%       cheese
%       top

if length(size) == 1
    size = [1 size];
end

if isempty(field_names)
    last_index = num2cell(size);
    s(last_index{:}) = struct;
    return
end

temp = cell(1,length(field_names)*2);
temp(1:2:end) = field_names;
temp{2} = cell(size);

s = struct(temp{:});

end