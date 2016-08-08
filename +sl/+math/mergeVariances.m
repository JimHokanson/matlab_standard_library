function final_variance = mergeVariances(variances,means,n_values)
%
%   final_variance = sl.math.mergeVariances(variances,means,n_values)
%
%   Computes the variance of multiple sets of data as if it had been
%   computed on all data sets at once.
%
%   One advantage of this approach, and the reason the function was
%   written, is that it allows computation of this value without
%   concatenating all of the data points together, which could exceed
%   memory limits.
%   
%
%   Examples:
%   ---------
%   1) 
%   
%   data = {[1 2 3 4] [2] [4 5 6 7]};
%   final_variance = sl.math.mergeVariances(cellfun(@var,data),cellfun(@mean,data),cellfun(@length,data))
%
%   %Compare to: var([data{:}])

final_variance = variances(1);
n_final = n_values(1);
mean_final = means(1);

for iValue = 2:length(variances)
   [final_variance,mean_final,n_final] = h__mergeVariancePairs(final_variance,variances(iValue),...
       mean_final,means(iValue),n_final,n_values(iValue));

end

end

function [v3,m3,n3] = h__mergeVariancePairs(v1,v2,m1,m2,n1,n2)
%
%   TODO: After working out the formula I realized we technically don't
%   need a loop
%


n3 = n1 + n2;

p1 = n1/n3;
p2 = n2/n3;

if n1 > 1
    v1 = v1*(n1-1)/n1;
end

if n2 > 2
    v2 = v2*(n2-1)/n2;
end

m3 = n1/n3*m1 + n2/n3*m2;

%http://stackoverflow.com/questions/1480626/merging-two-statistical-result-sets
temp = p1*(v1+(m1-m3)^2) + p2*(v2+(m2-m3)^2);

v3 = temp*(n3)/(n3-1);

end