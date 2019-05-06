classdef scalar < double
    %
    %   Class:
    %   sl.numbers.scalar
    %
    %   Created to play around with saving scalar values as such, and
    %   not as an array with 1 element (e.g. for JSON)
    %
    %   The goal was to see if I could cast a double to a scalar to give
    %   Matlab the notion that this wasn't a single element array but
    %   rather a scalar. It is a work in progress.
    
    
    %{
    
    %}
    
   methods
      function obj = scalar(scalar_value)
         if length(scalar_value) ~= 1
            error('Input data must be a scalar')
         end
         obj = obj@double(scalar_value);
      end
   end
    
end

