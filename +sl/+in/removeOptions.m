function [removed_options,remaining_options] = removeOptions(varargin_data,names_to_remove)
%
%   [removed_options,remaining_options] = sl.in.removeOptions(varargin_data,names_to_remove)
%
%   

%TODO: This needs to handle structures

if ~iscell(varargin_data)
    error('Only cell input handled yet')
end
removed_options = {};
remaining_options = varargin_data;

for iName = 1:length(names_to_remove)
    cur_name = names_to_remove{iName};
    I = find(strcmp(cur_name,remaining_options(1:2:end)),1);
    if ~isempty(I)
       I2 = 2*I;
       I1 = I2 - 1;
       removed_options{end+1} = cur_name; %#ok<AGROW>
       removed_options(end+1) = remaining_options(I2); %#ok<AGROW>
       remaining_options([I1 I2]) = [];
    end
end


end