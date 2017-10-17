classdef io
    %
    %   sl.io
    
    properties
    end
    
    methods (Static)
        function fid = fopenWithErrorHandling(file_path,mode,varargin)
            %x Call fopen but with better error handling support
            %
            %   fid = sl.io.fopenWithErrorHandling(file_path,mode,varargin)
            %
            %   This function is basically just fopen() but it also
            %   provides more information in case the function does not
            %   work.
            %
            %   Possible Errors:
            %   ----------------
            %   1) Missing file
            %   2) Permissions error - e.g. file open by another program
            %
            %   Examples:
            %   ---------
            %   1) Open a file for reading
            %
            %   fid = sl.io.fopenWithErrorHandling(file_path,'r')
            %
            %   See Also:
            %   ---------
            %   sl.io.fileRead
            
            in.endian = 'n';
            in.encoding = '';
            in = sl.in.processVarargin(in,varargin);
            [fid, msg] = fopen(file_path,mode,in.endian,in.encoding);
            
            if fid == (-1)
                %NOTE: I've run into problems with unicode ...
                %http://www.mathworks.com/matlabcentral/answers/86186-working-with-unicode-paths
                if ~exist(file_path,'file')
                    error_msg = sl.error.getMissingFileErrorMsg(file_path);
                    error(error_msg)
                else
                    %Can we get any more detailed as to why????
                    %   perhaps via some fopen('all')
                    %
                    %TODO: This is also called from fileWrite
                    error('sl:io:fileRead:cannotOpenFile','Unable to open the specified file:\n%s\nreason: %s',file_path, msg);
                end
            end
        end
    end
    
end

