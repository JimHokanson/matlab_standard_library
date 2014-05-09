function out = fileRead(file_path,type,varargin)
%fileRead
%
%   out = sl.io.fileRead(file_path,type,varargin)
%
%   Similiar to fileread() except that it allows specification of a single
%   fread type, like uint8
%
%   Inputs
%   -----------------------------------------------------------------------
%   type   : passed directly into fread
%
%   Optional Inputs
%   -----------------------------------------------------------------------
%   endian : (default 'n')
%
%   example:
%   -------------------------------------------------------------
%   out = sl.io.fileRead(file_path,'*uint8')

in.endian = 'n';
in = sl.in.processVarargin(in,varargin);

% 'native'      or 'n' - local machine format - the default
% 'ieee-le'     or 'l' - IEEE floating point with little-endian
%                        byte ordering
% 'ieee-be'     or 'b' - IEEE floating point with big-endian
%                        byte ordering
% 'ieee-le.l64' or 'a' - IEEE floating point with little-endian
%                        byte ordering and 64 bit long data type
% 'ieee-be.l64' or 's' - IEEE floating point with big-endian byte
%                        ordering and 64 bit long data type.


% open the file
if ischar(file_path)
    [fid, msg] = fopen(file_path,'r',in.endian);
    
    if fid == (-1)
        %NOTE: I've run into problems with unicode ...
        %http://www.mathworks.com/matlabcentral/answers/86186-working-with-unicode-paths
        if ~exist(file_path,'file')
            error('Specified file does not exist:\n%s\n',file_path)
        else
            error(message('sl:io:fileRead:cannotOpenFile', filename, msg));
        end
    end
    
    try
        % read file
        out = fread(fid,type)';
    catch exception
        % close file
        fclose(fid);
        throw(exception);
    end
    
    % close file
    fclose(fid);
else
    
    %'source' - output as double
    %'source=>output'
    %'*source' - keep input type
    %'N*source' or 'N*source=>output'
    
    %Note: endian wouldn't be handled ...
    
    if type(1) == '*'
        type = type(2:end);
        out  = typecast(org.apache.commons.io.FileUtils.readFileToByteArray(file_path),type);
    else
        error('Conversion type: "%s" not supported yet',type)
    end
    
end
