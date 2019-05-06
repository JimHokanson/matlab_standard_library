function str = getDisplayString(s) %#ok<INUSD>
%x Get string that goes to cmd window when a structure is displayed
%
%   str = sl.struct.getDisplayString(s)
%
%   This was written when you want to take the display of a string
%   and put it into a variable, such as for a GUI text. All it does
%   is capture the command window output.
%
%   Improvements
%   ------------
%   1) Allow removing all padding on LHS since by default we get a few
%   spaces ...
%
%   Example
%   -------
%   t = sl.table.getExampleTable();
%   %Put first row into a structure
%   s = table2struct(t(1,:));
%   str = sl.struct.getDisplayString(s);
%   disp(str)
%     str =
% 
%         '     LastName: 'Smith'
%                 Gender: 'Male'
%                    Age: 38
%                 Height: 71
%                 Weight: 176
%                 Smoker: 1
%               Systolic: 124
%              Diastolic: 93
% 
%          '

str = evalc('disp(s)');

end