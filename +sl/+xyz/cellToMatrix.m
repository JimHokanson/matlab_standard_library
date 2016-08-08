function xyz_matrix = cellToMatrix(xyz_cell)
%cellToMatrix
%
%   xyz_matrix = sl.xyz.cellToMatrix(xyz_cell)
%
%   See Also:
%   sl.xyz.vectorToMatrixByCell
%
%   IMPROVEMENTS
%   =================================================
%   1) Build in support for 2d as well.
%   2) Provide example and explanation of code ...

%TODO: Add type check ... - cell, 3 vectors

%This little weird but gives us a sorted output ...
[Z,Y,X] = ndgrid(xyz_cell{3:-1:1});
xyz_matrix = [X(:) Y(:) Z(:)];

end