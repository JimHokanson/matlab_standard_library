classdef derivatives < sl.obj.display_class
    %
    %   Class:
    %   sci.time_series.calculators.derivatives
    
    properties
        
    end
    
    methods (Static)
        function result = first_derivative(data,varargin)
            %
            %   new_data = obj.first_derivative(data,varargin)
            %
            %   sci.time_series.calculators.derivatives.first_derivative
            %
            %   Calculates the derivative of a point based on points
            %   that are 1/2 the specified width on either side of the
            %   point, i.e.:
            %
            %   value = x(I + half_width) - X(I-half_width);
            %
            %   The resulting value is scaled appropriately for both the
            %   width over which it is caculated as well as the sampling
            %   rate.
            %
            %   Optional Inputs
            %   ---------------
            %   null_value : default NaN
            %       Edge samples get this value. The # of samples which
            %       receive this value is depenendent on the width of the
            %       differentiation.
            %   sample_width : (default 2)
            %       # of samples over which to calculate the derivative.
            %       The default behavior calculates the derivative at
            %       a point based on the neighboring points.
            %   time_width : (default, not used)
            %       Time over which to calculate the derivative, centered
            %       on the sample itself. For example a 1 second width
            %       calculates the derivate at a point based on samples
            %       that are 0.5 seconds on either side
            %   filt_freq : default []
            %       Cutoff frequency for lowpass Butterworth filter. If no
            %       frequency is specified no filtering occurs.
            %   filt_order : (default 2)
            %       Uses filt-filt so the order is actually 2x this value.
            %
            %   Examples
            %   --------
            %   c = sci.time_series.calculators
            % 	new_data = c.derivatives.first_derivative(obj.raw_data,...
            %                               'time_width',1,'filt_freq',0.5);
            
            %scale
            %   - slope
            %   - sample
            in.scale = 'slope';
            in.null_value = NaN;
            in.sample_width = [];
            in.time_width = [];
            in.filt_freq = [];
            in.filt_order = 2;
            in = sl.in.processVarargin(in,varargin);
            
            result = sci.time_series.calculators.derivatives.first_derivative_result();
            
            %Determine half_sample_width amount
            %-----------------------------------------------
            if isempty(in.sample_width) && isempty(in.time_width)
                half_sample_width = 1;
            elseif isempty(in.time_width)
                half_sample_width = ceil(0.5*in.sample_width);
            else
                half_sample_width = data.ftime.durationToNSamples(0.5*in.time_width,'method',@round);
            end
            
            if half_sample_width < 1
                error('Specified width results in a half width less than 1 sample')
            end
            
            
            %Filtering if necessary and data retrieval
            %--------------------------------------------
            if isempty(in.filt_freq)
                d = data.d;
            else
                butter = sci.time_series.filter.butter(in.filt_order,in.filt_freq,'low');
                filt_data = data.filter(butter);
                d = filt_data.d;
                result.filtered_original_data = filt_data;
            end
            
            d2 = d;
            
            new_data = copy(data);
            
            
            if data.n_channels > 1
                error('Not yet implemented for more than 1 channel')
            end
            
            %Computing the result
            %-------------------------------------------------
            start_I = 1+half_sample_width;
            end_I = data.n_samples - half_sample_width;
            
            %TODO: Ideally this would be done without temporarily variables
            %but I don't know if it is ...
            switch in.scale
                case 'slope'  
                    scale = data.time.fs/(2*half_sample_width);
                case 'sample'
                    scale = 1;
            end
            d2(start_I:end_I,1) = scale*(...
                d(start_I+half_sample_width:end) - ...
                d(1:end_I-half_sample_width));
            
            d2(1:start_I-1,1) = in.null_value;
            d2(end_I+1:end,1) = in.null_value;
            
            new_data.d = d2;
            
            new_data.units = [new_data.units '/s'];
            new_data.addHistoryElements('Calculated first derivative using calculators.derivatives.first_derivative');
            
            result.result_data = new_data;
            result.orig_data = data;
        end
    end
end

