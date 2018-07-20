function [M,TF] = concatenate(cell_data,varargin)
%X concatenate vectors with different lengths by padding
%
%   [M,TF] = sl.array.concatenate(cell_data,varargin)
%
%   Outputs
%   -------
%   M :
%
%   Inputs
%   ------
%   cell_data : cell array
%
%   Optional Inputs
%   ----------------
%   pad : NYI (default NaN)
%
%   Improvements
%   ------------
%   1) Improve documentation
%   2) Examine concatenation technique used for 2d matrices compared to
%   for-loop
%   3) horizontal vs vertical????
%
%   Based on:
%   https://www.mathworks.com/matlabcentral/fileexchange/22909-padcat-varargin-







%Old documentation

%   M = PADCAT(V1, V2, V3, ..., VN) concatenates the vectors V1 through VN
%   into one large matrix. All vectors should have the same orientation,
%   that is, they are all row or column vectors. The vectors do not need to
%   have the same lengths, and shorter vectors are padded with NaNs.
%   The size of M is determined by the length of the longest vector. For
%   row vectors, M will be a N-by-MaxL matrix and for column vectors, M
%   will be a MaxL-by-N matrix, where MaxL is the length of the longest
%   vector.
%
%   Examples:
%      a = 1:5 ; b = 1:3 ; c = [] ; d = 1:4 ;
%      padcat(a,b,c,d) % row vectors
%         % ->   1     2     3     4     5
%         %      1     2     3   NaN   NaN
%         %    NaN   NaN   NaN   NaN   NaN
%         %      1     2     3     4   NaN
%      CC = {d.' a.' c.' b.' d.'} ;
%      padcat(CC{:}) % column vectors
%         %      1     1   NaN     1     1
%         %      2     2   NaN     2     2
%         %      3     3   NaN     3     3
%         %      4     4   NaN   NaN     4
%         %    NaN     5   NaN   NaN   NaN
%
%   [M, TF] = PADCAT(..) will also return a logical matrix TF with the same
%   size as R having true values for those positions that originate from an
%   input vector. This may be useful if any of the vectors contain NaNs.
%
%   Example:
%       a = 1:3 ; b = [] ; c = [1 NaN] ;
%       [M,tf] = padcat(a,b,c)
%       % find the original NaN
%       [Vev,Pos] = find(tf & isnan(M))
%       % -> Vec = 3 , Pos = 2
%
%   This second output can also be used to change the padding value into
%   something else than NaN.
%
%       [M, tf] = padcat(1:3,1,1:4)
%       M(~tf) = 99 % change the padding value into 99
%
%   Scalars will be concatenated into a single column vector.
%
%   See also CAT, RESHAPE, STRVCAT, CHAR, HORZCAT, VERTCAT, ISEMPTY
%            NONES, GROUP2CELL (Matlab File Exchange)

% for Matlab 2008 and up (tested in R2015a)
% version 2.2 (feb 2016)
% (c) Jos van der Geest
% email: samelinoa@gmail.com

% History
% 1.0 (feb 2009) created
% 1.1 (feb 2011) improved comments
% 1.2 (oct 2011) added help on changing the padding value into something
%     else than NaN
% 2.2 (feb 2016) updated contact info

% Acknowledgements:
% Inspired by padadd.m (feb 2000) Fex ID 209 by Dave Johnson

% narginchk(1,Inf) ;

%NYI
in.pad = NaN;
in.pad_rows = true;
in = sl.in.processVarargin(in,varargin);

% check the inputs
% SZ = cellfun(@size,cell_data,'UniformOutput',false) ; % sizes
% Ndim = cellfun(@ndims,cell_data) ; %
%
% if ~all(Ndim==2)
%     error([mfilename ':WrongInputDimension'], ...
%         'Input should be vectors.') ;
% end

TF = [] ; % default second output so we do not have to check all the time

if length(cell_data) == 1
    % single input, nothing to concatenate ..
    M = cell_data{1} ;
else
    if in.pad_rows
        n_rows_out = max(cellfun(@(x) size(x,1),cell_data));
        n_cols_out = sum(cellfun(@(x) size(x,2),cell_data));
        
        %This could change based on in.pad
        M = NaN(n_rows_out,n_cols_out);
        %max_rows
        end_I = 0;
        for i = 1:length(cell_data)
            cell_value = cell_data{i};
            start_I = end_I + 1;
            end_I = end_I + size(cell_value,2);
            n_rows = size(cell_value,1);
            M(1:n_rows,start_I:end_I) = cell_value;
        end
    end
    
    if nargout>1
        error('Not yet implemented')
    end
end % nargin == 1

if nargout > 1 && isempty(TF)
    % in this case, the inputs were all empty, all scalars, or all had the
    % same size.
    TF = true(size(M)) ;
end
