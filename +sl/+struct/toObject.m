function output = toObject(obj,s,fields_ignore,varargin)
%toObject Copies structure to object fields
%
%   [obj,extras] = sl.struct.toObject(obj,s,*fields_ignore)
%
%   NOTE: Currently there is no error thrown for missing fields
%
%   INPUTS
%   =======================================================================
%   obj : Handle object
%
%   OUTPUTS
%   =======================================================================
%   output : Class: sl.struct.toObjectResult

%   IMPROVEMENTS:
%   =======================================================================
%   1) Allow option to error when field doesn't exist
%   2) Allow option to error when fields to ignore don't exist (lower
%       priority)
%
%   TODO: Finish documentation

missing_fields = {};

fn = fieldnames(s);

mc      = metaclass(obj);
pl      = mc.PropertyList;
p_names = {pl.Name};
p_constant = p_names([pl.Constant]);

%TODO: At this point we know which properties will match and which won't

%Removal of trying to assign to a constant property
s = rmfield(s,p_constant);

%TODO: Should I warn if the constant properties have changed ?????

if exist('fields_ignore','var')

    %TODO: Check that ignored fields actually exist
    
    fn(ismember(fn,fields_ignore)) = []; 
end

for iFN = 1:length(fn)
    curField = fn{iFN};
    try
        obj.(curField) = s.(curField);
    catch
       missing_fields = [missing_fields {curField}]; %#ok<AGROW>
       %Currently we won't throw an error
    end
end

output = sl.struct.toObjectResult(obj,missing_fields);