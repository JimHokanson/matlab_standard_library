classdef header
    %
    %   Class:
    %   sl.io.zlib.header
    %
    %   Based On:
    %   https://stackoverflow.com/questions/9050260/what-does-a-zlib-header-look-like
    
    %{
    
    h = sl.io.zlib.header([120 156]);
    h = sl.io.zlib.header([120 1]);
    
    %}
    
    properties
        hex
        cmf %Normally 78
        flags
        compression_method %8 - deflate
        compression_info %
        %base-2 logarithm of the LZ77 window size
        %7 => 32K window size
    end
    
    
    methods
        function obj = header(bytes)
            %
            %   
            
            bytes = uint8(bytes);
            
            obj.hex = arrayfun(@dec2hex,bytes,'un',0);
            obj.cmf = bytes(1);
            obj.flags = bytes(2);
            
            %CMF processing
            %--------------
            % bits 0 to 3  CM     Compression method
            %
            % bits 4 to 7  CINFO  Compression info CM (Compression method)
            % This identifies the compression method used in the file. CM =
            % 8 denotes the "deflate" compression method with a window size
            % up to 32K. This is the method used by gzip and PNG and almost
            % everything else. CM = 15 is reserved.
            % 
            % CINFO (Compression info) For CM = 8, CINFO is the base-2
            % logarithm of the LZ77 window size, minus eight (CINFO=7
            % indicates a 32K window size). Values of CINFO above 7 are not
            % allowed in this version of the specification. CINFO is not
            % defined in this specification for CM not equal to 8.
            
            
            %
            obj.compression_method = sl.io.tc.getBitNumber(bytes(1),1,4);
            obj.compression_info = sl.io.tc.getBitNumber(bytes(1),5,8);
        end
            
    end
    
end

