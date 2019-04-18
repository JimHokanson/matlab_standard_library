function I = findThresholdCrossings(data,command,threshold,direction,varargin)
%x Find indices of when threshold crossings occur
%
%   I = sl.array.findThresholdCrossings(data,command,threshold,direction,varargin)
%
%       ____       ___          __        ___        __
%   ___|    |_____|   |________|  |______|   |______|  |_______
%      x          x            x         x          x  
%       
%   Why
%   ---
%   This should be a lot faster and more memory efficient than the
%   following Matlab code:
%
%       temp = (data>threshold);
%       temp = diff(temp);
%       I = find(temp==1); % Indices of rising edges
%
%   Outputs
%   -------
%   I : double array
%       Indices of when the threshold crossings occurred. Currently these
%       point to the index just before the crossing. (See Improvements 
%       Section)
%
%   Inputs
%   ------
%   data : double or single array
%   command :
%       '>'
%       '<'
%   direction :
%       'r' or 'rising'
%       'f' or 'falling'
%
%   Optional Inputs
%   ----------------
%   None yet ...
%
%   Examples
%   --------------------------------------
%   data = zeros(1,1e7);
%   data(1:1000:end) = 1;
%   threshold = 0.5;
%   I1 = sl.array.findThresholdCrossings(data,'>',threshold,'rising');
%   I1(1:3) => 1000, 2000, 3000
%   I2 = sl.array.findThresholdCrossings(data,'>',threshold,'falling');
%   I2(1:3) => 1, 1001, 2001
%
%   Improvements
%   ------------
%   1) Allow specifying where the index should occur, currently points to
%   point before crossing, we could however make this arbitrary (although
%   with no guarantees of range safety ...)

%Basically this is for a single data type with a double as the threshold
threshold = cast(threshold,'like',data); 

I = mex_findThresholdCrossings(data,double(command(1)),threshold,double(direction(1)));


end

%{
%Test code
%-----------------

%edge case testing
I1 = sl.array.findThresholdCrossings([],'>',0.5,'rising');



N1 = 100;
N2 = 10;
threshold = 0.5;
data = zeros(1,1e7,'double');
% data = zeros(1,1e7,'single');
data(5:1000:end) = 1;
data(6:1000:end) = 1;
data(7:1000:end) = 1;

%Rising, >
%---------------------------------------------
tic
for i = 1:N1
I1 = sl.array.findThresholdCrossings(data,'>',threshold,'rising');
end
t1 = toc/N1;

%Comparison code
tic
for i = 1:N2
temp = (data>threshold);
temp = diff(temp);
I2 = find(temp==1); % Indices of rising edges
end
t2 = toc/N2;

fprintf('t1: %g, t2: %g, Speedup: %g, equal: %d\n',t1*1000,t2*1000,t2/t1,isequal(I1,I2));

%Falling, >
%---------------------------------------------
tic
for i = 1:N1
I1 = sl.array.findThresholdCrossings(data,'>',threshold,'falling');
end
t1 = toc/N1;

%Comparison code
tic
for i = 1:N2
temp = (data>threshold);
temp = diff(temp);
I2 = find(temp==-1);
end
t2 = toc/N2;

fprintf('t1: %g, t2: %g, Speedup: %g, equal: %d\n',t1*1000,t2*1000,t2/t1,isequal(I1,I2));

%Falling, <
%-------------------------------------------------------
tic
for i = 1:N1
I1 = sl.array.findThresholdCrossings(data,'<',threshold,'falling');
end
t1 = toc/N1;

%Comparison code
tic
for i = 1:N2
temp = (data<threshold);
temp = diff(temp);
I2 = find(temp==1);
end
t2 = toc/N2;

fprintf('t1: %g, t2: %g, Speedup: %g, equal: %d\n',t1*1000,t2*1000,t2/t1,isequal(I1,I2));

%Rising, <
%-------------------------------------------------------
tic
for i = 1:N1
I1 = sl.array.findThresholdCrossings(data,'<',threshold,'rising');
end
t1 = toc/N1;

%Comparison code
tic
for i = 1:N2
temp = (data<threshold);
temp = diff(temp);
I2 = find(temp==-1);
end
t2 = toc/N2;

fprintf('t1: %g, t2: %g, Speedup: %g, equal: %d\n',t1*1000,t2*1000,t2/t1,isequal(I1,I2));


%}