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



struct_fn = fieldnames(s);

if in.remove_classes
   keyboard 
   is_object = structfun(@isobject,s);
   obj_names = struct_fn(is_object);
   s = rmfield(s,obj_names);
   struct_fn(is_object) = [];
end


mc = metaclass(obj);
prop_list = mc.PropertyList;

prop_names     = {prop_list.Name};
constant_props = prop_names([prop_list.Constant]);


%TODO: Eventually write a double setdiff method as this is horribly
%inefficient ..
valid_struct_fields_mask = ismember(struct_fn,prop_names);
missing_props_mask       = ~ismember(prop_names,struct_fn);

s = rmfield(s,constant_props);

is_constant_struct_fn = ismember(struct_fn,constant_props);

%Grab constant fields
%NOTE: Not using this currently ...
% % % s_const     = rmfield(s,struct_fn(~is_constant_struct_fn));
%Removal of trying to assign to a constant property
% % % % s_non_const = rmfield(s,struct_fn(is_constant_struct_fn));

valid_struct_fields_mask = valid_struct_fields_mask(~is_constant_struct_fn);
struct_fn                = struct_fn(~is_constant_struct_fn);

unassigned_struct_props   = struct_fn(~valid_struct_fields_mask);
class_props_not_in_struct = prop_names(missing_props_mask);

if ~isempty(in.fields_ignore)
    %TODO: Check that ignored fields actually exist
    %
    %   Why, what would I do with this info ????
    struct_fn(ismember(struct_fn,fields_ignore)) = []; 
end

for iFN = 1:length(struct_fn)
    curField = struct_fn{iFN};
% % % %     try
        obj.(curField) = s.(curField);
% %     catch
% %        missing_fields = [missing_fields {curField}]; %#ok<AGROW>
% %        %Currently we won't throw an error
% %     end
end

output = sl.struct.toObjectResult(obj,unassigned_struct_props,class_props_not_in_struct);