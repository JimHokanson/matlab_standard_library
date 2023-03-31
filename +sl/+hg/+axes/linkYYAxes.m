function linkYYAxes(ax)
%
%
%   sl.hg.axes.linkYYAxes(ax)
%
%   TODO: Document ...


%See Also: https://undocumentedmatlab.com/articles/using-linkaxes-vs-linkprop


%This could change if we had more axes ...
n_axes = length(ax);
left_rulers = cell(1,n_axes);
right_rulers = cell(1,n_axes);
%2 elements is for y-range [min, max]
y_left_limits = zeros(n_axes,2);
y_right_limits = zeros(n_axes,2);

for i = 1:n_axes
    left_rulers{i} = ax(i).YAxis(1);
    right_rulers{i} = ax(i).YAxis(2);
    y_left_limits(i,:) = ax(i).YAxis(1).Limits;
    y_right_limits(i,:) = ax(i).YAxis(2).Limits;
end

%Need to manually adjust so they encompass
%total range, otherwise value is just copied
%from one to the other

left_rulers = [left_rulers{:}];
right_rulers = [right_rulers{:}];

%Update current limits so that entire span of data which is
%currently visible is shown after linking
%
%otherwise you just get copying of one property to the other
%which might reduce the visible range
min_left = min(y_left_limits(:,1));
max_left = max(y_left_limits(:,2));
y_lim_left = [min_left max_left];

min_right = min(y_right_limits(:,1));
max_right = max(y_right_limits(:,2));
y_lim_right = [min_right max_right];

for i = 1:n_axes
    ax(i).YAxis(1).Limits = y_lim_left;
    ax(i).YAxis(2).Limits = y_lim_right;
end

%be sure to assign to a variable otherwise
%making the second linkprop call invalidates the first ...
hlink1 = linkprop(left_rulers,'Limits');
hlink2 = linkprop(right_rulers,'Limits');

setappdata(ax(1),'YLim_Listen_Left',hlink1);
setappdata(ax(1),'YLim_Listen_Right',hlink2);


end