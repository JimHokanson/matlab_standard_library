classdef scalar < double
    %
    %   Class:
    %   sl.numbers.scalar
    %
    %   Created to play around with saving scalar values as such, and
    %   not as an array with 1 element (e.g. for JSON)
    
   methods
      function obj = scalar(scalar_value)
         if length(scalar_value) ~= 1
            error('Input data must be a scalar')
         end
         obj = obj@double(scalar_value);
      end
   end
    
end

