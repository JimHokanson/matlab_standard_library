function [C idx] = mergesa(A, B, rowsflag)
% C = mergesa(A, B)
%
% Purpose: merge two sorted numerical arrays into one
%
% INPUTS
%   The inputs A and B must be numerical vectors and ascending sorted
% OUTPUT
%   C contains all elements of A and B, ascending sorted
%
% >> C = mergesa(A, B, 'rows') to merge rows (dictionary sorted)
%
% >> [C idx] = mergesa(...)
% returns idx such that C(idx>0,:) is equal to A and
%                       C(idx<0,:) is equal to B
% NOTE: there is no checking whereas the arrays are sorted
%
% See also: sort, sortrows, issorted
%
% Author Bruno Luong <brunoluong@yahoo.com>
% Date: 03-Oct-2010

if isempty(A)
    C = B;
    if nargout>=2
        if nargin < 3 || isempty(strfind('rows',lower(rowsflag)))
            idxmax = length(B);
        else
            idxmax = size(B,1);
        end
        idx = -(1:idxmax).';
    end
elseif isempty(B)
    C = A;
    if nargout>=2
        if nargin < 3 || isempty(strfind('rows',lower(rowsflag)))
            idxmax = length(A);
        else
            idxmax = size(A,1);
        end 
        idx = (1:idxmax).';
    end
else
    out = cell(1,max(nargout,1));
    % Cast A, B into a same (inferior) class
    commoncls = class([A(1) B(1)]);
    if ~isa(A, commoncls)
        A = feval(commoncls, A);
    elseif ~isa(B, commoncls)
        B = feval(commoncls, B);
    end
    % Call MEX engine
    if nargin<3
        [out{:}] = mergemex(A,B);
    else
        if isempty(strfind('rows',lower(rowsflag)))
            error('mergesa: unknown flag <%s>', rowsflag);
        end
        if size(A,2)>1
            [out{:}] = mergerowsmex(A,B);
        else
            [out{:}] = mergemex(A,B);
        end
    end
    C = out{1};
    if nargout>=2
        idx = out{2};
    end
end

end % mergesa