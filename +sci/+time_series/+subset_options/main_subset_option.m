classdef (Hidden) main_subset_option < handle
    %
    %   Class:
    %   sci.time_series.subset_options.main_subset_option
    
    properties
        d0 = '-----     Additonal Options    ------'
        n_parts
        
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
            %This can be called by objects after the samples have been
            %resolved to split the subset into smaller subsets ...
            if ~isempty(obj.n_parts) || ~isempty(obj.split_percentages)
                %1) Verify singular times ...
                split_eligible = all(cellfun('length',start_samples) == 1);
                if ~split_eligible
                   error('Objects are not split eligible, splitting requires only a single start/stop pair for each object')
                end
                
                obj.un = false;
                
                if ~isempty(obj.n_parts)
                    
                    %TODO: see sl.array.split
                    %make sl.array.getSplitIndices
                    
                    [start_samples,stop_samples] = ...
                            cellfun(@(x,y) sl.array.split.getSplitIndices(x,y,'n_parts',obj.n_parts),...
                                    start_samples,stop_samples,'un',0);     
                else
                    error('Not yet implemented')
                end
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

