function matrix_data = vectorToMatrixByCell(vector_data,xyz_cell)
%vectorToMatrixByCell
%
%   matrix_data = sl.xyz.vectorToMatrixByCell(vector_data,xyz_cell)
%
%   Takes vector data associated with a xyz matrix and transforms this data
%   into a matrix corresponding to the input xyz_cell locations originally
%   given. This function MUST BE PAIRED with the function:
%       sl.xyz.cellToMatrix
%
%
%
%   IMPROVEMENTS
%   =================================================
%   1) Build in support for 2d as well.
%   2) Provide example and explanation of code ...
%
%   See Also:
%   sl.xyz.cellToMatrix

sz = cellfun('length',xyz_cell);
matrix_data = permute(reshape(vector_data,sz(3:-1:1)),3:-1:1);



end