function s2 = arrayToScalar(s)
%
%   s2 = sl.struct.arrayToScalar(s)

n_elements = length(s);
s2 = struct;
fn = fieldnames(s);
for i = 1:length(fn)
    cur_name = fn{i};
    temp = cell(n_elements,1);
    for j = 1:n_elements
        temp{j} = s(j).(cur_name);
    end
    s2.(cur_name) = temp;
end