function path_entries = asCellstr(varargin)
%sl.path.asCellstr  Retrieves Matlab path as a cellstr
%
%   path_entries = sl.path.asCellstr()
%
%   OPTIONAL INPUTS
%   =======================================================================
%   remove_mtool : (default false), If true any sub directories
%       of the matlab root are removed
%
%   See Also:

in.remove_mtool = false;
in = sl.in.processVarargin(in,varargin);

p = path;
path_entries = sl.path.toCellstr(p);

if in.remove_mtool
   path_entries(sl.path.matchSubdirectories(path_entries,matlabroot)) = [];
end

end



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