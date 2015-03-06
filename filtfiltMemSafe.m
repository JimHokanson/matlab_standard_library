function y = filtfiltMemSafe(b,a,x)
%

%{
expt_id = '140414_C';
df = dba.GSK.data_file(expt_id,1);
p = df.getData('pres',-1,'filter_data',false);

filter_spec = sci.time_series.filter.butter(2,100,'low');
[B,A] = filter_spec.getCoefficients(1000)

final_data = repmat(p(3).d,[7,1]);

profile('-memory','on')
for i = 1:1
disp(i)
disp('memsafe')
tic
for j = 1:10
y1 = filtfiltMemSafe(B,A,final_data);
end
toc
tic
disp('default')
for j = 1:10
y2 = filtfilt(B,A,final_data);
end
toc
end
profile off
profile viewer


%}

%   Copyright 1988-2014 The MathWorks, Inc.

narginchk(3,3)

% Only double precision is supported
if ~isa(b,'double') || ~isa(a,'double') || ~isa(x,'double')
    error(message('signal:filtfilt:NotSupported'));
end
if isempty(b) || isempty(a) || isempty(x)
    y = [];
    return
end

% If input data is a row vector, convert it to a column
isRowVec = size(x,1)==1;
if isRowVec
    x = x(:);
end
[Npts,Nchans] = size(x);

% Parse SOS matrix or coefficients vectors and determine initial conditions
[b,a,zi,nfact,L] = getCoeffsAndInitialConditions(b,a,Npts);

% Filter the data
if Nchans==1
    if Npts<10000
        y = ffOneChanCat(b,a,x,zi,nfact,L);
    else
        y = ffOneChan(b,a,x,zi,nfact,L);
    end
else
    y = ffMultiChan(b,a,x,zi,nfact,L);
end

if isRowVec
    y = y.';   % convert back to row if necessary
end

%--------------------------------------------------------------------------
function [b,a,zi,nfact,L] = getCoeffsAndInitialConditions(b,a,Npts)

[L, ncols] = size(b);
na = numel(a);

% Rules for the first two inputs to represent an SOS filter:
% b is an Lx6 matrix with L>1 or,
% b is a 1x6 vector, its 4th element is equal to 1 and a has less than 2
% elements. 
if ncols==6 && L==1 && na<=2,
    if b(4)==1,
        warning(message('signal:filtfilt:ParseSOS', 'SOS', 'G'));
    else
        warning(message('signal:filtfilt:ParseB', 'a01', 'SOS'));
    end
end
issos = ncols==6 && (L>1 || (b(4)==1 && na<=2));
if issos,
    %----------------------------------------------------------------------
    % b is an SOS matrix, a is a vector of scale values
    %----------------------------------------------------------------------
    g = a(:);
    ng = na;
    if ng>L+1,
        error(message('signal:filtfilt:InvalidDimensionsScaleValues', L + 1));
    elseif ng==L+1,
        % Include last scale value in the numerator part of the SOS Matrix
        b(L,1:3) = g(L+1)*b(L,1:3);
        ng = ng-1;
    end
    for ii=1:ng,
        % Include scale values in the numerator part of the SOS Matrix
        b(ii,1:3) = g(ii)*b(ii,1:3);
    end
    
    ord = filtord(b);
    
    a = b(:,4:6).';
    b = b(:,1:3).';
         
    nfact = max(1,3*ord); % length of edge transients    
    if Npts <= nfact % input data too short
        error(message('signal:filtfilt:InvalidDimensionsDataShortForFiltOrder',num2str(nfact)))
    end
    
    % Compute initial conditions to remove DC offset at beginning and end of
    % filtered sequence.  Use sparse matrix to solve linear system for initial
    % conditions zi, which is the vector of states for the filter b(z)/a(z) in
    % the state-space formulation of the filter.
    zi = zeros(2,L);
    for ii=1:L,
        rhs  = (b(2:3,ii) - b(1,ii)*a(2:3,ii));
        zi(:,ii) = ( eye(2) - [-a(2:3,ii),[1;0]] ) \ rhs;
    end
    
