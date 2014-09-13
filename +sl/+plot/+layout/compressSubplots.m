function [h_axes, all_ax_pos] = compressSubplots
%PLOT_compressSubplots
%
%   [h_axes, all_ax_pos] = sl.ploy.layout.compressSubplots

chilluns = get(gcf,'Children');
all_ax_pos = [];
h_axes = [];
for iiChild = 1:length(chilluns)
    if strcmp(get(chilluns(iiChild),'type'),'axes')  ...
            && ~strcmp(get(chilluns(iiChild),'Tag'),'legend')
        h_axes = [h_axes chilluns(iiChild)];
        all_ax_pos = [all_ax_pos ;get(chilluns(iiChild),'Position')];
    end
end
N = length(h_axes);
if N > 1
    ax_pos = all_ax_pos(N,:);
    ax_pos = [1-ax_pos(3) ax_pos(2:4)];
    all_ax_pos(N,:) = ax_pos;
    extent = [get(h_axes(N),'Xlim') get(h_axes(N),'Ylim')];
    
    set(h_axes(N),'Position',[1-ax_pos(3) ax_pos(2:4)])
    set(h_axes(N),'ActivePositionProperty','Position')
    %   axis(extent)
    for iiAxis = (N-1):-1:1
        % push the subplots closer together
        last_ax_pos = ax_pos;
        ax_pos = all_ax_pos(iiAxis,:);
        ax_pos = [last_ax_pos(1)-ax_pos(3) ax_pos(2:4)];
        all_ax_pos(iiAxis,:) = ax_pos;
        set(h_axes(iiAxis),'Position',ax_pos)
        set(h_axes(N),'ActivePositionProperty','OuterPosition')
        %     axis(extent)
    end
end
end