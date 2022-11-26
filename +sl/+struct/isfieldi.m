function [flag,name] = isfieldi(s,field_or_fieldnames)
%X case insensitive field name check
%
%   [flag,name] = sl.struct.isfieldi(s,field)
%
%   [mask,names] = sl.struct.isfieldi(s,fieldnames)
%
%   Examples
%   --------
%   s = struct;
%   s.A = 1;
%   s.B = 2;
%   s.C = 3;
%   s.test = 'test';
%   [flag,name] = sl.struct.isfieldi(s,'a');
%   
%   [mask,names] = sl.struct.isfieldi(s,{'a','B','d','Test'});

    fn = fieldnames(s);

    if length(field_or_fieldnames) == 1
        field = field_or_fieldnames;
        mask = strcmpi(fn,field);
        if any(mask)
            flag = true;
            name = fn{mask};
        else
            flag = false;
            name = '';
        end
    else
        input_names = field_or_fieldnames;
        n_inputs = length(input_names);
        mask = false(1,n_inputs);
        names = cell(1,n_inputs);
        for i = 1:n_inputs
            mask2 = strcmpi(fn,input_names{i});
            if any(mask2)
                mask(i) = true;
                names{i} = fn{mask2};
            else
                names{i} = '';
            end
        end
        flag = mask;
        name = names;
    end
end