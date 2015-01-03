function reduce_to_width_tests

n_loops = 40;
n_samples = 1e8;
%Random data
%----------------------
%1e3 - 24.7 81% 12% 12% 19%
%1e4 - 94% 28% 27% 36%
%1e5 - 89% 35% 34% 45%
%1e6 - 98% 11% 11% 14% Wow, what a difference! 

%1:n_samples
%----------------------
%1e3 - 26.7 77% 13% 11% 16%
%1e5 - 9.63 79% 38% 30% 45%

%n_samples:-1:1
%----------------------
%1e5

samples_per_chunk = 1e5;
%r = rand(1,n_samples);
%r = 1:n_samples;
r = n_samples:-1:1;

bound_indices = 1:samples_per_chunk:n_samples;
if bound_indices(end) ~= n_samples
   bound_indices = [bound_indices n_samples];
end
lefts  = bound_indices(1:end-1);
rights = [bound_indices(2:end-1)-1 bound_indices(end)];

indices1 = zeros(2,length(lefts));
indices3 = indices1;
values2 = indices1;
values4 = indices1;
values5_min = indices1(1,:);
values5_max = indices1(2,:);
%Current Approach
%----------------
tic
for i = 1:n_loops
for iRegion = 1:length(lefts)
    yt = r(lefts(iRegion):rights(iRegion));
    [~, indices(1,iRegion)] = min(yt);
    [~, indices(2,iRegion)] = max(yt);
end
end
t1 = toc

%How much do we gain by only getting min and max
%Not that much, takes about 85% of the time
tic
for i = 1:n_loops
for iRegion = 1:length(lefts)
    yt = r(lefts(iRegion):rights(iRegion));
    values2(1,iRegion) = min(yt);
    values2(2,iRegion) = max(yt);
end
end
t2 = toc

t2/t1

data_reshaped = reshape(r,samples_per_chunk,n_samples/samples_per_chunk);

tic
for i = 1:n_loops
   [~,indices3(1,:)] = min(data_reshaped,[],1);
   [~,indices3(2,:)] = max(data_reshaped,[],1);
end
t3 = toc
t3/t1

tic
for i = 1:n_loops
   values4(1,:) = min(data_reshaped,[],1);
   values4(2,:) = max(data_reshaped,[],1);
end
t4 = toc
t4/t1

tic
for i = 1:n_loops
   [values5_min, values5_max] = ChunkMinMax(r, lefts, rights); 
end
t5 = toc
t5/t1



end

% % % % 
% % % % lefts  = bound_indices(1:end-1);
% % % % rights = [bound_indices(2:end-1)-1 bound_indices(end)];
% % % % 
% % % % for iRegion = 1:axis_width_in_pixels
% % % %     yt = y(lefts(iRegion):rights(iRegion), iChan);
% % % %     [~, indices(1,iRegion)] = min(yt);
% % % %     [~, indices(2,iRegion)] = max(yt);
% % % % end