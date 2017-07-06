function varargout = mergesort(varargin)
%x Merges two sorted arrays into one.
%
%   [c,idx] = sl.array.mergesort(a,b)
%
%   Inputs
%   ------
%   a :
%   b :
%
%   Outputs
%   -------
%   c :
%   idx :
%       c(idx > 0) is equal to A
%       c(idx < 0) is equal to B
%
%   Usage Notes
%   -----------
%   - Input arrays A and B must be ascending sorted. This is not checked
%     by the code.
%
%   Examples
%   --------
%   1) Speed Comparison
%   tic
%   a = 1:2:2e7;
%   b = 2:2:2e7;
%   [c,idx] = sl.array.mergesort(a,b);
%   toc
%
%   tic
%   [c2,idx2] = sort([a b]);
%   toc
%
%   2) Output Example
%   a = 1:2:10;
%   b = 2:2:10;
%   [c,idx] = sl.array.mergesort(a,b)
%   c => 1     2     3     4     5     6     7     8     9    10
%   c => 1    -1     2    -2     3    -3     4    -4     5    -5
%   
% 
% Author Bruno Luong <brunoluong@?????.com>
% Date: 03-Oct-2010
% http://www.mathworks.com/matlabcentral/fileexchange/28930-merge-sorted-arrays

fprintf('MEX file mergemex not yet compiled\nAction:\n');
fprintf('\t mergesa_install\n');

error('merge sort not compiled')


end