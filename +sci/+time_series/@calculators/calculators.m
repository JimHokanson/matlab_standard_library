classdef calculators
    %
    %   Class:
    %   sci.time_series.calculators
    %
    %   This class holds calculators as properties
    
    properties
        frequency
        spectrogram
        eventz
        regression %sci.time_series.calculators.regression
    end
    
    methods
        function obj = calculators()
            %
            % obj = sci.time_series.calculators
            obj.frequency = sci.time_series.calculators.spectrum_calculators;
            obj.regression = sci.time_series.calculators.regression;
            obj.eventz = sci.time_series.calculators.event_calculators;
            obj.spectrogram = sci.time_series.calculators.spectrogram_calculators;
        end
    end
end

