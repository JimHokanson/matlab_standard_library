function I = aboveThresholdRisingEdge(data,threshold)
%
%   I = sl.array.find_transitions.aboveThresholdRisingEdge(data,threshold)
%
%   

%Compiling:
%   mex findThresholdTransitions.c

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

I = findThresholdTransitions(data,threshold,0);

%{
data = zeros(1,1e7);
% data(5:1000:end) = 1;
data(5) = 1;
data(end-1) = 0;
sl.array.find_transitions.aboveThresholdRisingEdge(data,0.5)
%}

% % % % % % tic
% % % % % % for i = 1:10
% % % % % % pulsemat        = data;
% % % % % % pulsemat        = (pulsemat>threshold);
% % % % % % pulsemat        = diff(pulsemat);
% % % % % % trig_indices    = find(pulsemat==1); % Indices of rising edges
% % % % % % end
% % % % % % t1 = toc;
% % % % % % 
% % % % % % tic
% % % % % % for i = 1:10
% % % % % % wtf = findThresholdTransitions(data,threshold,0);
% % % % % % end
% % % % % % t2 = toc;
% % % % % % 
% % % % % % fprintf('t1: %g, t2: %g, ratio: %g, equal: %d\n',t1,t2,t1/t2,isequal(trig_indices,wtf));

end