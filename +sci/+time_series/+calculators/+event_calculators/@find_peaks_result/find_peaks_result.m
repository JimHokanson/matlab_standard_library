classdef find_peaks_result <handle
    %   
    %   Class:
    %   sci.time_series.calculators.event_calculators.find_peaks_result
    %
    %   JAH: This method is outdated and shouldn't be used
    %
    %   stores the result of
    %   sci.time_series.calculators.event_calculators.findPeaks
    %   
    %   TODO: for finding both min and max, allow the use of different
    %   threshold values
    
    properties
        data %sci.timeseries.data
        d %raw data (double)
        
        % can be 1 element array or 2 element cell array
        % (depends on the input 'type'. if type == 3, then the first
        % element applies to the maxima, and the second element applies to
        % the minima
        pks
        locs
        time_locs
    end
    methods
        function obj = find_peaks_result(data,type, varargin)
            obj.data = data;
            obj.d = data.d;
            
            switch type
                case 1 %just maxima
                    [obj.pks, obj.locs] = findpeaks(obj.d,varargin{:});
                    obj.time_locs = obj.data.ftime.getTimesFromIndices(obj.locs); 
                case 2 %just minima
                    temp = -obj.d;
                    [obj.pks, obj.locs] = findpeaks(temp,varargin{:});
                    obj.pks = -obj.pks;%need to flip it back
                    obj.time_locs = obj.data.ftime.getTimesFromIndices(obj.locs); 
                case 3
                    obj.pks = cell(1,2);
                    obj.locs = cell(1,2);
                    obj.time_locs = cell(1,2);
                    
                    [obj.pks{1,1}, obj.locs{1,1}] = findpeaks(obj.d,varargin{:});
                    obj.time_locs{1,1} = obj.data.ftime.getTimesFromIndices(obj.locs{1}); 
                    
                    temp = -obj.d;
                    [obj.pks{1,2}, obj.locs{1,2}] = findpeaks(temp, varargin{:});
                    obj.pks{1,2} = -obj.pks{1,2};
                    obj.time_locs{1,2} = obj.data.ftime.getTimesFromIndices(obj.locs{2}); 
                otherwise
                error('unrecognized peak finding type');
            end
        end
    end
end
