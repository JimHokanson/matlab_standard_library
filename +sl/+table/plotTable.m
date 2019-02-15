function h = plotTable(t,varargin)
%X plot table in a figure
%
%   h = sl.table.plotTable(t)
%
%
%   Example
%   -------
%   t = sl.table.getExampleTable();
%   h = sl.table.plotTable(patients);
%
%   Improvements
%   ------------
%   1) Plot into specified figure
%   2) Pass in a created uitable and only update contents
%   3) Allow horizontal alignment of fields - would require
%   a uitable wrapper that allows dissociation of data and display
%   where display is all strings ...
%   4) Number formatting - could have default and per variable 

%Alignment
%https://www.mathworks.com/matlabcentral/answers/244201-how-to-locate-the-data-in-the-middle-of-the-column-uitable#answer_193142

%{
    t = sl.table.getExampleTable();
    h = sl.table.plotTable(t)
%}

figure()

%https://www.mathworks.com/matlabcentral/answers/254690-how-can-i-display-a-matlab-table-in-a-figure
%t{:,:} doesn't work ...

c = cell(size(t));
for i = 1:size(t,2)
    temp = t{:,i};
    if iscell(temp)
        if size(temp,2) == 1
            %We might want to do this for logicals as well
            if isnumeric(temp{1})
                %Check for length
                temp = cellfun(@mat2str,temp,'un',0);
            end
            c(:,i) = temp;
        else
            %Assuming strings ...
            c(:,i) = sl.cellstr.rowsToStrings(temp,'delimiter','  ');
        end
    else
        c(:,i) = num2cell(temp);
    end
end

h = uitable('Data',c,'ColumnName',t.Properties.VariableNames,...
    'RowName',t.Properties.RowNames,'Units', 'Normalized', ...
    'Position',[0, 0, 1, 1]);


end