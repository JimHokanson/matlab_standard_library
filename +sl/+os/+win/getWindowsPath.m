function getWindowsPath()

[status,result] = system('echo %PATH%')

raw_path = result;
path_values = regexp(raw_path,';','split');

end