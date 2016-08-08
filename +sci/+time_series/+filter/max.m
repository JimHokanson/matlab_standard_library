classdef max < handle
    %
    %   Class:
    %   sci.time_series.filter.max
    
    properties
        width_type
        width_value
    end
    methods
        function obj = max(width,varargin)
            %
            %   obj = sci.time_series.filter.max(width,varargin)
            %
            %   Inputs:
            %   -------
            %   width : number
            %       This value is either in samples or seconds, depending
            %       upon the 'width_type' parameter.
            %
            %
            %   Optional Inputs:
            %   ----------------
            %   type : {'tri','rect'}
            %       The shape to use for smoothing ...
            %       tri - triangular window
            %       rect - rectangular window
            %   width_type : {'seconds','samples'}
            %   zero_phase : logical (default true)
            %       If true the data are filtered forwards and backwards
            %       using filtfilt() instead of filter()
            
            in.width_type = 'seconds';
            in = sl.in.processVarargin(in,varargin);
            
            obj.width_type  = in.width_type;
            obj.width_value = width;
        end
        function width = getWidthInSamples(obj,fs)
            if strcmp(obj.width_type,'samples')
                width = obj.width_value;
            else
                width = ceil(obj.width_value*fs);
            end
        end
        function max_data = filter(obj,data,fs)
            
            win_size = obj.getWidthInSamples(fs);
            
            %TODO: Add on check that this is 1d
            
            %Modified from example in:
            %http://www.mathworks.com/matlabcentral/fileexchange/24705-minmax-filter
            n_data  = length(data);
            max_data = zeros(size(data));
            m = max(data(1:win_size));
            for k = 1:length(data)-win_size
                max_data(k) = m;
                if data(k) < m
                    m = max(m, data(k+win_size));
                else
                    m = data(1+k);
                    for ii = k+2:k+win_size
                        if data(ii)>m
                            m = data(ii);
                        end
                    end
                end
            end
            for k = k+1:n_data-1
                max_data(k) = m;
                if data(k) > m
                    m = data(1+k);
                    for ii = k+2:n_data
                        if data(ii)>m
                            m = data(ii);
                        end
                    end
                end
            end
            max_data(end) = m;
        end
    end
    
    
end


