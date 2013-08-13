function varargout = getStructureField(cell_input,field)
%
%
%   varargout = sl.cell.getStructureField(cell_input,field)

n_cells = length(cell_input);
for iCell = 1:n_cells
   varargout{iCell} = cell_input{iCell}.(field); 
end
