classdef new_to_old
    %
    %   Class:
    %   sl.indices.new_to_old
    %
    %   This is a simple class for going back to old indices after
    %   indexing
    %
    %   
    %       WARNING WARNING WARNING WARNING WARNING
    %
    %       When I have time I going to rewrite all of this ...
    %
    %       WARNING WARNING WARNING WARNING WARNING
    %
    %
    %
    %   IMPROVEMENTS:
    %   -------------------------------------------------------------------
    %   I think this class can be replaced by a single function ...
    %   with an input that specifies whether or not we want
    %   indices or a mask ...
    %   
    %   NOTE: The mask will require an original size specification 
    %   in some cases ...
    %
    %   Currently used by:
    %   NEURON.xstim.single_AP_sim.grouper.initialize
    
    properties
    end
    
    methods (Static)
        %Not all types are implemented ...
        
        function old_indices = getOldIndices__oldKeepMask__newIndices(old_keep_mask,new_indices)
            %
            %   old_indices = getOldIndices__oldKeepMask__newIndices(old_keep_mask,new_indices)
            %
            %   IMPROVEMENTS:
            %   1) not thrilled by the name
            %   2) do I need to specify input types or will that resolve
            %   itself ????
            %   - old indices, new mask   - requires a size specification
            %   for a mask output ...
            %
            %   - old indices, new indices
            %   - old mask, new mask
            %   - old_mask, new indices
            %   
            
           temp        = find(old_keep_mask);
           old_indices = temp(new_indices);
        end
    end
    
end

