function path_entries = asCellstr(varargin)
%x  Retrieves Matlab path as a cellstr
%
%   path_entries = sl.path.asCellstr()
%
%   Optional Inputs:
%   ----------------
%   remove_mtool : (default false), 
%       If true any sub directories of the matlab root are removed. 
%   user_added_only : (default false)
%       This returns only paths that the user has explicitly added.
%
%   Examples:
%   ---------
%   path_entries = sl.path.asCellstr()
%
%   path_entries = sl.path.asCellstr('remove_mtool',true)
%
%   path_entries = sl.path.asCellstr('user_added_only',true)
%
%   See Also:
%   path
%   userpath

in.user_added_only = false;
in.remove_mtool = false;
in = sl.in.processVarargin(in,varargin);

if in.user_added_only
   in.remove_mtool = true; 
end

p = path();
path_entries = sl.path.toCellstr(p);

if in.remove_mtool
   path_entries(sl.path.matchSubdirectories(path_entries,matlabroot)) = [];
end

if in.user_added_only
   up = userpath();
   temp = sl.path.toCellstr(up);
   if length(temp) > 1
       error('The userpath is only expected to have a single path')
   end
   temp = temp{1}; %This should only a single value
   path_entries(strcmp(temp,path_entries)) = [];
end

end


%TODO: This needs to be moved to a real test class
%I'm playing around with this a bit ...
function helper__never_called() %#ok<DEFNU>
%sl.test.runInFunction('sl.path.asCellstr')
%@TEST_CODE

%@EXAMPLE
path_entries1 = sl.path.asCellstr();

%@EXAMPLE
path_entries2 = sl.path.asCellstr('remove_mtool',true);

%TODO: Add tests ...

%@END_TEST_CODE
end