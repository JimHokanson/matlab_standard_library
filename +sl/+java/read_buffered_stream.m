function output = read_buffered_stream(stream)
%
%   output = sl.java.read_buffered_stream(stream)
%
%   This was originally developed to facilitate communication with stdout
%   and stderr for a Java process but I'm not currently using it.
%   
%   Inputs:
%   -------
%   stream: java.io.

if nargin == 0
    %output = 
    base_path = sl.stack.getMyBasePath();
    output = fullfile(base_path,'read_buffered_stream','bin'); %,'buffered_reader.class');
else
    output = char(buffered_reader.readData(stream));
end

end