function boxPlotOptions()
%
%   sl.plot.demos.boxPlotOptions

%TODO: Show various examples of the box plot ...

scurr = rng;
rng(9)
r1 = randn(1,10);
r1(4) = 2;
r2 = 2.*randn(1,10) + 5;

r = [r1(:) r2(:)];

rng(scurr)

subplot(3,4,1)
boxplot(r);
title('Standard options')

subplot(3,4,2)
boxplot(r,'boxstyle','filled');
title('''boxstyle'',''filled''')

end