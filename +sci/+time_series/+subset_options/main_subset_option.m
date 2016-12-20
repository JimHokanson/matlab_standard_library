classdef (Hidden) main_subset_option < handle
    %
    %   Class:
    %   sci.time_series.subset_options.main_subset_option
    
    properties
        d0 = '-----     Additonal Options    ------'
        n_splits
        %NYI
        split_percentages
        un
        align_time_to_start
        d1 = '------  Specific Object Options -------'
    end
    
    methods (Abstract)
        [starts,stops,other_options] = getStartAndStopSamples(obj,data_objects)
    end
    methods
        function [start_samples,stop_samples] = processSplits(obj,start_samples,stop_samples)
            if ~isempty(obj.n_splits) || ~isempty(obj.split_percentages)
                %1) Verify singular times ...
                split_eligible = all(cellfun('length',start_samples) == 1);
                if ~isempty(obj.n_splits)
                    
                    %TODO: see sl.array.split
                    %make sl.array.getSplitIndices
                    
                    n_objects = length(start_samples);
                    start_new = cell(1,n_objects);
                    stop_new = cell(1,n_objects);
                    for iObject = 1:length(n_objects)
                        
                    end
                    
                end
                keyboard
            end
        end
        function options = getOtherOptions(obj)
            options = {};
            if ~isempty(obj.un)
                options = [options {'un',obj.un}];
            end
            if ~isempty(obj.align_time_to_start)
                options = [options {'align_time_to_start',obj.align_time_to_start}];
            end
        end
    end
    
    methods (Static)
        function samples = timesToSamples(objs,times)
            n_objs = length(objs);
            samples = cell(1,n_objs);
            for iObj = 1:n_objs
                cur_obj = objs(iObj);
                cur_times = times{iObj};
                %TODO: Introduce a bounds error check in getNearestIndices
                samples{iObj} = cur_obj.time.getNearestIndices(cur_times);
            end
        end
    end
    
end

