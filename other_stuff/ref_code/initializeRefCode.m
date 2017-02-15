function initializeRefCode()
%
%   see sl.path.addRef
%
%   Adds all relevant reference folders to path

my_path = sl.stack.getMyBasePath;

add_folder = @(x)addpath(fullfile(my_path,x));

add_folder('LinePlotReducer')

end