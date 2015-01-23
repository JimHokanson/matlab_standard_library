function tests_chunkMinMax2
y = rand(2e8,1);

chunk_size = 1e5;

lefts  = 1000:1e5:1e8;
rights = lefts + chunk_size - 1; 

indices = zeros(2,length(lefts));

tic
for iRegion = 1:length(lefts)
    yt = y(lefts(iRegion):rights(iRegion), 1);
    [~, indices(1,iRegion)] = min(yt);
    [~, indices(2,iRegion)] = max(yt);
end
indices = bsxfun(@plus,indices,lefts-1);
toc

tic
[~,~,minI,maxI] = pmex__chunkMinMax(y,lefts,rights);
toc

keyboard