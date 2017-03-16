function flag = isField(table,fieldname)
%x Determine if field is present in table
%   
%   flag = sl.table.isField(table,fieldname)

flag = any(strcmp(fieldname,table.Properties.VariableNames));


end