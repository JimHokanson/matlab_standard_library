function [u,uI] = uniqueWithGroupIndices(A,varargin)
%uniqueWithGroupIndices Returns groupings for each unique element
%
%   [u,uI] = sl.array.uniqueWithGroupIndices(A)
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
%   [u,uI] = sl.array.uniqueWithGroupIndices([3 5 3 5 5])
%   u => [3 5]
%   uI{1} => [1 3];
%   uI{2} => [2 4 5];
%
%   NOTE: u(#) has the same value as all A(uI{#})



%   SPEED NOTE
%   ==========================================
%   r = randi(100,1,100000);
%
%     METHOD 1 - takes time T
%     [u,uI] = unique2(r);
% 
%     METHOD 2 - takes time 3T
%     [u2,~,J] = unique_2011b(r);
%     uI2 = cell(1,length(u2));
%     for iChan = 1:length(u2)
%         uI2{iChan} = strfind(J,u2(iChan));
%     end
% 
%     METHOD 3 - takes time 5T
%     [u3,~,J] = unique_2011b(r);
%     uI3 = cell(1,length(u3));
%     for iChan = 1:length(u3)
%         uI3{iChan} = find(J == u3(iChan));
%     end

%Add error checking
%1) input must be number
%2) NaN handling

in.rows = false;
in = sl.in.processVarargin(in,varargin);

if isempty(A)
   u = [];
   uI = {};
   return
elseif (in.rows && size(A,1) == 1) || length(A) == 1
   u = A;
   uI = {1};
   return
end

%JAH TODO: Document code
if in.rows
    [Y,I2] = sortrows(A);
else
    [Y,I2] = sort(A(:));
end



if in.rows
	neighbor_mask = Y(1:end-1,:) ~= Y(2:end,:);
 	Itemp         = find(any(neighbor_mask,2));
elseif isnumeric(Y)
    if isnan(Y)
        error('NaN handling not yet supported')
    end
    Itemp = find(diff(Y) ~= 0);
else
    %could add case sensitivity
    Itemp = find(~strcmp(Y(1:end-1),Y(2:end)));  
end

Istart = [1; Itemp+1];
Iend   = [Itemp; length(A)]; 

if in.rows
u = Y(Istart,:);    
else
u = Y(Istart);
end

if ~in.rows
    %Handling row vectors, note that matrices will come out
    %as column vectors, just like for unique()
    rows = size(A,1);
    cols = size(A,2);
    if (rows == 1) && (cols > 1)
       u  = u'; 
       I2 = I2';
    end
end

%Population of uI
%-----------------------------
uI = cell(1,length(u));
for iUnique = 1:length(u)
   uI{iUnique} = I2(Istart(iUnique):Iend(iUnique));
end




