classdef (Hidden) toObject < sl.obj.handle_light
    %
    %   Class:
    %   sl.struct.toObject
    %
    %   Copies fields to object from struct
    %
    %   Implementation Notes
    %   =======================================================================
    %   1) Currently there is no error thrown for missing fields
    %   2) Constant properties are not assigned to
    
    properties
        updated_object  %Object after changing props, this was for value objects ...
        unassigned_struct_props
        class_props_not_in_struct
    end
    
    %METHODS
    %- allow throwing of an error if fields are missing
    %- make sure to specify which fields are missing
    
    methods
        function obj = toObject(old_obj,s,varargin)
            %   INPUTS
            %   =======================================================================
            %   old_obj : handle or value object, for value objects the result will need to
            %         be obtained from the result object
            %
            %
            %   OPTIONAL INPUTS
            %   =======================================================================
            %   remove_classes : (default true), if true then Matlab objects are
            %   IMPROVEMENTS:
            %   =======================================================================
            %   1) Allow option to error when field doesn't exist
            %   2) Allow option to error when fields to ignore don't exist (lower
            %       priority)
            %

            in.fields_ignore  = {};
            in.remove_classes = true;
            in = sl.in.processVarargin(in,varargin);
            
            obj.init(old_obj,s,in)
        end
    end
    
end

