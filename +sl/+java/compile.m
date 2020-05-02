function compile(java_target)
%
%   sl.java.compile(java_target)
%
%   This was thrown together rather hastily

if ~exist(java_target,'file')
    error('Requested target for compiling doesn''t exist')
end

%TODO: Could add options ...
javac_path = h__getCompilerPath();
cmd = sprintf('"%s" "%s"',javac_path,java_target);
[status,result] = system(cmd);
if status ~= 0
    error(result)
end


end

function p = h__getCompilerPath()
%
%   p = h__getCompilerPath()
%
%   TODO: Not sure if Matlab provides one ...

ml_java_version = version('-java');
%'Java 1.8.0_181-b13 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode

java_main_version = regexp(ml_java_version,'1\.\d+','match','once');
%e.g. 1.8

if ispc
    %TODO: Support JAVA HOME
    root_dir = 'C:\Program Files\Java';
    %TODO: Not sure when dir started supporting new format
    %2016ish
    d = dir(fullfile(root_dir,'**/javac.exe'));
    if isempty(d)
        error('either no compiler was found, OR, your Matlab version is too old to support the subdirectory call format of **')
    end
else
    error('not yet implemented')
end

match_mask = arrayfun(@(x) ~isempty(strfind(x.folder,java_main_version)),d);

d2 = d(match_mask);
if isempty(d2)
    error('Unable to find Java Compiler')
else
    %TODO: Eventually we could be better about trying
    %to match subversions or getting the latest ...
    %
    %For now we grab the last one
    p = fullfile(d2(end).folder,d2(end).name);
end
end