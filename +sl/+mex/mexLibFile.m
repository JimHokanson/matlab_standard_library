function mexLibFile(file_name,varargin)
%
%   sl.mex.mexLibFile(file_name,varargin)
%
%   Optional Inputs
%   ---------------
%   move_up: default false
%       If true, the compiled file is moved up a directory.
%
%   Improvements
%   ------------
%   This file could have lots of improvements. I think it would be best
%   to create more scripts for compiling mex on its own, without the 
%   configs that Matlab provides.

%{
    sl.mex.mexLibFile('same_diff.c','move_up',true)
%}

in.move_up = false;
in = sl.in.processVarargin(in,varargin);

list_result = sl.dir.getList(sl.getRoot,'recursive',true,'file_pattern',file_name,'output_type','paths');

if length(list_result) ~= 1
    if isempty(list_result)
        error('Unable to find specified file');
    else
        error('Multiple files matching the pattern were found')
    end
end

file_path = list_result{1};

current_path = cd;
cd(fileparts(file_path))

failed = false;
try
    mex(file_name)
catch ME
    failed = true;
end

cd(current_path);

if ~failed
   if in.move_up
      mexed_file_path = sl.dir.changeFileExtension(file_path,mexext()); 
      
      parent_path = sl.dir.filepartsx(mexed_file_path,2);
      
      current_mex_file_path = fullfile(parent_path,sl.dir.changeFileExtension(file_name,mexext()));
      function_name = sl.file_path.toFunctionName(current_mex_file_path);
      
      %Asked about: https://www.mathworks.com/matlabcentral/answers/325415-unable-to-clear-mex-file
      clear(function_name)
      %We might need a mex unlock call ...
      movefile(mexed_file_path,parent_path)
   end
end

if failed
   rethrow(ME) 
end

end