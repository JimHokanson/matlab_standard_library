classdef savitzky_golay
    %
    %   Class:
    %   sci.time_series.filter.savitzky_golay
    %
    %   TODO: Finish documentation
    %
    %   See Also:
    %   sgolayfilt
    
    properties
        order
        width
        width_type
    end
    
    methods
        function obj = savitzky_golay(order,width,varargin)
            %
            %
            %   obj = sci.time_series.filter.savitzky_golay(order,width,varargin)
            %
            %   Inputs:
            %   -------
            %   order : integer
            %       Polynomial order to fit to the data. Must be odd.
            %
            %   Optional Inputs:
            %   ----------------
            %
            %   Examples:
            %   ---------
            %
            %   
            
            in.width_type = 'seconds'; %samples
            in = sl.in.processVarargin(in,varargin);
            
            %TODO: Check for odd order
            
            obj.order = order;
            obj.width = width;
            obj.width_type  = in.width_type;
            
            %sgolayfilt(X,K,F,W)
           %K - order, must be less than F 
           %    polynomial order to fit to the data (locally)
           %F - frame size, F, F must be odd
           %    I think this is in samples
        end
        function width = getWidthInSamples(obj,fs)
            if strcmp(obj.width_type,'samples')
                width = obj.width_value;
            else
                width = ceil(obj.width_value*fs);
            end
        end
        function data = filter(obj,data,fs)
            
            K = obj.order;
            F = obj.getWidthInSamples(fs);
            
            data = sgolayfilt(data,K,F);
            
            data = filter_method(B,A,data);
        end
    end
    
end

