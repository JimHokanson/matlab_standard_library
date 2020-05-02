function examples()
%
%   sl.plot.colormaps.examples
%
% Demonstrate all the nifty colormaps available

cmaps = {'sl.plot.colormaps.lingray'
         'sl.plot.colormaps.rainbow'
         'sl.plot.colormaps.linhot'
         'sl.plot.colormaps.magenta'
         'sl.plot.colormaps.optimal'
         'sl.plot.colormaps.blue2cyan'
         'sl.plot.colormaps.blue2yellow'};

%load flujet
h = load('flujet');
for i = 1:numel(cmaps)
    figure;
    ax = gca;
    cmap = feval(cmaps{i});
    imagesc(h.X,'Parent',ax)
    colormap(ax,cmap);
    colorbar('Peer',ax);
    title(ax,cmaps{i});
end