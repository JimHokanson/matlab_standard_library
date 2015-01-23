function [I_before,I_after] = ofEdgesBoundingData(data,edges)
%x For each value determines the index of the bound_value just before the value
%
%   For each data point, the indices of the edges that come before
%   and after that data point are returned.
%
%   TODO: Include documentation
%
%   sl.array.indices.ofEdgesBoundingData(values,bound_values);
%
%   Inputs:
%   -------
%   data :
%   edges :
%
%   Outputs:
%   --------
%   I_before :
%   I_after :
%
%
%   TODO: Handle non-bounded values


I_after = sl.array.indices.ofDataWithinEdges(edges,data);

%This gives us the first index of bound_values which comes after the
%corresponding value. To get just before, we have to go 1 less.

I_before = I_after - 1;

%In order to get just to the right we would add 1

end