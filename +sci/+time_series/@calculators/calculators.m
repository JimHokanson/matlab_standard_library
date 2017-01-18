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
        function obj=calculators()
            %TODO: Constructor, instiate the calculators
            %do only regression for now ...
            
            regression= sci.time_series.calculators.regression()
        end
    end
end

