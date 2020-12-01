function t = renameColumns(t,pairs)
%
%   sl.table.renameColumns(t,pairs)
%
%   Inputs
%   ------
%   t : table
%   pairs : cellstr
%       array of old names followed by new names
%       'old_name1','new_name1','old_name2','new_name2'
%   
%   Example
%   -------
%   s.old1 = (1:3)';
%   s.old2 = (4:6)';
%   t = struct2table(s);
%   %Note, 'old3' is missing but that's fine, no error is thrown
%   t2 = sl.table.renameColumns(t,{'old1','new1','old3','new3'});
%   disp(t)
%   disp(t2)
%
%   Improvements
%   ------------
%   1. We could support errors if old name is missing

fh = @strcmp;

names = t.Properties.VariableNames;
for i = 1:2:length(pairs)
    old_name = pairs{i};
    new_name = pairs(i+1);
    I = fh(old_name,names);
    if ~isempty(I)
        names(I) = new_name;
    end
end

t.Properties.VariableNames = names;