classdef time_functions
    %
    %   Class:
    %   sci.time_series.time_functions
    
    %TODO: We're going to 
    
    %{
              getDataAlignedToEvent . :Aligns subsets of the data to a time
    %
    %
   removeTimeGapsBetweenObjects . :Removes any time gaps between objects (for plotting)
                       resample . :Change the sampling frequency of the data
                zeroTimeByEvent . :Redefines time such that the time of event is now at time zero.
    
    %}
    
    properties
        data_objects
    end
    
    methods
        function obj = time_functions(data_objects)
            obj.data_objects = data_objects;
        end
        function removeOffset(obj)
           %TODO 
        end
        function zeroTimeByEvent(obj)
            
        end
        function resample(obj)
            
        end
    end
    
end

