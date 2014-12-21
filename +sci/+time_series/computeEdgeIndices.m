function [i1,i2] = computeEdgeIndices(ts,t1,t2,check)
%computeEdgeIndices
%
%
%   TODO: This needs to be moved
%   
%
%
%   [I1,I2] = computeEdgeIndices(TS,T1,T2,*CHECK) computes the edge indices 
%   for every T1 & T2 pair where T1 < TS <= T2.  I1 is the first value
%   where this is true, and I2 is the last, and is equivalent to
%   the code below, assuming that T1(n) < T2(n), but should be alot faster.
%
%   Note: For missing pairs (no events between them), these get 
%   returned as 1,0 for I1 & I2 respectively.  Searching for I2 = 0 will
%   indicate which pairs have no events in between.  In addition the # of
%   events can be calculated as I2 - I1 + 1, which results in 0, for I2 = 0
%   and I1 = 0.
%
%   I1      : For every T1,T2 pair, the FIRST index at which TS falls 
%             between the two times values
%   I2      : For every T1,T2 pair, the LAST index, "               "
%
%   TS      : Time of events
%   T1      : Left time edges for computing indices 
%   T2      : Right time edges for computing indices
%   *CHECK  : (default false), if true, calculates I1 & I2 via for loops,
%              to check that the approach is correct
%   
%   COMPUTING EFFICIENCY (IMPORTANT REQUIREMENT):
%   The computing efficiency comes in from the assumption that both T1 and
%   T2 are ordered within themselves, T1(n) < T1(n+1) & the same for T2,
%   this means when searching for TS events that are between T1(n) and
%   T2(n), we only need to start the search (on the left side) whereever
%   T1(n-1) left off.  I.E. If TS = [1 3 5] and I1(n-1) is index 2, we know
%   that I1(n), if valid (i.e. not empty and hence = 1), has to be at least
%   2 because T1(n - 1) is greater than 1 (the first index of Ts), and 
%   hence T1(n) will also be.  This means that instead of every T1,T2 pair
%   searching over all Ts, it can do search in sliding windows, starting
%   the search wherever the last index left off.
%
%   EXAMPLE:
%   ====================================
%   TS = [1 3 5 10];
%   T1 = [0 2 8];
%   T2 = [2 9 10];
%
%   [I1,I2] = computeEdgeIndices(TS,T1,T2);
%   
%   I1 => [1 2 4];
%   I2 => [1 3 4];
%
%   Note, this says, for T1(1) = 0 & T2(1) = 2
%   I1(1) = 1
%   I2(1) = 1
%   indicating that  TS(1:1) is between 0 and 2
%
%   For T1(2) = 2 & T2(2) = 9
%   I1(2) = 2
%   I2(2) = 3
%   indicating that TS(2:3) is between 2 and 9
%   
%
%   See also: calcFrFast, histc
        
    if nargin == 3
        check = 0;
    end
    
    if length(t1) ~= length(t2)
        error('Inputs t1 & t2 must be the same size')
    end

    %MAGIC, BEWARE :)
    if size(ts,1) > 1
        [~,i1] = histc(t1,[-inf; ts]);
    else
        [~,i1] = histc(t1,[-inf ts]);
    end

    if t2(end) == inf
        t2(end) = datatypemax(t2(1));
    end
    
    %IF <= don't offset
    if size(ts,1) > 1
        [~,i2] = histc(t2,[ts; inf]);
    else
        [~,i2] = histc(t2,[ts inf]);
    end
    %else add a really small number to t2 or - a small # from ts

    if isempty(ts)
        %Maintains size
        i1 = ones(size(t1));
        i2 = zeros(size(t2));
        return
    end
    
    I = find(t1 >= ts(end),1);
    i1(I:end) = 1;
    i2(I:end) = 0; %This provides empty indexing and lengths of 0
    
    if check
        I1 = cell(1,length(t1));
        I2 = I1;
        for ii = 1:length(t1)
            I1{ii} = find(ts >= t1(ii),1);
            I2{ii} = find(ts < t2(ii),1,'last');
        end
        
        I = find(cellfun('isempty',I1) | cellfun('isempty',I2));
        %I = find(cellfun(@(x,y) isempty(x) | isempty(y),I1,I2));
        %keyboard
        I1(I) = {1};
        I2(I) = {0};
        I1 = cell2mat(I1);
        I2 = cell2mat(I2);
        if any(I1 - i1 ~= 0) || any(I2 - i2 ~= 0)
           error('Check failed, there is a difference between the generated indices') 
        end
    end
end


%Some random code that I used for testing
%==============================================
% tic
% for i = 1:1000
% 
%     ts = sort(rand(1000,1).*rand(1000,1));
%     t1 = 0:0.001:1;
%     t2 = t1 + .1;
% 
%     [i1,i2] = computeEdgeIndices(ts,t1,t2,0);
% 
% end
% toc




