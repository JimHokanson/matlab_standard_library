classdef calculators
    %
    %   Class:
    %   sci.time_series.calculators
    %
    %   This class holds calculators as properties
    
    properties
        frequency  %??? - merge with spectrogram????
        spectrogram
        eventz
        regression %For Greg!!!!! sci.time_series.calculators.regression
    end
    
    methods
        function obj = calculators()
            % obj = sci.time_series.calculators
            obj.regression = sci.time_series.calculators.regression;
        end
    end
end

