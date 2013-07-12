function path_entries = asCellstr()
%
%
%   path_entries = sl.path.asCellstr()
%
%   IMPROVEMENTS:
%   1) Allow removal of Matlab toolboxes

%in.remove_mtool = false;
%in = sl.in.processVarargin(in,varargin);

p = path;
path_entries = sl.path.toCellstr(p);