function x = filtfiltMemSafe(b,a,x)
%
%
%   Change x = x so that we might do everything in place ...

%{

http://stackoverflow.com/questions/585257/is-there-a-better-way-to-reverse-an-array-of-bytes-in-memory

%Lesson, flipping of a vector is not done in place
y1 = 1:1e8;
while true
    y1(1:1:end) = y1(end:-1:1);
    pause(0.1)
end

%More memory efficient (it seems, but still allocating memory)
while true
    y1(:) = flip(y1,1);
    pause(0.1)
end

while true
    y1 = flip(y1,1);
    pause(0.1)
end


while true
y1 = filterInChunks(y1);
pause(0.1)
end


while true
   tic
   n_in = floor(length(y1)/2);
   len_p1 = length(y1)+1;
   for iSample = 1:n_in
      end__sample = len_p1-iSample;
      t1 = y1(iSample);
      y1(iSample) = y1(end__sample);
      y1(end__sample) = t1;
   end
   toc

end



expt_id = '140414_C';
df = dba.GSK.data_file(expt_id,1);
p = df.getData('pres',-1,'filter_data',false);

filter_spec = sci.time_series.filter.butter(2,100,'low');
[B,A] = filter_spec.getCoefficients(1000);

final_data = repmat(p(3).d,[7,1]);

N_inner = 5;

for j = 1:N_inner
    p1 = filter(B,A,final_data);
end

for j = 1:N_inner
    p2 = filterInChunks(B,A,final_data,100000);
end



profile('-memory','on')
for i = 1:1
disp(i)
disp('memsafe')
tic
for j = 1:N_inner
y1 = filtfiltMemSafe(B,A,final_data);
end
toc
tic
disp('default')
for j = 1:N_inner
y2 = filtfilt(B,A,final_data);
end
toc
tic
for j = 1:N_inner
y3 = sl.array.mex_filtfilt(B,A,final_data);
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
    x = [];
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

x = ffOneChan(b,a,x,zi,nfact,L);


if isRowVec
    x = x.';   % convert back to row if necessary
end

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

end

%--------------------------------------------------------------------------
function xc = ffOneChan(b,a,xc,zi,nfact,L)

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


ii = 1;
%Get the starting conditions for going forward
xt1 = -xc(nfact+1:-1:2) + 2*xc(1);
xt2 = -xc(end-1:-1:end-nfact) + 2*xc(end);

%STEP 1: Early part for forward 
%???? I'm not sure why this isn't filtered in reverse to get the
%starting values. Perhaps I need to read the reference
[~,zo1] = filter(b(:,ii),a(:,ii), xt1, zi(:,ii)*xt1(1)); % yc1 not needed



%STEP 2: Main filtering going forward
%
%   If we think that the output and input are going to be different, then
%   this will duplicate our values


%SETUP OF IN PLACE
%=================
%[xc,zo2] = h__filterInChunks(b(:,ii),a(:,ii), xc, zo1,ceil(length(xc)/1000));

b1 = b(:,ii);
a1 = a(:,ii);
zi1 = zo1;
chunk_size = ceil(length(xc)/1000);


%IN PLACE CODE COPY
%==============================================
start_chunk = 1:chunk_size:size(xc,1);
end_chunk = start_chunk + chunk_size - 1;
if end_chunk(end) > size(xc,1);
    end_chunk(end) = size(xc,1);
end



[xc(start_chunk(1):end_chunk(1),:),zf1] = filter(b1,a1,xc(start_chunk(1):end_chunk(1),:),zi1);    


for iChunk = 2:length(start_chunk)
   cur_start = start_chunk(iChunk);
   cur_end   = end_chunk(iChunk);
   [xc(cur_start:cur_end,:),zf1] = filter(b1,a1,xc(cur_start:cur_end,:),zf1);
end
%===============================================

zo2 = zf1;

%==========================================================









%Step 3: Late part for forward, early part for going backward
yc3 = filter(b(:,ii),a(:,ii), xt2, zo2);

%Step 4: Get the initial filter conditions for going in reverse
%based on the estimated late segment
%
%Where did this zi come from?
[~,zo] = filter(b(:,ii),a(:,ii), yc3(end:-1:1), zi(:,ii)*yc3(end));

%Step 5: Filter the data going backward
%
%This isn't being done in place even though it should be by this point ...
%
xc = flip(xc,1);

%SETUP OF IN PLACE
%=================
%Better call:
%xc = h__filterInChunks(b(:,ii),a(:,ii), xc, zo,ceil(length(xc)/1000));

b1 = b(:,ii);
a1 = a(:,ii);
zi1 = zo;
chunk_size = ceil(length(xc)/1000);

%IN PLACE CODE COPY
%==============================================
start_chunk = 1:chunk_size:size(xc,1);
end_chunk = start_chunk + chunk_size - 1;
if end_chunk(end) > size(xc,1);
    end_chunk(end) = size(xc,1);
end


[xc(start_chunk(1):end_chunk(1),:),zf1] = filter(b1,a1,xc(start_chunk(1):end_chunk(1),:),zi1);    

for iChunk = 2:length(start_chunk)
   cur_start = start_chunk(iChunk);
   cur_end   = end_chunk(iChunk);
   [xc(cur_start:cur_end,:),zf1] = filter(b1,a1,xc(cur_start:cur_end,:),zf1);
end
%===============================================

%TODO: Do this in place ...
xc = flip(xc,1);

%xc = xc(end:-1:1);

end

function [xc,zf] = h__filterInChunks(b,a,xc,zi,chunk_size)

start_chunk = 1:chunk_size:size(xc,1);
end_chunk = start_chunk + chunk_size - 1;
if end_chunk(end) > size(xc,1);
    end_chunk(end) = size(xc,1);
end

if isempty(zi)
[xc(start_chunk(1):end_chunk(1),:),zf] = filter(b,a,xc(start_chunk(1):end_chunk(1),:));
else
[xc(start_chunk(1):end_chunk(1),:),zf] = filter(b,a,xc(start_chunk(1):end_chunk(1),:),zi);    
end

for iChunk = 2:length(start_chunk)
   cur_start = start_chunk(iChunk);
   cur_end   = end_chunk(iChunk);
   [xc(cur_start:cur_end,:),zf] = filter(b,a,xc(cur_start:cur_end,:),zf);
end

end