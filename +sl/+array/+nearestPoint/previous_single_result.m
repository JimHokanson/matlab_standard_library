classdef previous_single_result < handle
    %
    %   Class:
    %   sl.array.nearestPoint.previous_single_result
    
    properties (Hidden)
        raw_result
    end
    
    properties
       nx
       ny 
    end
    
    properties (Dependent)
        by_y
        by_x
        xy_pairs
    end
    
    %   Optional Inputs
%   ---------------
%   return:
%       - 'x' - an array the lenght of x, values are indices into y
%               0 indicates no match
%       - 'xy' - a [n x 2] array where each valid index of x is accompanied
%                with its appropriate y index
    
    methods
        function value = get.by_y(obj)
            value = obj.raw_result;
        end
        function value = get.by_x(obj)
            temp = obj.raw_result;
            value = zeros(1,obj.nx);
            for iY = 1:obj.ny
                if temp(iY)
                    value(temp(iY)) = iY;
                end
            end
        end
        function value = get.xy_pairs(obj)
            temp = obj.raw_result;
            value = zeros(obj.ny,2);
            iOut = 1;
            for iY = 1:obj.ny
                if temp(iY)
                    value(iOut,1) = iY;
                    value(iOut,2) = temp(iY);
                    iOut = iOut + 1;
                end
            end
            value(iOut:end,:) = [];
        end
    end
    
    methods
        function obj = previous_single_result(raw_result,nx,ny)
            %
            %   obj = sl.array.nearestPoint.previous_single_result(raw_result)
            obj.raw_result = raw_result;
            obj.nx = nx;
            obj.ny = ny;
        end
    end
    
end

