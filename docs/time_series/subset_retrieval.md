# Data Subset Retrieval #

Subsets of the time series can be extracted using a variety of functions.

# Entry Points #

There are two entry points.

The first is to access the `subset` property, which contains all of the retrieval options. 

Unfortunately as a property we can't access all objects simultaneously. If we ever have multiple objects we need to use the method `getSubsetRetriever`

```
data = sci.time_series.data.example(2);

%1) subset property
%Getting all pause epochs
%'un',0 is needed, more on this later ...
pauses = data.subset.fromEpoch('pauses','un',0)

%2) via the subset retriever
sr = data.subset_retriever();
pauses = sr.fromEpoch('pauses','un',0);

``` 

In the above example, the second approach is not needed. It is needed with multiple objects.

```
d1 = sci.time_series.data.example(1);
d3 = sci.time_series.data.example(3);

objs = [d1 d3];

%This wouldn't work
%pauses = objs.subset.fromEpoch('pauses','un',0)

%This does
sr = objs.subset_retriever();
pauses = sr.fromEpoch('pauses','un',0);

```

# List of Methods #

- fromEpoch 
- fromEpochAndPct
- fromEpochAndSampleWindow
- fromEpochAndTimeWindow
- fromEventAndSampleDuration
- fromEventAndSampleWindow
- fromEventAndTimeDuration
- fromEventAndTimeWindow
- fromPercentSubset
- fromProcessor
- fromStartAndStopEvent
- fromStartAndStopSamples
- fromStartAndStopTimes
- fromStartSampleAndSampleDuration
- fromStartSampleAndTimeDuration
- fromStartTimesAndSampleDuration
- fromStartTimesAndTimeDuration
- intoNParts
- splitAtPercentages

