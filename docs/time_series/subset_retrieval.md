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

# Multiple times or objects #

When multiple times or objects are requested, the returned value is not a single object. The general format is:

```
{subsets_for_input_1, subsets_for_input_2, subsets_for_input_3, etc.}
```

In other words, you get a cell array back, where each cell in the cell array matches an index in the original object array.

For any input object where you request multiple times, even a scalar input object, these will be returned as an array in the respective cell.

Some examples:

Consider two "channels" where you want 3 subsets from each. The returned value will be:

```
{chan1_subsets[1x3] chan2_subsets[1x3])
```

Now consider the case with a scalar (single element) input object, with n events/subsets requested.

If n=1, then you will simply get another object as the output:

```
subset_object
```

If however n is larger than 1, then you will get a cell array:

```
{subsets[1 x n]}
```

**Note** - As I typed this up I realized that multiple times for a single object should probably just return an array of objects. I may change this behavior at some point in the near future.


## 'UniformOutput', false

Thus the type of output will vary depending on the number of subsets.

To get around this output type variation, you are required to specify that you expect more than one subset back. This follows MATLAB's `cellfun` notation where you need to specify that the output will not be uniform, and thus requires a cell array.

```
x = {1 2 3 4} %cell array with one element
x2 = {[1 2 3 4],[3 4 5 6 7]} %cell array with 2 elements (2 numerical arrays)
r1 = cellfun(@(y) y > 2,x); %this is ok
r2 = cellfun(@(y) y > 2,x2); %this is NOT ok
```
If we run the above code, the line with `r2` will fail because the output is not the same for each element of the cell array. To fix that line we need to add on `'UniformOutput',false`

```
r2 = cellfun(@(y) y > 2,x2,'UniformOutput',false);
```

Importantly, we can do this with the `r1` line as well, just in case our input happens to have multiple elements. This is considered the correct way of doing things if we ever expect more than one event. 
```
%just in case `x` has more than one element
r1 = cellfun(@(y) y > 2,x,'UniformOutput',false);
```

If we know we will always have one event, or if more than one event is an error and unexpected, it would be better to not set `UniformOutput` to `false`

