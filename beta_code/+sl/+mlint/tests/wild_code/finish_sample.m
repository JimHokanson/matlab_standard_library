% If you want to automatically save the project when you exit MATLAB, then
% add the following command at the end of your 'finish.m' file. Or you can
% rename this file to 'finish.m' and copy into one of your search
% directory (like the directory where 'pm.m' is in).

try
    pm('finish_pm');
catch
    disp('pm couldn''t be found');
    disp('exiting without saving project');
end

