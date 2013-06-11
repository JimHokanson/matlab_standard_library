classdef (Hidden) toObjectResult
    %
    %   Class:
    %   sl.struct.toObjectResult
    %   
    
    properties
       updated_object
       missing_fields
    end
    
    %METHODS
    %- allow throwing of an error if fields are missing
    %- make sure to specify which fields are missing 
    
    methods
        function obj = toObjectResult(updated_object,missing_fields)
           obj.updated_object = updated_object;
           obj.missing_fields = missing_fields;
        end
    end
    
end

