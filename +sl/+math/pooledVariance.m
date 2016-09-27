function pooled_variance = pooledVariance(variances,n_values)
%
%   pooled_variance = sl.math.pooledVariance(variances,n_values)   

% %https://en.wikipedia.org/wiki/Pooled_variance
% numerator_temp = (n1 - 1)*v1 + (n2-1)*v2;
% v3 = numerator_temp/(n3-2);

numerator = sum((n_values-1).*variances);
pooled_variance = numerator/(sum(n_values)-length(n_values));