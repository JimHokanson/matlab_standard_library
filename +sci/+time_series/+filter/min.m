classdef min < handle
    
    properties
        width_type
        width_value
    end
    methods
        function obj = min(width,varargin)
            %
            %   obj = sci.time_series.filter.min(width,varargin)
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
            %   width_type : {'seconds','samples'}

            
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
        function min_data = filter(obj,data,fs)
            
            %TODO: Add on a check if not 1d
            
            win_size = obj.getWidthInSamples(fs);
            
            %Modified from example in:
            %http://www.mathworks.com/matlabcentral/fileexchange/24705-minmax-filter
            n_data  = length(data);
            min_data = zeros(size(data));
            m = min(data(1:win_size));
            for k = 1:length(data)-win_size
                min_data(k) = m;
                if data(k) > m
                    m = min(m, data(k+win_size));
                else
                    m = data(1+k);
                    for ii = k+2:k+win_size
                        if data(ii) < m
                            m = data(ii);
                        end
                    end
                end
            end
            for k = k+1:n_data-1
                min_data(k) = m;
                if data(k) < m
                    m = data(1+k);
                    for ii = k+2:n_data
                        if data(ii) < m
                            m = data(ii);
                        end
                    end
                end
            end
            min_data(end) = m;
        end
    end
    
    
end


