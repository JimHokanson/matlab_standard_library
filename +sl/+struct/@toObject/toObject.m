classdef toObject < sl.obj.handle_light
    %
    %   Class:
    %   sl.struct.toObject
    %
    %   Copies fields to object from struct.
    %
    %   The resulting object is a property of this object.
    %
    %   I created an object because there was additional information
    %   besides just the converted object that I wanted to hold onto.
    %   Since I didn't know how complicated it was going to get I decided
    %   to create the temporary conversion object.
    %
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
        function obj = toObject(s,old_obj,varargin)
            %
            %
            %   :/ I should really switch the input order
            %
            %   Inputs first, then pointers ...
            %
            %
            %   Inputs:
            %   -------
            %   old_obj : handle or value object
            %       For value objects the result will need to be obtained 
            %       from the result object. For handle objects the object
            %       is modified in place.
            %
            %
            %   Optional Inputs:
            %   ----------------
            %   remove_classes : logical (default true),
            %       If true then Matlab objects are
            %
            %   Improvements:
            %   -------------
            %   1) Allow option to error when field doesn't exist
            %   2) Allow option to error when fields to ignore don't exist (lower
            %       priority)
            %

            in.fields_ignore  = {};
            in.remove_classes = true;
            in = sl.in.processVarargin(in,varargin);
            
            %sl.struct.toObject.init
            obj.init(old_obj,s,in)
        end
    end
    
end

