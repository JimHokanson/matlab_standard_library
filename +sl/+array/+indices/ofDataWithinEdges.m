function [I1,I2] = ofDataWithinEdges(data,varargin)
%x Compute data indices that bound either side of each 
%
%   [I1,I2] = sl.array.indices.ofDataWithinEdges(data,edges)
%
%   [I1,I2] = sl.array.indices.ofDataWithinEdges(data,left_edges,right_edges)
%
%   Purpose. This function was originally written to go from times
%   to a continuous rate code, where the times are the 'data' and the
%   edges are time samples.
%   
%   Pseudocode
%   ----------
%   for i = 1:length(left_edges)
%       temp = find(data > left_edges(i) & data <= right_edges(i);
%       if ~isempty(temp)
%           I1(i) = temp(1);
%           I2(i) = temp(end);
%       else
%           I1(i) = 1;
%           I2(i) = 0;
%       end
%   end
%
%
%   TODO: This should be the fallback for mex code. The mex code has
%   been moved locally but still needs to be reorganized.
%
%   Inputs
%   ------
%   data : array
%       Values. MUST BE SORTED.
%   edges : array
%       When edges are passed in, the boundaries are defined as being
%       greater than one edge and less than its neighbor.
%   left_edges: array
%       Paired with right_edges. We are thus looking for values that
%       are greater than the left edge and less than the right edge.
%   right_edges: array
%
%   Outputs
%   -------
%   I1 : 
%       Left indices of data that falls within the edge boundaries.
%       i.e. I1(i) corresponds to the index of the data point that 
%       is the FIRST TO SATISFY:
%       i.e. data(I1(i))  > left_edges(i) & < right_edges(i)
%
%       This value is set to 1 when no values are valid.
%   I2 : 
%       Right indices of data ...
%       This is the index that is LAST TO SATISFY ...
%
%       This value is set to 0 when no values are valid
%
%   note, the # of values between each edge can be computed as:
%   n_values_between_edges = I2 - I1 + 1;
%
%   Examples
%   --------
%   data = 3:10
%   edges = 1:3:20
%   [I1,I2] = sl.array.indices.ofDataWithinEdges(data,edges)
%   I1 => [1,3,6,1,1,1]
%   I2 => [2,5,8,0,0,0]
%
%   Explanation of the example
%   --------------------------
%   Edges:         1     4     7     10       13  ...
%   data               3 4 5 6 7 8 9 10
%   indices of data    1 2 3 4 5 6 7 8
%      I1 indices      x   x     x               
%      I2 indices        x     x     x
%
%   Note this example also exposes the equality rules, that we are looking
%   for > and <=
%   Eventually this could be extended to better rules, but this would be 
%   difficult with this approach ...
%
%   Why (for example) is I1(2) => 3
%   Because: data(3) => 5
%       and this is the first value that is greater than
%       edges(2) (value of 4)
%   Another example, why is I2(3) => 8
%   Because
%
%   Because the 3rd value of data has a value of 5, which is the FIRST VALUE 
%   that is greater than the 2nd index of the edges (4
%
%   in words, I1(2) => 3, because data(3) (value=5) is the first value that 
%   is greater than the 2nd edge value
%
%  

if nargin == 3
    t1 = varargin{1};
    t2 = varargin{2};
else
    edges = varargin{1};
    t1 = edges(1:end-1);
    t2 = edges(2:end);    
end

if length(t1) ~= length(t2)
    error('Inputs t1 & t2 must be the same size')
end

if isempty(data)
    %Maintains size
    I1 = ones(size(t1));
    I2 = zeros(size(t2));
    return
end

I = find(t1 >= data(end),1);

%MAGIC, BEWARE :)
%------------------------------------------------
%I forgot where I first saw this trick being used
if size(data,1) > 1
    [~,I1] = histc(t1,[-inf; data]);
else
    [~,I1] = histc(t1,[-inf data]);
end
I1(I:end) = 1;

if nargout == 1
    return
end

if t2(end) == inf
    t2(end) = datatypemax(t2(1));
end

if size(data,1) > 1
    [~,I2] = histc(t2,[data; inf]);
else
    [~,I2] = histc(t2,[data inf]);
end
I2(I:end) = 0; %This provides empty indexing and lengths of 0

end

% % % % function h__runCheck()
% % % %     if in.check
% % % %         I1 = cell(1,length(t1));
% % % %         I2 = I1;
% % % %         for ii = 1:length(t1)
% % % %             I1{ii} = find(ts >= t1(ii),1);
% % % %             I2{ii} = find(ts < t2(ii),1,'last');
% % % %         end
% % % %
% % % %         I = find(cellfun('isempty',I1) | cellfun('isempty',I2));
% % % %         %I = find(cellfun(@(x,y) isempty(x) | isempty(y),I1,I2));
% % % %         %keyboard
% % % %         I1(I) = {1};
% % % %         I2(I) = {0};
% % % %         I1 = cell2mat(I1);
% % % %         I2 = cell2mat(I2);
% % % %         if any(I1 - i1 ~= 0) || any(I2 - i2 ~= 0)
% % % %            error('Check failed, there is a difference between the generated indices')
% % % %         end
% % % %     end
% % % % end

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




