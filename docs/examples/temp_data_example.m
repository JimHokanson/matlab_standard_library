clf
d = sci.time_series.data.example(2);
plot(d)
d2 = d.subset.fromEpoch('pauses','un',0);
hold on
plot(d2{1},'color','r')
d.plotEvent('starts');
hold off


