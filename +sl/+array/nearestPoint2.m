function [IND, D] = nearestPoint2(x,y,m) 
%nearestPoint2 - find the nearest value in another vector
%
%   [ind,d] = sl.array.nearestPoint2(x,y,*m) 
%
%   [ind,d] = sl.array.nearestPoint2('test')
%
%   JAH: Why did I download this method?
%
%   Inputs
%   ------
%   x : 
%       Does not need to be sorted
%   y :
%       Does not need to be sorted
%   m : default 'nearest'
%       - 'nearest' - no restrictions on where 'y' is relative to 'x'
%       - 'previous' - closest value in 'y' needs to be to the left of 'x'
%       - 'next' - closest value in 'y' needs to be the the right of 'x'
%
%   Outputs
%   --------
%   ind : 
%       Index of nearest point. For 'previous' and 'next' results may 
%       have NaN to indicate no match.
%   d :
%       Distance between element in 'x' and its matching 'y'
%
%   Examples
%   --------
%   
%    
%
%
%   IND = NEARESTPOINT(X,Y) finds the value in Y which is the closest to 
%   each value in X, so that abs(Xi-Yk) => abs(Xi-Yj) when k is not equal to j.
%   IND contains the indices of each of these points.
%   Example: 
%      NEARESTPOINT([1 4 12],[0 3]) % -> [1 2 2]
%       for each index in x, the value is the closest index in y
%
%   [IND,D] = ... also returns the absolute distances in D,
%   that is D == abs(X - Y(IND))
%
%   NEARESTPOINT(X, Y, M) specifies the operation mode M:
%   'nearest' : default, same as above
%   'previous': find the points in Y that are closest, but preceeds a point in X
%               NEARESTPOINT([0 4 3 12],[0 3],'previous') % -> [NaN 2 1 2]
%   'next'    : find the points in Y that are closets, but follow a point in X
%               NEARESTPOINT([1 4 3 12],[0 3],'next') % -> [2 NaN 2 NaN]
%
%   If there is no previous or next point in Y for a point X(i), IND(i)
%   will be NaN (and D(i) as well).
%
%   X and Y may be unsorted.
%
%   This function is quite fast, and especially suited for large arrays with
%   time data. For instance, X and Y may be the times of two separate events,
%   like simple and complex spike data of a neurophysiological study.
%
%   Nearestpoint('test') will run a test to show it's effective ness for
%   large data sets
%
%   Original File Details
%   ---------------------
%   version 4.1 (jan 2016)
%   (c) 2004 Jos van der Geest
%   Matlab File Exchange Author ID: 10584
%   email: samelinoa@gmail.com

% History : 
%  aug 25, 2004 - corrected to work with unsorted input values
%  nov 02, 2005 - 
%  apr 28, 2006 - fixed problem with previous points
%  sep 14, 2012 - updated for more recent versions of ML
%                 fixed two errors per suggestion of Drew Compston
%  v4.1 (jan 2016) - fixed error when second output was requested without a
%          next or previous nearestpoint (thanks to Julian)
%          - fixed mlint suggestions

if nargin==1 && strcmp(x,'test')
    IND = [];
    D = [];
    testnearestpoint();
    return
end

narginchk(2,3);

if nargin==2
    m = 'nearest';
else
    if ~ischar(m)
        error('Mode argument should be a string (either ''nearest'', ''previous'', or ''next'')') ;
    end
end

if ~isa(x,'double') || ~isa(y,'double')
    error('X and Y should be double matrices');
end

if isempty(x) || isempty(y)
    IND = [];
    D = [];
    return;
end

% sort the input vectors
sz = size(x);

%JAH: Consider skipping sorting 
[x, xi] = sort(x(:)); 
[~, xi] = sort(xi); % for rearranging the output back to X
nx = numel(x) ; 
cx = zeros(nx,1);
qx = isnan(x); % for replacing NaNs with NaNs later on

[y,yi] = sort(y(:)); 
ny = length(y); 
cy = ones(ny,1);

xy = [x ; y];

[~, xyi] = sort(xy);
cxy = [cx ; cy] ;
cxy = cxy(xyi); % cxy(i) = 0 -> xy(i) belongs to X, = 1 -> xy(i) belongs to Y
ii = cumsum(cxy);  
ii = ii(cxy==0).'; % ii should be a row vector

% reduce overhead
clear cxy xy xyi ;

switch lower(m)
    case {'nearest','near','absolute'}
        % the indices of the nearest point
        ii = [ii ; ii+1] ;
        ii(ii==0) = 1 ;
        ii(ii>ny) = ny ;         
        yy = y(ii) ;
        dy = abs(repmat(x.',2,1) - yy) ;
        [~, ai] = min(dy) ;
        IND = ii(sub2ind(size(ii),ai,1:nx)) ;
    case {'previous','prev','before'}
        % the indices of the previous points
        ii(ii < 1) = NaN ;
        IND = ii ;
    case {'next','after'}
        % the indices of the next points
        ii = ii + 1 ;
        ii(ii>ny) = NaN ;
        IND = ii ;
    otherwise
        error('Unknown method "%s"',m) ;
end

IND(qx) = NaN ; % put NaNs back in
% IND = IND(:) ; % solves a problem for x = 1-by-n and y = 1-by-1

if nargout==2
    % also return distance if requested;
    D = NaN(1,nx) ;
    q = ~isnan(IND) ;   
    if any(q)
        D(q) = abs(x(q) - reshape(y(IND(q)),[],1)) ;
    end
    D = reshape(D(xi),sz) ;
    
end
    
% reshape and sort to match input X
IND = reshape(IND(xi),sz) ;

% because Y was sorted, we have to unsort the indices
q = ~isnan(IND) ;
IND(q) = yi(IND(q)) ;

end

function testnearestpoint
disp('TEST for nearestpoint, please wait ... ') ;
M = 13 ;
tim = NaN(M,3) ;
tim(8:M,1) = 2.^(8:M).' ;
figure('Name','NearestPointTest','doublebuffer','on') ;
h = plot(tim(:,1),tim(:,2),'bo-',tim(:,1),tim(:,3),'rs-') ;
xlabel('N') ;
ylabel('Time (seconds)') ;
title('Test for Nearestpoint function ... please wait ...') ;
set(gca,'xlim',[0 max(tim(:,1))+10]) ;
for j=8:M
    N = 2.^j ;
    A = rand(N,1) ; B = rand(N,1) ;
    tic ;
    D1 = zeros(N,1) ;
    I1 = zeros(N,1) ;
    for i=1:N
        [D1(i), I1(i)] = min(abs(A(i)-B)) ;
    end
    tim(j,2) = toc ;
    pause(0.1) ;
    tic ;
    [D1x, D2x] = sl.array.nearestPoint2(A,B) ; %#ok<ASGLU>
    tim(j,3) = toc ;
    % isequal(I1,I2)
    set(h(1),'Ydata',tim(:,2)) ;
    set(h(2),'Ydata',tim(:,3)) ;
    drawnow ;
end
disp('Done.')
title('Test for Nearestpoint function') ;
legend({'Traditional for-loop','Nearestpoint'}) ;

end


