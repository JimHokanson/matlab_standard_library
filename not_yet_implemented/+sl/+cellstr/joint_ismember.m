classdef joint_ismember < handle
    %
    %   class:
    %   sl.cellstr.jointIsmember
    %
    %   TODO: This should inherit from some class that actually does the
    %   work
    %
    %   What do we want to know:
    %   - in1_not2
    %   - in2_not1
    %   - one_in_two_mask
    %   - one_in_two_loc
    %   - two_in_one_mask
    %   - two_in_one_loc
    
    properties
    end
    
    methods
        function obj = joint_ismember(group1,group2)
            
            %Make sure both are row vectors
            if ~isvector(group1) || ~isvector(group2)
                error('Both inputs must be vectors')
            end
            
            %TODO: Finish implementation
            
            
        end
        
        
    end
    
end
