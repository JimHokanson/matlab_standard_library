function output = concatenate(varargin)
%
%   output = sl.struct.concatenate(varargin);
%

%Optional inputs not yet handled
%Need to look for first non-structure entry
in.cat_direction = 'h'; %v - NYI
in.string_null = '';
in.numeric_null = NaN; %0,
in.missing_callback = [];
%in = sl.in.processVarargin(in,varargin);

%Outputs:
%------------
%names
%- matrix of which were missing
%=> this might be better for

%Order???
%------------------
%1st seen is first out
%-> merge all fieldnames

%Might be a useful reference
%-----------------------------
%https://github.com/johwing/matlab_structure_utility/blob/master/cat_struct.m

%sl.struct.results.concatenation

structs = varargin;
n_structs = length(structs);
all_field_names = cellfun(@fieldnames,structs,'un',0);

%TODO: Improve speed by working with #s, not fields names
u_fields = unique(vertcat(all_field_names{:}),'stable');

struct_d1 = cellfun(@(x) size(x,1),structs);
struct_d2 = cellfun(@(x) size(x,2),structs);

%TODO: We could short circuit here early ...

if in.cat_direction == 'h'
    %d1 needs to be the same
    if ~sl.array.allSame(struct_d1)
        error('Horizontal concatenation requires the same # of rows in all structs')
    end
    output_size = [struct_d1(1) sum(struct_d2)];
else
    if ~sl.array.allSame(struct_d2)
        error('Vertical concatenation requires the same # of columns in all structs')
    end
    output_size = [sum(struct_d1) struct_d2(1)];
end

values = cell(n_structs,output_size(1),output_size(2));
is_missing = true(n_structs,output_size(1),output_size(2));

end_I = 0;

if in.cat_direction == 'h'
    changing_dim_size = struct_d2;
else
    changing_dim_size = struct_d1;
end

struct_cells = cellfun(@struct2cell,structs,'un',0);

for iStruct = 1:n_structs
    %cur_struct = structs{iStruct};
    cur_struct_cell = struct_cells{iStruct};
    cur_fields = all_field_names{iStruct};
    [mask,loc] = ismember(cur_fields,u_fields);
    
    start_I = end_I + 1;
    end_I = start_I + changing_dim_size(iStruct)-1;
    
    if in.cat_direction == 'h'
        values(loc(mask),:,start_I:end_I) = cur_struct_cell(mask,:,:);
        is_missing(loc(mask),:,start_I:end_I) = false;
    else
        values(loc(mask),start_I:end_I,:) = cur_struct_cell(mask,:,:);
        is_missing(loc(mask),start_I:end_I,:) = false;
    end
end

output = sl.struct.results.concatenation(u_fields,values,is_missing,in);

end

function h__test1()


s1.a = 1;
s1.b = 2;
s1.c = 'test';

s2.a = 3;
s2.b = 5;

s3.c = 'hi';
s3.b = 10;


s4.d = 'wtf man';

s_obj = sl.struct.concatenate(s1,s2,s3,s4);

end