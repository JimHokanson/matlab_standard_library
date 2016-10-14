function pids = getProcessIDFromName(name)
%
%   process_id = sl.os.getProcessIDFromName(name)
%
%   Inputs
%   ------
%   name: string
%       
%
%   Examples:
%   ---------
%   process_id = sl.os.getProcessIDFromName('Excel')
%
%   process_id = sl.os.getProcessIDFromName('chrome2')

if ispc
    p = System.Diagnostics.Process.GetProcessesByName(name);
    pids = zeros(1,p.Length);
    for i = 1:length(pids)
       temp = p(i);
       pids(i) = temp.Id;
    end
    
    
    
    %Old version
% % %    %Tasklist function
% % %    %https://technet.microsoft.com/en-us/library/bb491010.aspx
% % %    DELIMITER_LINE = 3; 
% % %    SPACE_CHAR = char(32);
% % %     
% % %    [~,response_string] = system(sprintf('tasklist/fi "imagename eq %s"',name));
% % %    lines = sl.str.getLines(response_string);
% % %    
% % % % <first line is empty>  
% % % % INFO: No tasks are running which match the specified criteria.
% % %    
% % %    if length(lines) == 2
% % %        pids = [];
% % %        return
% % %    end
% % %        
% % %    %Let's look for the spaces on the line below the headers
% % %    I_space = find(lines{DELIMITER_LINE} == SPACE_CHAR,2);
% % %    indices = I_space(1):I_space(2);
% % %    pids = cellfun(@(x) str2double(x(indices)),lines(DELIMITER_LINE+1:end-1));
% % % 
% % % %Example to parse:
% % % % <first line is blank>
% % % % Image Name                     PID Session Name        Session#    Mem Usage
% % % % ========================= ======== ================ =========== ============
% % % % excel.exe                    38108 Console                    1    156,980 K
% % % % <last line is blank>  
   
   
else
   error('Only Windows is currently supported') 
end


end