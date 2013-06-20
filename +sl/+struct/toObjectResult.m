classdef (Hidden) toObjectResult
    %
    %   Result of function:  sl.struct.toObject
    %
    %   Class:
    %   sl.struct.toObjectResult
    %   
    %   See Also:
    %   sl.struct.toObject
    
    properties
       updated_object  %Object after changing props, for 
       unassigned_struct_props
       class_props_not_in_struct
    end
    
    %METHODS
    %- allow throwing of an error if fields are missing
    %- make sure to specify which fields are missing 
    
    methods
        function obj = toObjectResult(...
                updated_object,...
                unassigned_struct_props,...
                class_props_not_in_struct)
           obj.updated_object            = updated_object;
           obj.unassigned_struct_props   = unassigned_struct_props;
           obj.class_props_not_in_struct = class_props_not_in_struct;
        end
    end
    
end

