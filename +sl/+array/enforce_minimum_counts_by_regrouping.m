classdef enforce_minimum_counts_by_regrouping < sl.obj.handle_light
    %
    %   Class:
    %   sl.array.enforce_minimum_counts_by_regrouping
    %
    %   wtf = sl.array.enforce_minimum_counts_by_regrouping(5:15,20)
    %
    %   EXAMPLE: Consider we have group sizes of:
    %   5,6,7,...,15 and we want each group to have a minimum of 20
    %
    %   This class would regroup so that each group now has at least 20
    %
    %   Currently only 1 method of doing this is implemented, shifting left
    %
    %   i.e. 5,6,7,8 go together, forming 26
    %   then 9,10,11 go together, forming 30, etc
    %
    %   other algorithms for regrouping could eventually be implemented ...
    %   
    %   See Also:
    %   
    
    properties
        d0 = '----  Options ----'
        method = 'strategy' %Other options not yet implemented ...
    end
    
    %Inputs ===============================================================
    properties
        d1 = '----  Inputs  ------'
        counts_in %[1 x n]
        min_size
    end
    
    properties
        d2 = '-----  Outputs  -----'
        counts_out
    end
    
    methods
        function obj = enforce_minimum_counts_by_regrouping(counts_in,min_size)
            
            assert(isvector(counts_in),'Counts input must be a vector');
            if size(counts_in,1) > 1
                counts_in = counts_in';
            end
            
            obj.counts_in = counts_in;
            obj.min_size  = min_size;
            obj.run();
        end
        function run(obj)
            %
            %   This method shifts things to the left
            %   to get a minimum group size ...
            %
            counts_in_local = obj.counts_in;
            min_size_local  = obj.min_size;
            
            %total_counts = sum(counts_in_local);
            
            %TODO: Short circuit on total_counts < min_size_local
            
            cur_run_size = 0;
            
            n_counts_in = length(counts_in_local);
            
            end_of_group_mask = false(1,n_counts_in);
            last_end_index = 0;
            for iCount = 1:length(counts_in_local)
                cur_run_size = cur_run_size +  counts_in_local(iCount);
                if cur_run_size >= min_size_local
                    end_of_group_mask(iCount) = true;
                    last_end_index = iCount;
                    cur_run_size = 0;
                end
            end
            
            if ~end_of_group_mask(end)
                %The last group is too small, incorporate into previous group
                end_of_group_mask(last_end_index) = false;
                end_of_group_mask(end) = true;
            end
            
            %Get start mask ...
            %start_mask = [true end_of_group_mask(1:end-1)];
            
            cum_sum_counts = cumsum(counts_in_local);
            end_counts = cum_sum_counts(end_of_group_mask);
            obj.counts_out = end_counts - [0 end_counts(1:end-1)];
            
        end
    end
end

