function varargout = splitAndProcessVarargin(in,varargin_data,names,varargin)
%x Takes optional inputs meant for different subfunctions and splits them
%
%
%   varargout = sl.in.splitAndProcessVarargin(in,varargin_data,names,varargin);
%
%   This function was written to support having optional inputs that 
%   were meant for different functions in the same parent function.
%
%   The example below shows how to build up the function.
%
%   Keeping Subfunction defaults
%   ----------------------------
%   Sometimes the defaults are built off of the data itself or the 
%   calling function doesn't wish to specify a default and would rather
%   keep the default of the subfunction being called. If a value is
%   specified as "null" the variable will not exist in the output struct
%   UNLESS the user has specified an input value.
%
%   Example:
%   --------
%   in.filter_data = true;
%   s1 = fieldnames(in);
%   in.case_sensitive = false;
%   in.partial_match  = true;
%   in.multiple_channel_rule = 'error';
%   s2 = fieldnames(in);
%   in.return_object  = true;
%   in.data_range     = sl.in.NULL;
%   in.time_range     = sl.in.NULL; 
%   in.get_as_samples = true;      
%   in.leave_raw      = false;
%   s3 = fieldnames(in);
%   [in,in_name,in_data] = sl.in.splitAndProcessVarargin(in,varargin,{s1,s2,s3});
%
%   stringMatchingFunction(input1,input2,in_name);
%
%   %in.data_range won't exist unless the user has specified it in varargin
%   data = dataFunction(input3,in_data);
%
%   if in.filter_data
%      %filter data
%   end
%
%   -------------------------------------------------
%
%   See Also:
%   ---------
%   sl.in.NULLs 



n_names = length(names);
n_out = nargout;

if n_names ~= n_out
    error('The # of outputs should be equal to the number of input name sets')
end


%We need to split the names by each section
%This is hard for the user to write cleanly so we split here.
%
%   names{1} = first set of fieldnames
%   names{2} = first and second set of fieldnames
%   names{3} = first, second, and third set of fieldnames
%
%   An earlier algorithm was calling setdiff in the caller, but the
%   following problem was encountered
%
%        e.g.:
%        in.a = 1;
%        s1 = fieldnames(in)
%        in.b = 1;
%        in.c = 2;
%        s2 = setdiff(fieldnames(in),s1)
%        in.d = 5
%        s3 = setdiff(fieldnames(in),s2)
%
%   This example code above looks like it will identify the components
%   defined in each section, but in this example s3 will incorrectly
%   contain 'a', since 'a' is not in s2
%
%   i.e. s3 => {'a' 'd'} when it should be just {'d'}
%
%   In this loop below, names is cumulative, so we don't run into this
%   problem
real_names = cell(1,n_names);
real_names{1} = names{1};
for iName = 2:n_names
   real_names{iName} = setdiff(names{iName},names{iName-1}); 
end
names = real_names;


if iscell(varargin_data)
   varargin_data = sl.in.propValuePairsToStruct(varargin_data); 
else
   %This should be straightforward but I just want to see how it comes in
   error('Not yet implemented')
end

new_names = fieldnames(varargin_data);
for iNew = 1:length(new_names)
    cur_name = new_names{iNew};
    if isfield(in,cur_name)
        in.(cur_name) = varargin_data.(cur_name);
    else
        %TODO: Provide a clickable link to valid field names ...
        error('Specified field: "%s" is not a valid optional input',cur_name);
    end
end

varargout = cell(1,nargout);
for iOut = 1:length(names)
   name_set = names{iOut};
   s = struct;
   for iName = 1:length(name_set)
       cur_name = name_set{iName};
       cur_value = in.(cur_name);
       if ~isa(cur_value,'sl.in.NULL')
          s.(cur_name) = in.(cur_name);
       end
   end
   varargout{iOut} = s;
end

end