function barFromObservations(ids,data,id_names,type_names)
%
%   sl.plot.type.barFromObservations(ids,data,type_names)
%   TODO: This needs TONS of work
%
%   Inputs:
%   -------
%   ids: [1 x n_samples] type???? numeric array or cellstr?
%       Identifies which id each sample belongs to
%   data: [n_samples x type]
%   

%1) ID (row or column)
%   - this can be a string or numeric
%2) observations
%       samples x type
%3) type names

needs_fixin_for_single = size(data,2) == 1;

if needs_fixin_for_single
    %Uh oh, Matlab can't handle this properly ...
   data = [data data];
   data(:,2) = 0;
end


%Call to stats functions
%- eventually this dependency should be removed
[data_mean,data_sem,n_per_group] = grpstats(data,ids,{'mean','sem','numel'});

%M-by-N matrix Y as M groups of N vertical bars. 


[hBar, hErrorbar] = sl.plot.type.barwitherr(data_sem', data_mean');    % Plot with errorbars

if needs_fixin_for_single
    type_names{end+1} = 'NULL';
end

set(gca,'XTickLabel',type_names)

if needs_fixin_for_single
   set(gca,'xlim',[0.5 1.5]); 
end

legend_strs = sl.cellstr.sprintf('%s : n=%d',id_names,n_per_group(:,1));

legend(legend_strs)




end
