function [u,uI] = uniqueWithGroupIndices(A)
%uniqueWithGroupIndices Returns groupings for each unique element
%
%   [u,uI] = sl.cellstr.uniqueWithGroupIndices(A)
%
%   This function is a quicker way of getting the indices which 
%   match a particular unique value.
%
%   Inputs:
%   -------
%   A : vector
%       Must be:
%       1) sortable via sort()
%       2) able to compare neighbors via diff or strcmp
%
%   Outputs:
%   --------
%   u  : unique values
%   uI : (cell array)
%       Each entry holds the indices of A which match u.
%
%   Example:
%   --------
%   Out of date
%   [u,uI] = sl.array.uniqueWithGroupIndices([3 5 3 5 5])
%   u => [3 5]
%   uI{1} => [1 3];
%   uI{2} => [2 4 5];
%
%   NOTE: u(#) has the same value as all A(uI{#})


%Add error checking
%1) input must be number
%2) NaN handling

if isempty(A)
   u = [];
   uI = {};
   return
elseif length(A) == 1
   u = A;
   uI = {1};
   return
end

%JAH TODO: Document code
[Y,I2] = sort(A(:));


%could add case sensitivity
Itemp = find(~strcmp(Y(1:end-1),Y(2:end)));  


Istart = [1; Itemp+1];
Iend   = [Itemp; length(A)]; 

u = Y(Istart);

%Handling row vectors, note that matrices will come out
%as column vectors, just like for unique()
rows = size(A,1);
cols = size(A,2);
if (rows == 1) && (cols > 1)
   u  = u'; 
   I2 = I2';
end

%Population of uI
%-----------------------------
uI = cell(1,length(u));
for iUnique = 1:length(u)
   uI{iUnique} = I2(Istart(iUnique):Iend(iUnique));
end




