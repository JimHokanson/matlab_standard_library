classdef classHasNoPropertyOrMethod < sl.error.ml.base
    %
    %   Class:
    %   sl.error.ml.subscripting.classHasNoPropertyOrMethod
    %  
    %   TODO: Inherit from some abstract class
    
    %{
    Reasons:
    1) The error is often deeeper and actually has 
    
    
    Solutions:
    1) The 2nd dot might not actually exist:
    
    e.g.
        'The class dba has no property or method named ''options''.'
    dba.options.my_class %<= doesn't exist
    dba.options.my_existing_class %<= does exist
    
    So the problem isn't with dba or options, but with the next part
    
    TODO: Extract the components of the dot indexing
    
    %}
    
    properties
       identifier = 'MATLAB:subscripting:classHasNoPropertyOrMethod'
       is_dynamic = true
       error_msg = ''
       example_msgs = {
           'The class dba has no property or method named ''options''.'}
    end
    
    methods
    end
    
end

