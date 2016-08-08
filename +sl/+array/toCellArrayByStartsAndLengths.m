function output = toCellArrayByStartsAndLengths(data,starts,lengths)
%
%
%   output = sl.array.toCellArrayByStartsAndLengths(data,starts,lengths)
%


n_cells = length(starts);
output  = cell(1,n_cells);

ends = starts + lengths - 1;

for iCell = 1:n_cells
   output{iCell} = data(starts(iCell):ends(iCell));
end



end