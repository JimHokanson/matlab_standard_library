function solve(obj)
%
%
%   IMPROVEMENTS:
%   =======================================================================
%   1) Even if we have old data, allow the first set of indices to be set
%   based on the bounds ...
%
%   FULL PATH:
%   sci.cluster.iterative_max_distance.solve
%

% previous_data
% new_data
% starting_indices

new_data = obj.new_data;
old_data = obj.previous_data;

n_new              = size(new_data,1);
starting_indices   = obj.starting_indices;
n_starting_indices = length(starting_indices);

%Initialization of the first set of points
%--------------------------------------------------------------------------
%TODO: Make this a function ...
if isempty(old_data) && n_starting_indices == 0
    
    [~,I_min] = min(new_data);
    [~,I_max] = max(new_data);
    
    starting_indices = unique([I_min I_max]);
    obj.starting_indices = starting_indices;
    n_starting_indices   = length(starting_indices);
end

%These will be our output variables ...
index_order  = zeros(1,n_new);
max_distance = zeros(1,n_new);

if n_starting_indices ~= 0
    index_order(1:n_starting_indices) = starting_indices;
end

%[IDX,D] = knnsearch(X,Y)
%--------------------------------------------------------------------------
%X - MX-by-N
%Y - MY-by-M
%
%D - MY-by_K <- Important, D is sized by Y, relative to points in X

%Calculation of 'min_dist_to_chosen_point'
%--------------------------------------------------------------------------
%min_dist_to_chosen_point reflects the minimum distance from all unchosen
%points to all previously chosen points. The point that has the maximum in
%this vector at any step cycle is the point that is the furthest from
%any chosen point. We need to make sure this kept up to date as we choose
%new points ...

if isempty(starting_indices)
    if isempty(old_data)
        error('Logic above changed, starting indices should be defined if old data is not')
    end
    [~,min_dist_to_chosen_point] = knnsearch(old_data,new_data);
else
    [~,min_dist_to_chosen_point] = knnsearch(new_data(starting_indices,:),new_data);
    if ~isempty(old_data)
        %Old data are considered chosen points as well ...
        %Merge via min(x,y) operation, not by previous concatenation
        [~,temp] = knnsearch(old_data,new_data);
        min_dist_to_chosen_point = min(min_dist_to_chosen_point,temp);
    end
end



min_dist_to_chosen_point(starting_indices) = 0; %By definition ...

%Info for adjusting min_dist_to_chosen_point during the loop
%--------------------------------------------------------------------------
[idx_nn,dist_nn] = knnsearch(new_data,new_data,'K',50);

%Transpose for grabbing along columns
dist_nn = dist_nn';
idx_nn  = idx_nn';

%Some final initialization before the loop
%--------------------------------------------------------------------------
exhaustive_search = false(1,n_new);

not_chosen_mask = true(1,n_new);
not_chosen_mask(starting_indices)  = false;

%Main algorithm
%--------------------------------------------------------------------------
%More on the algorithm being used can be found at the end of the file ...
%   - might move it ...
for iPoint = n_starting_indices+1:n_new
    
    %SLOW LINE
    [cur_max_distance,I] = max(min_dist_to_chosen_point);
    
    index_order(iPoint) = I;
    not_chosen_mask(I)  = false;
    max_distance(iPoint)    = cur_max_distance;
    min_dist_to_chosen_point(I) = 0;
    
    if dist_nn(end,I) < cur_max_distance
        %Then we aren't bounded in our sorted list and we need to do an
        %exhaustive search to update points which may now be closer
        %to this point than to previously chosen points ...
        exhaustive_search(iPoint) = true;
        min_dist_to_chosen_point(not_chosen_mask) = ...
            min(min_dist_to_chosen_point(not_chosen_mask),pdist2(new_data(not_chosen_mask,:),new_data(I,:)));
    else
        last_update_index = find(dist_nn(:,I) > cur_max_distance,1)-1;
        update_indices    = idx_nn(1:last_update_index,I);
        min_dist_to_chosen_point(update_indices) = ...
            min(min_dist_to_chosen_point(update_indices),dist_nn(1:last_update_index,I));
    end
end


%Property Assignment
%--------------------------------------------------------------------------
obj.exhaustive_search = exhaustive_search;
obj.index_order       = index_order;
obj.max_distance      = max_distance;



%At this point we have a vector which contains the smallest distance to a
%"chosen" point. The algorithm now involves:
%1) Going through and finding the point whose min value is the largest, in
%other words, who is the furthest away from any previously chosen point
%2) Adjusting other points so that if they are closer to this new point
%than previously chosen points, updating the
%       smallest_distance_to_a_chosen_point
%accordingly so that it holds the distance
%to this new point, and not whichever previously chosen point they were
%previously bound to.
%
%Importantly, this doesn't need to be an exhaustive search because at all
%times we know the largest distance between an "unknown" or "unchosen"
%point and all previously chosen points. Thus, once we encounter distances
%between this newly chosen points and other points we can stop as they
%will never be closer to the newly chosen point than they are to some other
%already chosen point, otherwise, the maximum distance to a chosen point
%would be incorrect. Put loosely in code this is:
%
%   next_point = index of max (minimum distances from unchosen to chosen points)
%
%   cur_max_distance = distance value at next_point index
%
%   At this point, all unchosen points are are within cur_max_distance
%   of at least one chosen point
%
%   Next: Update min_distance values accordingly given that next_point
%   is now considered to be chosen
%
%   smallest_distance_to_a_chosen_point =
%           min(smallest_distance_to_a_chosen_point,distance to next_point)
%
%   IMPORTANTLY:
%   If we had a sorted list of distances from the point to others, we could
%   stop once we get larger than cur_max_distance, because the other
%   points would never satisfy the minimum comparison above, i.e.
%
%   min(smallest_distance_to_a_chosen_point,distance to next_point)
%
%   to do so would mean that the next_point choice above was invalid ...
%
%   We use knnsearch to form a partially sorted list of smallest distances.
%   If the max occurs within this list, we can stop. If not, we must
%   compute the distance from this point to all other points ...


end