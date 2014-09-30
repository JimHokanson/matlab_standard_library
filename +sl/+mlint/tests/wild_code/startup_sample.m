% If you want to automatically open the previous project when you startup
% MATLAB, then add the following command at the end of your 'startup.m'
% file. Or you can rename this file to 'startup.m' and copy into one of
% your search path (like the directory where 'pm.m' is in).


try
    addpath('path_to_the_project_manager');
    pm('startup_pm');
    addpath('path_to_the_project_manager');
catch
    disp('pm couldn''t be found');
    disp('Matlab starts without pm.m');
end
