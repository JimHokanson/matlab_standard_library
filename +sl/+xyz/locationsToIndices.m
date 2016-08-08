function IJK_final = locationsToIndices(locations,xyz_cell_or_matrix,varargin)
%
%
%   sl.xyz.locationsToIndices(locations,xyz_cell_or_matrix,varargin)
%
%
%   This function needs a lot of work but it works for a cell input
%   
%   locations [n x 3] - no reason we couldn't make it work for 2d as well

%TODO: Check correct 

in.linearize_index = false;
in = sl.in.processVarargin(in,varargin);

if iscell(xyz_cell_or_matrix)
   xyz_cell = xyz_cell_or_matrix;
   IJK_final = zeros(size(locations));
   for iDim = 1:3
      [~,I] = min(abs(bsxfun(@minus,xyz_cell{iDim}(:),locations(:,iDim)')));
      IJK_final(:,iDim) = I;
   end
else
   error('Not yet implemented') 
end
