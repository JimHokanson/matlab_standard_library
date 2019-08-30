function processes = getProcessesByName(name)
    %
    %   processes = sl.os.dotnet.getProcessesByName(name)
    %
    %   Output
    %   ------
    %   processes : cell array of 'System.Diagnostics.Process'
    %       
    %
    %   Example:
    %   --------
    %   processes = sl.os.dotnet.getProcessesByName('chrome')
    %
    %   See Also
    %   --------
    %   sl.os.dotnet.getRunningProcessNames
    
    %{
        processes = sl.os.dotnet.getProcessesByName('chrome')
    %}
    
    %p is a process array
    p = System.Diagnostics.Process.GetProcessesByName(name);
    
    processes = cell(1,p.Length);
    for i = 1:length(processes)
       processes{i} = p(i);
    end

end