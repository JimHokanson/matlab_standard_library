function togScreen()
%
%
%   togScreen()
%   
%   This can be helpful when a figure is on the wrong screen. It moves the
%   figure to the desired screen.

%Let's make it raised
h_fig = gcf;
raiseFig();

sz = get(0,'MonitorPosition');
left_positions = sz(:,1);
widths = sz(:,3);
right_positions = left_positions + widths;

left_positions = [-Inf; left_positions; right_positions(end)];
right_positions = [left_positions(2); right_positions; Inf];


cur_x_pos = h_fig.Position(1);

I = find(cur_x_pos >= left_positions & cur_x_pos < right_positions);

%   1       2             3            4      
%   Fake -- Monitor 1  -- Monitor 2 -- Fake
%
%   If at end, move to the 2nd index (Monitor 1)                                   

if I >= length(right_positions) - 1
    I = 2;
else
    I = I + 1;
end

h_fig.Position(1) = left_positions(I);

end