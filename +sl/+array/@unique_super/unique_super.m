classdef (Hidden) unique_super < sl.obj.handle_light
    %
    %   Class:
    %   sl.array.unique_super
    %
    %   Status:
    %   I'm still working on the properties that this class will contain.
    %   I also need some more error checking ...
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Handle empty better
    %   2) Handle Inf and Nan better
    %   3) Implement test cases!
    %   4) Floating point unique ...
    %
    %   See Also:
    %   sl.array.unique
    %   sl.array.unique_rows
    %   sl.cellstr.unique
    
    
    properties (Constant,Hidden,Abstract)
        SORT_FUNCTION_HANDLE %Must return sorted and indexes
        IS_DIFFERENT_HANDLE  %Must return a mask, with n-1 elements
        IS_2D
    end
    
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
        o_unique         %This is what is known as the stable sort in the
        %typical unique function ...
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
        
        
        o_IA_first
%         o_IA_last  = 
%         s_IA_first = find(obj.s_indices(obj.s_start_mask))
%         s_IA_last  = find(obj.s_indices(obj.s_end_mask));
        
        o_IC_first %reference into the stable solution
        s_IC_first
        
        
        
        
        %s_unique_stable_index = 
        
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
        

        o_unique_counts
        s_unique_counts  %
        
        o_group_indices  %(cell array), this provides group indices but
        %the order is based on a stable sort. The indices still refer to
        %the original data. 
        %
        s_group_indices  %(cell array), each cell array element contains
        %indices of a unique value. Indices are to the original data.
        %
        %   i.e. each element from o_data(s_group_indices{#}) == s_unique(#)
        %
        %   This is useful for grabbing associated data by unique elements
    
        %This would be the same as s_group_indices but organized by the
        %first occurence of each entry, not by the sorted occurence of each
        %unique entry
        %o_group_indices
    
    end
    
    properties (Hidden)
       index_of_first_unique_stable_in_sorted
    end
    
    methods
        function value = get.index_of_first_unique_stable_in_sorted(obj)
           value = obj.index_of_first_unique_stable_in_sorted;
           if isempty(value)
                             %There are at least two ways of doing this
              %
              %  use sort or do a find (requires more memory)
              %
              %And an additional question of whether or not you 
              %access s_group_indices or not

              I_orig = obj.s_indices(obj.s_start_I);
              [~,value] = sort(I_orig);
              obj.index_of_first_unique_stable_in_sorted = value;
              %An alternative approach would involve creating
              %an empty vector the same length as the max
              %of the indices, then assigning 1:n to each of these indices
              %and then getting these non-zero elements in order
              %i.e. let's say we had the indices 5 2 7
              %
              %  we could easily create a vector 0 2 0 0 1 0 3
              %
              %  we then grab the non-zero elements
              %
              %  what about a sparse matrix?
              %  the sparse matrix would need to do a sort 
              %
              %  The sort might be more efficient for sparse, 
              %  sparse is slower 
              
%                 tic
%                 for i = 1:1000  
%                 temp = zeros(1,max(I_orig));
%                 temp(I_orig) = 1:length(I_orig);
%                 I2 = nonzeros(temp);
%                 end
%                 toc
              
              
%               tic
%               for i = 1:1000
%               I2 = nonzeros(sparse(1,I_orig,1:length(I_orig)));
%               end
%               toc
           end
        end
        function value = get.o_unique_counts(obj)
           value = obj.o_unique_counts; 
           if isempty(value)
              value = obj.s_unique_counts(obj.index_of_first_unique_stable_in_sorted);
              obj.o_unique_counts = value;
           end
        end
        function value = get.s_unique_counts(obj)
           value = obj.s_unique_counts;
           if isempty(value)
              value = obj.s_end_I - obj.s_start_I + 1;
              obj.s_unique_counts = value;
           end
        end
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
                if obj.IS_2D
                    obj.s_unique = obj.s_data(obj.s_start_mask,:);
                else
                    obj.s_unique = obj.s_data(obj.s_start_mask);
                end
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
                if obj.IS_2D
                    obj.o_unique = obj.o_data(obj.o_start_mask,:);
                else
                    obj.o_unique = obj.o_data(obj.o_start_mask);
                end
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
        function value = get.o_IA_first(obj)
           value = obj.o_IA_first;
           if isempty(value)
              value = find(obj.o_start_mask);
              obj.o_IA_first = value;
           end
        end
        function value = get.s_IC_first(obj)
           value = obj.s_IC_first;
           if isempty(value)
              value = cumsum(obj.s_start_mask);
              value(obj.s_indices) = value;
              obj.s_IC_first = value;
           end
        end
        function value = get.o_IC_first(obj)
           value = obj.o_IC_first;
           if isempty(value)
              value = zeros(size(obj.o_start_mask));
              value(obj.o_start_mask) = 1:obj.n_unique;
              value = value(obj.o_first_group_I);
              obj.o_IC_first = value;
           end
        end
        function value = get.o_group_indices(obj)
           value = obj.o_group_indices;
           if isempty(value)
              value = obj.s_group_indices(obj.index_of_first_unique_stable_in_sorted);
              obj.o_group_indices = value;

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
                                
                %TODO: This should be a method ...
                Isort  = obj.s_indices;
                Istart = obj.s_start_I;
                Iend   = obj.s_end_I;
                n_unique_local = obj.n_unique;
                
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
        function obj = unique_super(data)
            %
            %   For subclasses:
            %   obj@sl.array.unique_super(data);
            
            obj.o_data = data;
            
            %TODO: Provide improved empty handling ...
            
            [s,obj.s_indices] = obj.SORT_FUNCTION_HANDLE(data);
            
            is_different      = obj.IS_DIFFERENT_HANDLE(s);
            
            obj.s_data       = s;
            
            if isrow(is_different)
                obj.s_start_mask = [true is_different];
                obj.s_end_mask   = [is_different true];
            else
                obj.s_start_mask = [true; is_different];
                obj.s_end_mask   = [is_different; true];
            end
            
            %NOTE: I just wanted to populate n_unique
            %Not sure if I should just do sum() here
            %or choose some other more common variable ...
            obj.s_start_I    = find(obj.s_start_mask);
            obj.n_unique     = length(obj.s_start_I);
            
        end
    end    
end

