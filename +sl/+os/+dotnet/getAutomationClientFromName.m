function auto_client = getAutomationClientFromName(name)
%
%   auto_client = sl.os.dotnet.getAutomationClientFromName(name)
%
%   Examples
%   --------
%   auto_client = sl.os.dotnet.getAutomationClientFromName('excel');

if isempty(which('System.Windows.Automation.AutomationElement'))
    %This may only work for the newer .NET framework
    asm = NET.addAssembly('UIAutomationClient');
end

processes = sl.os.dotnet.getProcessesByName(name);

if isempty(processes)
    auto_client = [];
elseif length(processes) > 1
    error('Multiple processes with the given name were found')
else
    p = processes{1};
    auto_client = System.Windows.Automation.AutomationElement.FromHandle(p.MainWindowHandle); 
end
    

end