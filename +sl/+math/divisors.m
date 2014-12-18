function d = divisors(n)
%
%   d = sl.math.divisors(n)
%
%   TODO: Document function
%
%   Examples:
%   ---------
%   d = sl.math.divisors(210);

f = factor(n);
[uf,temp] = sl.array.uniqueWithGroupIndices(f);

n_uf = cellfun('length',temp);

%% Calculate the divisors
d = 1;
for f = uf
    d = d*(f.^(0:n_uf));
    d = d(:);
end
d = sort(d)';