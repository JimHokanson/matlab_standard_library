function test_maxMinViaResizing

r = rand(1e8+3456,1);

N = 20;
n_chunks = 4000;

new_m = floor(length(r)/n_chunks);

extra_samples = length(r) - new_m*n_chunks;

tic
for i = 1:N
[a,b,c,d] = pmex__minMaxViaResizing(r,new_m,n_chunks);
end
if extra_samples ~= 0
    extra_samples_m1 = extra_samples-1;
   leftover_samples = r(end-extra_samples_m1:end);
   [~,last_min_I] = min(leftover_samples);
   last_min_I = last_min_I + extra_samples_m1;
   [~,last_max_I] = max(leftover_samples);
   last_max_I = last_max_I + extra_samples_m1;
   %TODO: Put together
   min_I = [b last_min_I];
   max_I = [d last_max_I];
end
toc

lefts = 1:25000:length(r);
rights = lefts + (25000-1);

lefts(end) = [];
rights(end) = [];

a2 = a;
b2 = b;
c2 = c;
d2 = d;

tic
for i = 1:N
for iRegion = 1:length(lefts)
    yt = r(lefts(iRegion):rights(iRegion));
    [~,b2(iRegion)] = min(yt);
    [~, d2(iRegion)] = max(yt);
end
end
toc

isequal(b,b2)
isequal(d,d2)

keyboard