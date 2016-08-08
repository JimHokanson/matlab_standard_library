classdef multi_parameter_testing
    %
    %   Class:
    %   sci.optimization.multi_parameter_testing
    %
    %   
    %
    %   IMPROVEMENTS:
    %   -------------
    %   1) It might be useful to allow expansion of parameters across a 
    %   given dimension
    
    %{
    s = struct;
    s.a = 1:2;
    s.b = {'cheese','temp','testing'};
    s.c = 10:10:50;
    
    
    %}
        
    
    properties
       column_names
    end
    
    methods
        function obj = multi_parameter_testing(params_to_vary,function_handle)
           %
           %
           %    obj = sci.optimization.multi_parameter_testing(params_to_vary,function_handle) 
            
            
            %We could allow returning a structure of values
            %like slope and intercept for regression
            
            obj.column_names = fieldnames(params_to_vary);
            
            param_lengths = structfun(@length,params_to_vary);
            
            n_tests = prod(param_lengths);
            n_params = length(obj.column_names);
            
            %The following could go into a permutation and combinations
            %sort of package ...
            %
            %NOTE: With the first dimension varying the fastest, we are
            %actually going in linear indexing order
            %--------------------------------------------------------------
            test_indices = ones(n_tests,n_params);
            cur_counts   = ones(1,n_params);
            for iTest = 2:n_tests
               for iParam = 1:n_params
                  if cur_counts(iParam) ~= param_lengths(iParam)
                      cur_counts(iParam) = cur_counts(iParam) + 1;
                      break
                  else
                     %reset and increae the next guy
                     cur_counts(iParam) = 1; 
                  end
               end
               test_indices(iTest,:) = cur_counts;
            end
            
            keyboard
            
            result_data = zeros(param_lengths);
            
            %--------------------------------------------------------------
            cell_params = struct2cell(params_to_vary);
            fn = fieldnames(params_to_vary);
            for iTest = 1:n_tests

               %s will contain the variables for the current iteration
               s = struct;
               for iField = 1:length(fn)
                  cur_field = fn{iField};
                  cur_index = test_indices(iTest,iField);
                  s.(cur_field) = cell_params{iField}(cur_index);
               end
               
               
                
                
            end
            
            
            keyboard
           
        end
    end
    
end

