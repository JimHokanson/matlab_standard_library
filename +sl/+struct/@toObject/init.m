function init(obj,old_obj,s,in)
%   TODO: DOCUMENTATION OUT OF DATE ----------------
%
%

initial_struct_fn = fieldnames(s);

struct_fn = fieldnames(s);

if in.remove_classes
   is_object = structfun(@isobject,s);
   obj_names = struct_fn(is_object);
   s = rmfield(s,obj_names);
   struct_fn(is_object) = [];
end


mc         = metaclass(old_obj);
prop_list  = mc.PropertyList;
prop_names = {prop_list.Name};


%Removal of properties that we can't set
%--------------------------------------------------------------------------
constant_props_mask = [prop_list.Constant];
dependent_mask      = [prop_list.Dependent];
if any(dependent_mask)
   %We can't set dependent methods which don't have a set method ...
   dependent_mask(dependent_mask) = arrayfun(@(x) isempty(x.SetMethod),prop_list(dependent_mask));
end

all_cant_set_props  = prop_names(constant_props_mask | dependent_mask);
struct_fn(ismember(struct_fn,all_cant_set_props)) = [];

%Determine properties no longer in the object
%--------------------------------------------------------------------------
not_in_class_prop_mask  = ~ismember(struct_fn,prop_names);
unassigned_struct_props = struct_fn(not_in_class_prop_mask);
struct_fn(not_in_class_prop_mask) = [];

%Removal of fields to ignore 
%--------------------------------------------------------------------------
if ~isempty(in.fields_ignore)
    %TODO: Check that ignored fields actually exist
    %
    %   Why, what would I do with this info ????
    %
    %   Might be good just to know ...
    
    if ischar(in.fields_ignore)
        in.fields_ignore = {in.fields_ignore};
    end
    
    struct_fn(ismember(struct_fn,in.fields_ignore)) = []; 
end

%TODO: Include a try/catch on private assigments

%Final assignment ...
%--------------------------------------------------------------------------
for iFN = 1:length(struct_fn)
    curField = struct_fn{iFN};
    old_obj.(curField) = s.(curField);
end


%Population of output
%--------------------------------------------------------------------------
class_props_not_in_struct = prop_names(~ismember(prop_names,initial_struct_fn));

obj.updated_object            = old_obj;
obj.unassigned_struct_props   = unassigned_struct_props;
obj.class_props_not_in_struct = class_props_not_in_struct;