classdef calculators
    %
    %   Class:
    %   sci.time_series.calculators
    %
    %   This class holds calculators as properties
    %
    %   Example
    %   -------
    %   c = data.calaculators;
    %   result = c.eventz.findLocalPeaks(data,'min')
    
    properties
        frequency   %sci.time_series.calculators.spectrum_calculators
        spectrogram %sci.time_series.calculators.spectrogram_calculators
        eventz      %sci.time_series.calculators.event_calculators
        regression  %sci.time_series.calculators.regression
        derivatives %sci.time_series.calculators.derivatives
    end
    
    methods
        function obj = calculators()
            %
            % obj = sci.time_series.calculators
            obj.frequency = sci.time_series.calculators.spectrum_calculators;
            obj.regression = sci.time_series.calculators.regression;
            obj.eventz = sci.time_series.calculators.event_calculators;
            obj.spectrogram = sci.time_series.calculators.spectrogram_calculators;
            obj.derivatives = sci.time_series.calculators.derivatives;
        end
    end
end

