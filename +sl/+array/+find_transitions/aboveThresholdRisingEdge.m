function I = aboveThresholdRisingEdge(data,threshold)
%X find indices where data goes from below to above threshold
%
%   I = sl.array.find_transitions.aboveThresholdRisingEdge(data,threshold)
%
%   Written to be a bit faster but also to save memory.
%
%   JAH: What did I need this for? Why not write others?
%
%   Inputs
%   ------
%   
%   See Also
%   --------
%   sl.array.findThresholdCrossings

%Compiling:
%   mex findThresholdTransitions.c
%
%   This was renamedto mex_findTHresholdCrossings
%
%   It seems like this was an effort to make the calls easier to make
%   than: sl.array.findThresholdCrossings

%{
%Test code
%-----------------
data = zeros(1,1e7);
data(5:1000:end) = 1;
I1 = sl.array.find_transitions.aboveThresholdRisingEdge(data,0.5);


%}

%Options
%-------
%0 - 

%Call to C code
I = findThresholdTransitions(data,threshold,0);

%{
data = zeros(1,1e7);
data(5:1000:end) = 1;
data(5) = 1;
data(end-1) = 0;
threshold = 0.5;
%sl.array.find_transitions.aboveThresholdRisingEdge(data,0.5)

tic
for i = 1:10
pulsemat = data;
pulsemat = (pulsemat>threshold);
pulsemat = diff(pulsemat);
trig_indices = find(pulsemat==1); % Indices of rising edges
end
t1 = toc;

tic
for i = 1:10
wtf = sl.array.find_transitions.aboveThresholdRisingEdge(data,threshold);
end
t2 = toc;

fprintf('t1 (MATLAB): %g, t2 (mex): %g, ratio: %g, equal: %d\n',t1,t2,t1/t2,isequal(trig_indices,wtf));
%}

end