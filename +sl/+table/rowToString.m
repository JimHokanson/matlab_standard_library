function str = rowToString(t)
%
%   str = sl.table.rowToString(t);
%
%   s = struct();
%   s.a = 1;
%   s.b = 2;
%   t = struct2table(s);

col_names = t.Properties.VariableNames;

str = '';
for i = 1:length(col_names)
    cur_name = col_names{i};
    cur_value = t.(cur_name);
    value_str = strtrim(evalc('disp(cur_value)'));
    str = [str cur_name ':' value_str ', '];
end

str(end-1:end) = [];


end