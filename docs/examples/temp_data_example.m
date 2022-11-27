clf
d = sci.time_series.data.example(2);
plot(d)
d2 = d.subset.fromEpoch('pauses','un',0);
d3 = d.subset.fromEpoch('pauses','indices',2);
hold on
plot(d2{1},'color','r')
plot(d3,'color','k','linewidth',2);
d.plotEvent('starts');
hold off


d1 = sci.time_series.data.example(1);
d3 = sci.time_series.data.example(3);

objs = [d1 d3];

%Note this has to be done because of how dependent properties work :/
sr = objs.getSubsetRetriever();
sec1_2 = sr.fromStartAndStopTimes(1,2);

sec_multi = sr.fromStartAndStopTimes(-2:0,0:2,'un',0);
