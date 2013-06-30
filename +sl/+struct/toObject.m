function output = toObject(obj,s,varargin)
%toObject Copies structure to object fields
%
%   [obj,extras] = sl.struct.toObject(obj,s,varargin)
%
%   Implementation Notes
%   =======================================================================
%   1) Currently there is no error thrown for missing fields
%   2) Constant properties are not assigned to
%
%
%   TODO: DOCUMENTATION OUT OF DATE ----------------
%
%
%   INPUTS
%   =======================================================================
%   obj : handle or value object, for value objects the result will need to
%         be obtained from the result object
%
%
%   OPTIONAL INPUTS
%   =======================================================================
%   remove_classes : (default true), if true then Matlab objects are 
%       
%
%   OUTPUTS
%   =======================================================================
%   output : Class: sl.struct.toObjectResult
%
%
%   See Also:
%   sl.struct.toObjectResult



%   IMPROVEMENTS:
%   =======================================================================
%   1) Allow option to error when field doesn't exist
%   2) Allow option to error when fields to ignore don't exist (lower
%       priority)
%

in.fields_ignore  = {};
in.remove_classes = true;
in = sl.in.processVarargin(in,varargin);

initial_struct_fn = fieldnames(s);

struct_fn = fieldnames(s);

if in.remove_classes
   is_object = structfun(@isobject,s);
   obj_names = struct_fn(is_object);
   s = rmfield(s,obj_names);
   struct_fn(is_object) = [];
end


mc = metaclass(obj);
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
    %
    struct_fn(ismember(struct_fn,fields_ignore)) = []; 
end

%Final assignment ...
%--------------------------------------------------------------------------
for iFN = 1:length(struct_fn)
    curField = struct_fn{iFN};
    obj.(curField) = s.(curField);
end


%Population of output
%--------------------------------------------------------------------------
class_props_not_in_struct = prop_names(~ismember(prop_names,initial_struct_fn));

output = sl.struct.toObjectResult(obj,unassigned_struct_props,class_props_not_in_struct);