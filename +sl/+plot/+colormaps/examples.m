function examples()
% Demonstrate all the nifty colormaps available

cmaps = {'colormaps.lingray'
         'colormaps.rainbow'
         'colormaps.linhot'
         'colormaps.magenta'
         'colormaps.optimal'
         'colormaps.blue2cyan'
         'colormaps.blue2yellow'};

load flujet
for i = 1:numel(cmaps)
    figure;
    ax = gca;
    cmap = feval(cmaps{i});
    colormap(ax,cmap);
    imagesc(X,'Parent',ax)
    colorbar('Peer',ax);
    title(ax,cmaps{i});
end