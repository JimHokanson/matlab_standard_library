function [unique_rows,I,J] = uniqueRows(input_cell_array,varargin)
%uniqueRows  Unique rows for a cell array
%
%   [unique_rows,I,J] = sl.cell.uniqueRows(input_cell_array,varargin)
%
%   Outputs:
%   --------
%   unique_rows :
%       Values of all unique rows.
%   I : array, length == size(unique_rows,1)
%       Parallels the 'I' output from unique in that:
%               unique_rows = input_cell_array(I,:) 
%       In other words this helps us bring other variables
%       into the unique space, i.e. only keeping one example
%       of some other array where our input is unique
%
%           i.e. in_array1 = {'a'; 'b'; 'a'; 'b'} 
%                in_array2 = [1 2 3 4]
%
%       [unique_rows,I,J] = sl.cell.uniqueRows(in_array1)
%
%       If we get "examples" from in_array2 from unique examples of
%       "in_array1" - using I - we would get the values 1 and 2.
%
%       array2_examples = in_array2(I);
%       => [1,2]
%
%   J : array, length == size(input_cell_array,1)
%       Parallels the 'J' output from unique in that:
%               input_cell_array = unique_rows(J,:);
%       In other words this helps us to identify how each
%       member of the orginal array relates to the unique values
%       and can be used to do some common operation to all members
%       of an array which have the same unique value for this index.
%
%           
%           i.e. in_array1 = {'a'; 'b'; 'a'; 'b'} 
%                in_array2 = [1 2 3 4]
%       
%       [unique_rows,I,J] = sl.cell.uniqueRows(in_array1)
%
%       If we group in_array2 by J values this tells us that 'a'
%       contains [1,3] and 'b' contains [2,4]
%
%
%   Inputs:
%   -------
%   input_cell_array : cell array
%       The columns must all be of the same type. In addition, the 
%       allowable types are:
%           - strings
%           - scalars
%           - N-D matrices
%       TODO: We could technically support anything with a sortrows function
%
%   Optional Inputs:
%   ----------------
%   treat_nan_as_equal : logical (default true)
%       Whether or not to make comparisons where comparing NaN to another
%       NaN results in being the same or different.
%       Note, by default in Matlab NaN == NaN is false. Normally however
%       we don't care if two rows are the same, except that they both
%       have NaN values which makes them ineligible to be the same.
%       Because of this, the default behavior is to allow NaN values
%       to be the same as each other.
%   first_or_last_I : {'first','last'} (default 'last')
%       Whether the I value points to the first occurence of each unique
%       row in 'input_cell_array' or to the last occurrence
%
%   Examples:
%   ---------
%   1)
%       a = {'chese' 1:5 NaN
%            'asdfe' 1:5 NaN;
%            'asdfe' 1:5 NaN;
%            'beste' 1:5 NaN} 
%
%       u = sl.cell.uniqueRows(a)
%
% %     u =>  'asdfe'    [1x5 double]    [NaN]
% %           'beste'    [1x5 double]    [NaN]
% %           'chese'    [1x5 double]    [NaN]
%   
%       u = sl.cell.uniqueRows(a,'treat_nan_as_equal',false)
%   
% %     u =>  'asdfe'    [1x5 double]    [NaN]
% %           'asdfe'    [1x5 double]    [NaN]
% %           'beste'    [1x5 double]    [NaN]
% %           'chese'    [1x5 double]    [NaN]
%
%
%   See also:
%   ---------
%   isequal
%   isequalwithequalnans

in.treat_nan_as_equal = true;
in.first_or_last_I = 'last';
%TODO: Could add column order option
in = sl.in.processVarargin(in,varargin);

%JAH 1/1/2015: This code is a bit old and not up to current standards but
%it works so I'm going to leave it alone

if isempty(input_cell_array)
    unique_rows = [];
    I = [];
    J = [];
    return
end

%Some Basic Initialization
%--------------------------------------
[n_rows,n_columns] = size(input_cell_array);
COL_ORDER = 1:n_columns; %Could make this an input argument,
%affects order of unique output => see sortrows

%Handling the Simple Case
%--------------------------------------
if n_rows == 1
    unique_rows = input_cell_array; 
    I = 1; 
    J = 1; 
    return 
end


