function names = getRunningProcessNames()
%
%   names = sl.os.dotnet.getRunningProcessNames(varargin)
%
%   Optional Inputs
%   ---------------

    in.unique_only = true;
    in = sl.in.processVarargin(in,varargin);

    p = System.Diagnostics.Process.GetProcesses();

    names = cell(p.Length,1);
    for i = 1:length(names)
       names{i} = char(p(i).ProcessName);
    end

    if in.unique_only
       names = unique(names); 
    end
    
end