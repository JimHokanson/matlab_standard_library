classdef calls < sl.mlint
    %
    %   Class:
    %   sl.mlint.calls
    %
    %   'calls' identifies function calls within a file.
    %
    %   Implements:
    %   -----------
    %   mlintmex('-calls')
    %
    %   Call via:
    %   ---------
    %   obj = sl.mlint.mex.calls(file_path)
    %
    %   This class exposes the mlintmex function with the '-calls' input.
    %   From what I can tell, this is equivalent to the '-callops' input.
    %
    %
    %   Issues:
    %   -------
    %   1) There is information in this function as to when a function
    %   starts and when it ends, but this is not being processed. I'm not
    %   sure what functions get this information (all with an end
    %   statement? i.e. functions don't require end but they all
    %   functionally "end") and whether the end specification
    %   always immediately follows the start specification or not or
    %   whether it is logically arranged.
    %
    %   See Also:
    %   sl.mlint
    
    %{
          dt = 0.001;
          t  = -2:dt:2;
          time_obj = sci.time_series.time(dt,length(t));
          y = chirp(-2:dt:2,100,1,200,'q');
          wtf = sci.time_series.data(y',time_obj);
    
          w = sl.mlint.all(which(class(wtf)));
          c = w.calls
    
    %}
    
    %Assumptions:
    %----------------------------------------------------------------------
    %1) End functions always immediately follow the start function
    
    %Questions:
    %----------------------------------------------------------------------
    %1) Do declarations show up as calls, or just calls to these functions?
    %
    %   The declarations definitely show up as calls. These are resolved.
    %   The calls to these functions show up as unresolved.
    
    properties
        d0 = '----  From raw mlintmex call   ----'
        %Following are properties that are parsed from the mlintmex call.
        %-------------------------------------------------------------------
        line_numbers         %[1 x n]
        %1 based?
        column_I %[1 x n]
        %1 based?
        absolute_I %[1 x n]
        
        n_calls 
        
        fcn_call_types       %[1 x n], this describes the type of
        %function call such as a main function, anonymous, or sub-function
        %
        %A - anonymous function
        %M - main method in file
        %E - end of function
        %    I think this doesn't exist for anonymous functions
        %N - nested functions
        %S - subfunction, functions in classdef including constructors
        %    show up as this, not as M
        %U - called function, unresolved
        
        depths           %[1 x n], depth in the file of the function call,
        %Top most functions are at depth 0.
        fcn_names       %{1 x n} Name of the function or call being made.
        %Anonymous functions lack a name.
    end
    
    methods
        function value = get.absolute_I(obj)
           value = obj.absolute_I;
           if isempty(value)
              value = obj.getAbsIndicesFromLineAndColumn(obj.line_numbers,obj.column_I);
              obj.absolute_I = value;
           end
        end
    end
    
    properties
        unique_fcn_names
        unique_fcn_I
    end
    
    methods
        function value = get.unique_fcn_names(obj)
            value = obj.unique_fcn_names;
            if isempty(value)
                h__populateUniqueFcns(obj);
                value = obj.unique_fcn_names;
            end
        end
        function value = get.unique_fcn_I(obj)
            value = obj.unique_fcn_I;
            if isempty(value)
                h__populateUniqueFcns(obj);
                value = obj.unique_fcn_I;
            end
        end
    end
    
    methods
        function obj = calls(file_path)
            %
            %   obj = sl.mlint.calls(file_path)
            
            
            obj.file_path = file_path;
            
            %NOTE: The -m3 specifies not to return mlint messages
            obj.raw_mex_string    = mlintmex(file_path,'-calls','-m3');
            
            %TODO: Handle when the raw_mex_string is empty ...
            
            c = textscan(obj.raw_mex_string,'%*s %f %f %s');
            
            obj.line_numbers = c{1}';
            obj.column_I     = c{2}';
            obj.fcn_names    = c{3}';
            
            obj.n_calls = length(obj.fcn_names);
            
            c2 = regexp(obj.raw_mex_string,'^(?<type>\w+)(?<depth>\d+)','lineanchors','names');
            
            obj.fcn_call_types  = {c2.type};
            
            obj.depths = cellfun(@helper_str2int,{c2.depth});
        end
        function fcn_call = getFunctionCallInfo(obj,I)
            %
            %   f = getFunctionCallInfo(obj,I);
            %
            %   Inputs:
            %   -------
            %   I : scaler
            %   
            %   Outputs:
            %   --------
            %   f : 
            %
            
            fcn_call = sl.mlint.fcn_call(obj,I);
        end
    end
    
end

function h__populateUniqueFcns(obj)
[u,uI] = sl.array.uniqueWithGroupIndices(obj.fcn_names);
obj.unique_fcn_names = u;
obj.unique_fcn_I = uI;
end

function output = helper_str2int(str)
output = sscanf(str,'%d',1);
end

function helper_examples()
t = sl.mlint.tester;

wild_paths = t.f_wild.file_paths;
n_wild = length(wild_paths);
all_types = cell(1,n_wild);
types_with_ends = cell(1,n_wild);
for iWild = 1:length(wild_paths);
    cur_file_path = wild_paths{iWild};
    wtf = sl.mlint.calls(cur_file_path);
    temp_types = wtf.fcn_call_types;
    %     if any(strcmp(temp_types,'A'))
    %        keyboard
    %     end
    all_types{iWild} = temp_types;
    types_with_ends{iWild} = wtf.fcn_call_types(find(strcmp(temp_types,'E'))-1);
end

%   unique([all_types{:}])
%   unique([types_with_ends{:}])


end