%ERROR CHECKING - CHECK CONSISTENCY FOR EACH COLUMN
%===========================================================
for iCol = 1:n_columns
    %NOT YET DONE
end


%THE SORT_CELL_BACK_TO_FRONT FUNCTION & SORTROWS
%=================================================================
%Note, cell2mat is very slow, rewrote sortrows

I = (1:n_rows)';
for k = n_columns:-1:1
    colUse = abs(COL_ORDER(k));
    %NOTE: right here we make an assumption about the types being consistent in a given column
    if isnumeric(input_cell_array{1, colUse})
        sz = cellfun('prodofsize',input_cell_array(:,colUse)); %sz = cellfun(@numel,iCA(:,k));
        if isempty(find(sz > 1,1))
            tmp = helper__fastCell2Matrix(input_cell_array(I,colUse));
            ind = sortrowsc(tmp, sign(COL_ORDER(k))*1);
        else %We are dealing with matrices
            
            %SOME ERROR CHECKING ON THE MATRICES
            %=========================================
            szS = cellfun(@size,input_cell_array(:,colUse),'UniformOutput',false);
            
            %1) DIMENSION SAME CHECK
            %----------------------------------------------
            nDims = cellfun('ndims',szS);
            if length(unique(nDims)) ~= 1
                error('%s not setup to handle varying size matrices yet',mfilename)
            end
            
            %2) EACH DIMENSION THE SAME CHECK
            %----------------------------------------------
            szMat = helper__fastCell2Matrix(szS); %NOTE: we had to first check that each input is
            %the same size, i.e. that the dimensions were the same otherwise fastC2M barfs
            %We are checking dimensions here instead of number of elements as perhaps someone
            %cares if the dimensions are different, even though the linearized contents might
            %not be ex. a = [1 3;2 4] vs b = [1 2 3 4], size(a) = [2 2], size(b) = [1 4], but
            %all(a(:) == b(:)) is true, note that the matrix code linearizes the inputs for
            %sorting purposes
            curCol = 1;
            notMatchSz = [];
            while curCol <= nDims(1) && isempty(notMatchSz)
                notMatchSz = find(diff(szMat(:,curCol)) ~= 0,1);
                curCol = curCol + 1;
            end
            
            if ~isempty(notMatchSz)
                error('%s not setup to handle varying size matrices yet',mfilename)
            end
            %=============================================
            
            tmp = helper__fastCell2Matrix(input_cell_array(I,colUse));
            ind = sortrowsc(tmp, sign(COL_ORDER(k))*(1:size(tmp,2)));
        end
        
    else
        tmp = char(input_cell_array(I,k)); %Nice and quick
        ind = sortrowsc(tmp, sign(COL_ORDER(k))*(1:size(tmp,2)));
    end
    I = I(ind);
end

%NOW RESORTING AND OBTAINING UNIQUE
%=========================================
%NOTE: ndx is the 2nd output of sortrows
input_cell_array = input_cell_array(I,:);

sameVector = false(n_rows,n_columns);

if in.treat_nan_as_equal
    for iCol = 1:n_columns
        sameVector(2:end,iCol) = arrayfun(@isequalwithequalnans,input_cell_array(2:end,iCol),input_cell_array(1:end-1,iCol));
    end
else
    for iCol = 1:n_columns
        sameVector(2:end,iCol) = arrayfun(@isequal,input_cell_array(2:end,iCol),input_cell_array(1:end-1,iCol));
    end
end

d = ~all(sameVector,2);
unique_rows = input_cell_array(d,:);

%ADDITIONAL OUTPUT HANDLING
%===========================================
if nargout == 3
    J = cumsum(d);
    J(I) = J;             % Re-reference POS to indexing of SORT.
end

% Create indices if needed.
if nargout > 1
    if in.first_or_last_I(1) == 'l'
        I = I([d(2:end); true]);  % Final element is always a member of unique list.
    else
        I = I(d); % First element is always a member of unique list.
    end
else
    I = [];
    J = [];
end
end

function m = helper__fastCell2Matrix(CA)
%ASSUMPTIONS -> all elements of CA have the same size
%TO REPLACE SLOW CELL2MAT FOR MATRICES

szCA = size(CA);
sz = numel(CA{1});

m = zeros(szCA(1),sz(1));
for iRow = 1:szCA(1)
    m(iRow,:) = CA{iRow}(:);
end
end