else
    %----------------------------------------------------------------------
    % b and a are vectors that define the transfer function of the filter
    %----------------------------------------------------------------------
    L = 1;
    % Check coefficients
    b = b(:);
    a = a(:);
    nb = numel(b);
    nfilt = max(nb,na);   
    nfact = max(1,3*(nfilt-1));  % length of edge transients
    if Npts <= nfact      % input data too short
        error(message('signal:filtfilt:InvalidDimensionsDataShortForFiltOrder',num2str(nfact)));
    end
    % Zero pad shorter coefficient vector as needed
    if nb < nfilt
        b(nfilt,1)=0;
    elseif na < nfilt
        a(nfilt,1)=0;
    end
    
    % Compute initial conditions to remove DC offset at beginning and end of
    % filtered sequence.  Use sparse matrix to solve linear system for initial
    % conditions zi, which is the vector of states for the filter b(z)/a(z) in
    % the state-space formulation of the filter.
    if nfilt>1
        rows = [1:nfilt-1, 2:nfilt-1, 1:nfilt-2];
        cols = [ones(1,nfilt-1), 2:nfilt-1, 2:nfilt-1];
        vals = [1+a(2), a(3:nfilt).', ones(1,nfilt-2), -ones(1,nfilt-2)];
        rhs  = b(2:nfilt) - b(1)*a(2:nfilt);
        zi   = sparse(rows,cols,vals) \ rhs;
        % The non-sparse solution to zi may be computed using:
        %      zi = ( eye(nfilt-1) - [-a(2:nfilt), [eye(nfilt-2); ...
        %                                           zeros(1,nfilt-2)]] ) \ ...
        %          ( b(2:nfilt) - b(1)*a(2:nfilt) );
    else
        zi = zeros(0,1);
    end
end

%--------------------------------------------------------------------------
function y = ffOneChan(b,a,xc,zi,nfact,L)

%{
%Single channel data with padding added on
%For small data only
for ii=1:L
    % Single channel, data explicitly concatenated into one vector
    y = [2*y(1)-y(nfact+1:-1:2); y; 2*y(end)-y(end-1:-1:end-nfact)]; %#ok<AGROW>
    
    % filter, reverse data, filter again, and reverse data again
    y = filter(b(:,ii),a(:,ii),y,zi(:,ii)*y(1));
    y = y(end:-1:1);
    y = filter(b(:,ii),a(:,ii),y,zi(:,ii)*y(1));
    
    % retain reversed central section of y
    y = y(end-nfact:-1:nfact+1);
end

%}


%    xxxxxxxxxxx    %%%%
%
%Step 1: guess at initial data by filtering early segments backward
%....xxxxxxxxxxx
%
%Step 2: filter forward using guessed at early segments
%
%Step 3: Continue filtering past the data to guess at late data
%    xxxxxxxxxxx....
%
%Step 4: 

%TODO: Some in place data flipping would be great

ii = 1;
%Get the starting conditions for going forward
xt1 = -xc(nfact+1:-1:2) + 2*xc(1);
xt2 = -xc(end-1:-1:end-nfact) + 2*xc(end);

%STEP 1: Early part for forward 
%???? I'm not sure why this isn't filtered in reverse to get the
%starting values. Perhaps I need to read the reference
[~,zo1] = filter(b(:,ii),a(:,ii), xt1, zi(:,ii)*xt1(1)); % yc1 not needed

%STEP 2: Main filtering going forward
[xc,zo2] = filter(b(:,ii),a(:,ii), xc, zo1);

%Step 3: Late part for forward, early part for going backward
yc3 = filter(b(:,ii),a(:,ii), xt2, zo2);

%Step 4: Get the initial filter conditions for going in reverse
%based on the estimated late segment
[~,zo] = filter(b(:,ii),a(:,ii), yc3(end:-1:1), zi(:,ii)*yc3(end));

%Step 5: Filter the data going backward
xc = filter(b(:,ii),a(:,ii), xc(end:-1:1), zo);

xc = xc(end:-1:1);

y = xc;

