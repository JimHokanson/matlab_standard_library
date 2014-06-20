function test_minMaxOfDataSubset
%Speed test


N    = 1e7; %10 million
data = rand(N,1);

bound_indices = 1:1e4:N;

n_repeats = 20;

tic
for iRepeat = 1:n_repeats
    
    
    [~,~,indices_of_max,indices_of_min] = minMaxOfDataSubset(data,...
        bound_indices(1:end-1),...
        bound_indices(2:end),1,1,1);
    
    indices_both = [indices_of_max indices_of_min];
    indices2 = sort(indices_both,2)';
    
    
end
toc

tic
indices  = zeros(2,axis_width_in_pixels);
for iRepeat = 1:n_repeats
    for iRegion = 1:length(bound_indices) - 1
        left  = bound_indices(iRegion);
        right = bound_indices(iRegion+1);
        
        yt = data(left:right, iChan);
        [~, index_of_max]     = max(yt);
        [~, index_of_min]     = min(yt);
        
        %Record those indices.
        %Shift back to absolute indices due to subindexing into yt
        if index_of_max > index_of_min
            indices(1,iRegion) = index_of_min + left - 1;
            indices(2,iRegion) = index_of_max + left - 1;
        else
            indices(2,iRegion) = index_of_min + left - 1;
            indices(1,iRegion) = index_of_max + left - 1;
        end
    end
end
toc

isequal(indices,indices2)