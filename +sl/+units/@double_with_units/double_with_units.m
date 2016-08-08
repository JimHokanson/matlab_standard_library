classdef double_with_units
    %
    %   Class:
    %   sl.units.double_with_units
    
    
    %{
    
    temp = sl.units.double_with_units(1:10,'mm/s^2');
    disp(temp);
    
    s.a = temp;
    s
    s.a = 1:10
    s
    %}  
    
    %properties
    %   units
    %   temp_display_string
    %end
    
    properties (Hidden)
       data
       units
    end
    
    methods
        function obj = double_with_units(input_value,units_string)
           obj.data = input_value; 
           obj.display_string = units_string;
        end
    end
    
end

%{
%http://www.mathworks.com/help/matlab/matlab_oop/implementing-a-custom-display.html

%The struct is what to display 
EmployeeInfo < handle & matlab.mixin.CustomDisplay

methods (Access = protected)
   function propgrp = getPropertyGroups(obj)
      if ~isscalar(obj)
         propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
      else
         pd(1:length(obj.Password)) = '*';
         propList = struct('Department',obj.Department,...
            'JobTitle',obj.JobTitle,...
            'Name',obj.Name,...
            'Salary','Not available',...
            'Password',pd);
         propgrp = matlab.mixin.util.PropertyGroup(propList);
      end
   end
end


Built-In Subclasses That Define Properties
When a subclass of a built-in class defines properties, MATLAB no longer supports indexing and concatenation operations. MATLAB cannot use the built-in functions normally called for these operations because subclass properties can contain any data.

The subclass must define what indexing and concatenation mean for a class with properties. If your subclass needs indexing and concatenation functionality, then the subclass must implement the appropriate methods.

Methods for Indexing

To support indexing operations, the subclass must implement these methods:

subsasgn ? Implement dot notation and indexed assignments
subsref ? Implement dot notation and indexed references
subsindex ? Implement object as index value
Methods for Concatenation

To support concatenation, the subclass must implement the following methods:

horzcat ? Implement horizontal concatenation of objects
vertcat ? Implement vertical concatenation of objects
cat ? Implement concatenation of object arrays along specified dimension



%}

