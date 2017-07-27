classdef previous_single_result < handle
    %
    %   Class:
    %   sl.array.nearestPoint.previous_single_result
    
    properties
        raw
    end
    
    properties
        nx
        ny
    end
    
    properties (Dependent)
        xy_pairs
    end
    
    methods
        function value = get.xy_pairs(obj)
            temp = obj.raw;
            value = zeros(2,obj.nx);
            iOut = 1;
            for i = 1:obj.nx
                if temp(i)
                    value(1,iOut) = i;
                    value(2,iOut) = temp(i);
                    iOut = iOut + 1;
                end
            end
            value(:,iOut:end) = [];
        end
    end
    
    methods
        function obj = previous_single_result(raw_result,nx,ny)
            %
            %   obj = sl.array.nearestPoint.previous_single_result(raw_result)
            obj.raw = raw_result;
            obj.nx = nx;
            obj.ny = ny;
        end
    end
    
end

