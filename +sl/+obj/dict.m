classdef dict < handle
    %
    %   Class:
    %   dict
    %
    %   http://undocumentedmatlab.com/blog/class-object-tab-completion-and-improper-field-names
    
    properties (Access = 'protected')
        props
    end
    
    methods
        function obj = dict()
            obj.props = containers.Map;
        end

    end
    
    methods (Hidden=true)
        function mask = isfield(obj,field_or_fieldnames)
           if ischar(field_or_fieldnames)
               field_or_fieldnames = {field_or_fieldnames};
               mask = ismember(field_or_fieldnames,obj.props.keys());
           end
        end
        % Overload property names retrieval
        function names = properties(obj)
            names = fieldnames(obj);
        end
        % Overload fieldnames retrieval
        function names = fieldnames(obj)
            names = sort(obj.props.keys);  % return in sorted order
        end
        % Overload property assignment
        function obj = subsasgn(obj, subStruct, value)
            if strcmp(subStruct.type,'.')
                try
                    obj.props(subStruct.subs) = value;
                catch
                    error('Could not assign "%s" property value', subStruct.subs);
                end
            else  % '()' or '{}'
                error('not supported');
            end
        end
        % Overload property retrieval (referencing)
        function value = subsref(obj, subStruct)
%             persistent class_method_name_map
%             if isempty(class_method_name_map)
%                class_method_names = sl.obj.meta.getAllClassMethodNames(obj);
%                class_method_name_map = containers.Map;
%                for iName = 1:length(class_method_names)
%                    cur_name = class_method_names{iName};
%                    class_method_name_map
%             end
            s1 = subStruct(1);
            if strcmp(s1.type,'.')
                try
                    value = obj.props(s1.subs);
                    prop_lookup_failed = false;
                catch
                    prop_lookup_failed = true;
                    %TODO: Might want to look for s1.subs being a method
                    %see commented out code above
                    builtin('subsref', obj, subStruct)
                    %error('"%s" is not defined as a property', s1.subs);
                end
                if ~prop_lookup_failed && length(subStruct) > 1
                value = subsref(value,subStruct(2:end)); 
                end
            else  % '()' or '{}'
                error('not supported');
            end

        end
        function disp(obj)
            %TODO: This was written when inheriting from
            %containers.Map and could be simplified 
            k = obj.props.keys;
            v = obj.props.values;
            key_length = cellfun(@length,k);
            padding_length = max(key_length) - key_length;
            key_displays = cellfun(@(x,y) [blanks(x) y],...
                num2cell(padding_length),k,'un',0);
            for iK = 1:length(k)
                cur_key = k{iK};
                cur_key_display = key_displays{iK};
                
                I = find(strcmp(k,cur_key),1);
                cur_value = v{I};
                
                %Not working "inside" the class
                %cur_value = obj(cur_key);
                %TODO: Add is logical
                if isnumeric(cur_value) && isscalar(cur_value)
                    fprintf('%s: %d\n',cur_key_display,cur_value);
                elseif ischar(cur_value)
                    fprintf('%s: %s\n',cur_key_display,cur_value);
                else
                    temp_size = sprintf('%dx',size(cur_value));
                    %Need to drop the extra 'x' in temp_size
                    fprintf('%s: [%s %s]\n',cur_key_display,temp_size(1:end-1),class(cur_value));
                end
            end
        end
    end
    
end

