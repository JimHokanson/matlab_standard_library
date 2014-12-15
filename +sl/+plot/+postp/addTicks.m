function addTicks(axes_h,axis,tick_values,tick_labels,varargin)
%
%   sl.plot.postp.addTicks(axes_h,axis,tick_values,tick_labels)
%
%   Inputs:
%   -------
%   axes_h : handle
%   axis : {'x','y','z'}
%   tick_values : numeric array
%   tick_labels : cellstr

%TODO: Eventually make this dynamic via:
%http://undocumentedmatlab.com/blog/setting-axes-tick-labels-format
%
%   NOTE: I think that the linked code might not work if the plot is cleared
%   - Ideally we want the ticks to clear as well (I think) - how would we
%   detect that the things we care about have been cleared so that we
%   should remove the listener????
%
%
%   ??? - What do about overlaps???? - merge strings ?????
%   ??? - What about using a mask with the right hand side?????
    
% % % in.too_close = []; %NYI: Idea is to remove the old number if
% % % %the new number is too close
% % % in = sl.in.processVarargin(in,varargin);

in.clear_old_ticks = false;
in = sl.in.processVarargin(in,varargin);

if nargin < 4
    error('Too few inputs')
end

ticks_str  = [axis 'Tick'];
labels_str = [axis 'TickLabel'];

if in.clear_old_ticks
    cur_ticks = [];
    cur_labels = {};
else
    cur_ticks  = get(axes_h,ticks_str);
    cur_labels = get(axes_h,labels_str);
end

merged_ticks  = [cur_ticks(:); tick_values(:)];
merged_labels = [cur_labels(:); tick_labels(:)];

[s_merged_ticks,I] = sort(merged_ticks);

s_merged_labels = merged_labels(I);

%For right now, we'll remove the numbers on the axis, this should
%eventually be changed ...

delete_mask = s_merged_ticks(1:end-1) == s_merged_ticks(2:end);

s_merged_ticks(delete_mask)  = [];
s_merged_labels(delete_mask) = [];

set(axes_h,ticks_str,s_merged_ticks,labels_str,s_merged_labels);


end