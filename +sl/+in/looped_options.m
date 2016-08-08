classdef looped_options < handle
    %
    %   Class:
    %   sl.in.looped_options
    %
    %   This class was created to allow options that vary in a loop
    %
    %   See sci.time_series.data
    %
    %   TODO: Add more documentation
    
    properties
        orig_options %Usually a struct, unless we are not going to do
        %modifications to the output, then we will set it up based on the
        %return type
        loop_option_names;
        return_type
        current_index = 0
        return_original = false
    end
    
    methods
        function obj = looped_options(orig_options,potential_loop_option_names,varargin)
            in.return_type = 'cell';
            in = sl.in.processVarargin(in,varargin);
            
            
            obj.orig_options = orig_options;
            obj.return_type = in.return_type;
            
            if isempty(orig_options)
                obj.return_original = true;
                if strcmp(in.return_type,'cell')
                    obj.orig_options = {};
                else
                    obj.orig_options = struct;
                end
            else
                %What looping variable do we have ...
                if iscell(orig_options)
                    orig_options = sl.in.propValuePairsToStruct(orig_options,'force_lower',true);
                end
                
                prop_names = fieldnames(orig_options);
                
                potential_loop_option_names = lower(potential_loop_option_names);
                
                potential_loop_option_names(~ismember(potential_loop_option_names,prop_names)) = [];

                %Loop through the remaining variables, if any of them
                %have multiple sizes
                keep_mask = true(1,length(potential_loop_option_names));
                for iName = 1:length(potential_loop_option_names)
                    cur_name = potential_loop_option_names{iName};
                    cur_value = orig_options.(cur_name);
                    if length(cur_value) == 1
                        keep_mask(iName) = false;
                    else
                        if ~iscell(cur_value)
                            orig_options.(cur_name) = num2cell(cur_value);
                        end
                        %TODO: Ensure all values are cells so we don't need
                        %to check below
                        %We'll currently support
                    end
                end
                
                obj.loop_option_names = potential_loop_option_names(keep_mask);
                
                if ~any(keep_mask)
                    obj.return_original = true;
                    if strcmp(in.return_type,'cell')
                        obj.orig_options = sl.in.structToPropValuePairs(orig_options);
                    else
                        obj.orig_options = orig_options;
                    end
                else
                    obj.orig_options = orig_options;
                end
            end
            
        end
        function output = getNext(obj)
            %Replace all original options that vary with their singular loop values...

            if obj.return_original
               output = obj.orig_options;
               return
            end
            
            cur_I = obj.current_index + 1;
            obj.current_index = cur_I;
            output = obj.orig_options;
            for iOption = 1:length(obj.loop_option_names)
               cur_name = obj.loop_option_names{iOption};
               output.(cur_name) = output.(cur_name){cur_I};
            end
            
            if strcmp(obj.return_type,'cell')
               output = sl.in.structToPropValuePairs(output); 
            end
            
        end
    end
    
end

