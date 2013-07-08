classdef unique_rows < sl.obj.handle_light
    %
    %   Class:
    %   sl.array.unique_rows
    %
    %
    %   This class is meant to be able to provide more information about a
    %   unique set of rows than is tranditionally given from
    %   unique(,'rows'). It does this by holding onto intermediate values
    %   during the sorting process.
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Handle empty better
    %   2) Handle Inf and Nan better
    %   3) Alias 
    %   4) Implement test cases!
    %
    %   See Also:
    %   sl.array.tests.unique_rows

    properties
        %d0 = '---- Typical Unique Outputs ----'
        %unique           => s_unique
        %unique('stable') => o_unique
        %
        %IC - not exposed, however s_groups can be useful
        %It would be easy to expose this ...
        %=> 
        
        %NOTE: Many of these properties are lazily evaluated upon request
        
        n_unique         %# of unique values ...
        
        d1 = '---- Original Data ----'
        o_data           %Input to the class
        o_indices        %Indices of the original in the sorted data ...
        %o_data(#) = s_data(o_indices(#))
        %index - original
        %value - sorted index
        o_unique         %
        o_start_mask     %Indicates first instance of a unique element
                         %based on the original 'stable' order
        %o_end_mask      %NYI

        
        d2 = '---- Sorted Data ----'
        s_data           %Sorted data ...
        s_indices        %indices match sorted data, values are indices of
        %original data, i.e. s_data(#) = o_data(s_indices(#))
        %index - sorted
        %value - original index
        s_start_mask     %s_unique = s_data(s_start_mask) OR
        s_end_mask       %s_unique = s_data(s_end_mask) OR      logical
        s_start_I        %s_unique = s_data(s_start_I) OR       indices
        s_end_I          %s_unique = s_data(s_end_I)   
        s_unique         %The traditional output of unique
        
        d3 = '---- More useful Properties ----'
        o_first_group_I  %Index of first element that has the same value
        %as the current element
        %i.e. if we have for data:
        %[3 4 3 5 3 5] 
        %then this array will be:
        % 1 2 1 4 1 4
        %
        %   NOTE: this equals: ib(ic) from a stable sort
        %
        %   This property was originally implemented when I wanted to
        %   "learn" values for a given set of "points". Once I knew those
        %   values, all other points could point to that learned value
        %   More specifically, for a set of 3d points, I computed the
        %   stimulus that a cell would see from that 3d points, these
        %   stimuli were not unique. By learning the unique stimuli first,
        %   I could extend their solutions to other points that had
        %   redundant stimuli.
        
        s_group_indices  %(cell array), each cell array element contains
        %indices of a unique value
        %
        %   i.e. each element from o_data(s_group_indices{#}) == s_unique(#)
        %   
        %   This is useful for grabbing associated data by unique elements
    end
    
    methods
        function value = get.s_start_I(obj)
           value = obj.s_start_I;
           if isempty(value)
               value = find(obj.s_start_mask);
               obj.s_start_I = value;
           end
        end
        function value = get.s_end_I(obj)
           value = obj.s_end_I;
           if isempty(value)
               value = find(obj.s_end_mask);
               obj.s_end_I = value;
           end
        end
        function value = get.s_unique(obj)
            if isempty(obj.s_unique)
                obj.s_unique = obj.s_data(obj.s_start_mask,:);
            end
            value = obj.s_unique;
        end
        function value = get.o_start_mask(obj)
           value = obj.o_start_mask;
           if isempty(value)
                %This helps to understand if you look at the definition
                %of o_indices and s_start_mask 
              value = obj.s_start_mask(obj.o_indices); 
           end
        end
        function value = get.o_unique(obj)
            if isempty(obj.o_unique)
                obj.o_unique = obj.o_data(obj.o_start_mask,:);
            end
            value = obj.o_unique;
        end
        function value = get.o_indices(obj)
            value = obj.o_indices;
            if isempty(value)
                invSort             = obj.s_indices;
                invSort(invSort)    = 1:length(invSort);
                value               = invSort;
                obj.o_indices       = invSort;
            end
        end
        function value = get.s_group_indices(obj)
            value = obj.s_group_indices;
            if isempty(value)
                
                Istart = obj.s_start_I;
                Iend   = obj.s_end_I;
                Isort  = obj.s_indices;
                
                n_unique_local = obj.n_unique;
                
                value = cell(1,n_unique_local);
                
                for iUnique = 1:n_unique_local
                    value{iUnique} = Isort(Istart(iUnique):Iend(iUnique));
                end
                obj.s_group_indices = value;
            end
        end
        function value = get.o_first_group_I(obj)
           value = obj.o_first_group_I;
           if isempty(value)               
              %The idea with this method is that s_indices points
              %to the original indices that have a particular unique value
              %
              %The s_start_I and s_end_I also form a contiguous group
              %of indices into s_indices_local that all have this unique
              %value
              %
              %We thus assign all of these indices the first index, which,
              %due to the stable sort, will be the lowest index of all the
              %values.
              Isort  = obj.s_indices;
              Istart = obj.s_start_I;
              Iend   = obj.s_end_I;
              n_unique_local  = obj.n_unique;
              
              value = zeros(1,length(Isort)); 
              for iGroup = 1:n_unique_local
                 cur_start     = Istart(iGroup);
                 cur_end       = Iend(iGroup);
                 value(Isort(cur_start:cur_end)) = Isort(cur_start);
              end
              obj.o_first_group_I = value;
           end
        end
    end
    
    %Constructor ==========================================================
    methods
        function obj = unique_rows(data)
            obj.o_data = data;
            
            %TODO: Provide improved empty handling ...
            
            [s,obj.s_indices] = sortrows(data);
            
            neighbor_mask = s(1:end-1,:) ~= s(2:end,:);
            is_different  = any(neighbor_mask,2);
            
            obj.s_data       = s;
            obj.s_start_mask = [true; is_different];
            
            %NOTE: I just wanted to populate n_unique
            %Not sure if I should just do sum() here
            %or choose some other more common variable ...
            obj.s_start_I    = find(obj.s_start_mask);
            obj.n_unique     = length(obj.s_start_I);
            obj.s_end_mask   = [is_different; true];
        end
    end
end

