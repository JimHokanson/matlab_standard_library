classdef class < dynamicprops
    %   
    %
    %   Class:
    %   sl.gui.class
    %
    %   set(0,'HideUndocumented',true)
    
    %     properties (Abstract)
    %
    %     end
    
    properties (Hidden)
        CLASS_HANDLE
    end
    
    methods
        function obj = class(handle)
            obj.CLASS_HANDLE = handle;
            temp = get(handle);
            
            fn = fieldnames(temp);
            for iFN = 1:length(fn)
                cur_field_name = fn{iFN};
                d = addprop(obj,cur_field_name);
                d.SetMethod = @(obj,value) obj.genericSet(cur_field_name,value);
                d.GetMethod = @(obj) obj.genericGet(cur_field_name);
            end
        end
        function genericSet(obj,prop_name,value)
              set(obj.CLASS_HANDLE,prop_name,value);
%             temp = dynamic_prop_ref.SetMethod;
%             dynamic_prop_ref.SetMethod = []; %function_handle.empty;
%             obj.(prop) = value;
%             dynamic_prop_ref.SetMethod = temp;
        end
        function value = genericGet(obj,prop_name)
           value = get(obj.CLASS_HANDLE,prop_name);
        end
    end
    
end

