function [indices,type_id,groups] = getTypeIndices(obj,types_to_get)
%getTypeIndices
%
%    [indices,type_id,groups] = getTypeIndices(obj,types_to_get)
%
%    The simplest way to understand this function may be to examine
%    the example.
%
%    INPUTS
%    ======================================================================
%    types_to_get : (cellstr), types for which we want
%                    information about
%
%    OUTPUTS
%    ======================================================================
%    indices  : ([1 x n]) original indices containing one of the types
%                (sorted)
%    type_ids : ([1 x n]), for each entry, which of the
%                requested types it matches, 1 indicates it matches the
%                first type entry, 2, the second entry, etc.
%    groups   : ({1 x n_unique}), for each unique type, this indexes
%                into the two above properties, specifying which belong
%                to the specified type. It does NOT index into the original
%                set of entries, that would be done via indices(groups{#})
%
%   
%   EXAMPLE
%   =======================================================================
%   getTypeIndices(obj,{'<NAME>' '<INT>' 'FOR'})
%
%     1 2  3  4  5  6
%     ---------------------------------------------------------------
%     1 10 20 30 51 70 <= indices
%     1 2  1  3  1  2  <= type_ids -  1 => <NAME>, 2 => <INT> 3 => 'FOR'
% 
%     groups:
%     {1 3 5}          <= for each request, which are of this type ...
%     {2 6}
%     {4}

if ischar(types_to_get)
    types_to_get = {types_to_get};
end

n_types_get = length(types_to_get);

myMap       = obj.unique_types_map;
is_key_mask = myMap.isKey(types_to_get);
n_found     = sum(is_key_mask);

if n_found == 0
    indices = [];
    type_id = [];
    groups  = cell(1,n_types_get);
    return
end

indices_of_entries_of_type_ca = myMap.values(types_to_get(is_key_mask));

if n_found == 1
   indices = indices_of_entries_of_type_ca{1};
   type_id = ones(1,length(indices));
   groups  = cell(1,n_types_get);
   groups{is_key_mask} = 1:length(indices);
   return
end

n_entries           = length(obj.line_numbers);
untruncated_type_id = zeros(1,n_entries);


cur_value_index = 0;
for iTypeGet = find(is_key_mask)
    
    %NOTE: The values are aligned only to those present
    %not to all requested values, thus we need to loop index variables
    cur_value_index = cur_value_index + 1;
    
    type_indices_in_original = indices_of_entries_of_type_ca{cur_value_index};
    untruncated_type_id(type_indices_in_original) = iTypeGet;
end

valid_indices_mask = untruncated_type_id ~= 0;
indices            = find(valid_indices_mask);
type_id            = untruncated_type_id(valid_indices_mask);

%NOTE: final_indices is only used at the places where the
%valid_indices_mask is true. Importantly though, the indexing
%order is the same as the original entries, so we can now go
%back and translate from indices that are relevant for all
%entries to indices that are relevant only for the truncated
%subset of entries. 
%
%The values of final_indices are only relevant for the
%truncated subset. Indexes into final_indices exist for all values, not
%just truncated values.
final_indices = cumsum(valid_indices_mask);

cur_value_index = 0;
groups = cell(1,n_types_get);
for iTypeGet = find(is_key_mask)
    cur_value_index = cur_value_index + 1;
    
    type_indices_in_original = indices_of_entries_of_type_ca{cur_value_index};
    groups{iTypeGet} = final_indices(type_indices_in_original);
end

end