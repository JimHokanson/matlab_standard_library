function result = theilSen(data)
%
%   result = sci.time_series.calculators.regression.theilSen(data)
%
%   Outputs
%   -------
%   result = sci.time_series.calculators.regression.theil_sen_result

%TODO: This might be better in some generic regression package
%with a wrapper here for time series

%http://scikit-learn.org/stable/modules/generated/sklearn.linear_model.TheilSenRegressor.html#sklearn.linear_model.TheilSenRegressor
%http://scikit-learn.org/stable/auto_examples/linear_model/plot_theilsen.html
%https://github.com/scikit-learn/scikit-learn/blob/14031f65d144e3966113d3daec836e443c6d7a5b/sklearn/linear_model/theil_sen.py

[d,t] = data.getRawDataAndTime();

% [d,t] = data.getRawDataAndTime();

if data.n_channels ~= 1
   error('Code written assuming a single channel') 
end

%Assuming no NaNs ...
if any(isnan(d))
    error('NaN detected, assumption violated')
end

n_samples = data.n_samples;

%Sampling
%---------------------
if n_samples <= 2000
    m = h__bruteForce(d,t);
else
    m_all = zeros(1,10);
    n_samples_use = 1000;
    for iM = 1:10
       m_all(iM) = h__median_from_sampling(n_samples_use,d,t); 
    end
    m = mean(m_all);
end


    b = median(d-m*t); 
    
    result = sci.time_series.calculators.regression.theil_sen_result;
    result.slope = m;
    result.intercept = b;
    result.training_data = copy(data);

end

function m = h__bruteForce(d,t)
n_samples = length(d);
C = NaN(n_samples,n_samples);
for i=1:n_samples
    C(i,1:(i-1)) = (d(i)-d(1:(i-1)))./(t(i) - t(1:(i-1)));
end
m = nanmedian(C(:));                       % calculate slope estimate
end

function m = h__median_from_sampling(n,d,t)
n_samples = length(d);
I = randi(n_samples,n,2);

%We might be able to make this step a bit quicker ...
I(I(:,1)==I(:,2),:) = [];
I = sort(I,2);
m = median( (d(I(:,2))-d(I(:,1))) ./ (t(I(:,2)) - t(I(:,1))));

end

function [m, b] = TheilSen(data)
% Performs Theil-Sen robust linear regression on data
%
% [m b] = TheilSen(data)
%
% data: a matrix with rows of observations and 1st column of predictor
%   variables and 2nd column of response variabls, data = [x, y]
% m: estimated slope
% b: estimated offset
%
%
% Source:
%   Gilbert, Richard O. (1987), "6.5 Sen's Nonparametric Estimator of
%   Slope", Statistical Methods for Environmental Pollution Monitoring,
%   John Wiley and Sons, pp. 217–219, ISBN 978-0-471-28878-7
%
%
% %%% Z. Danziger October 2014 %%%
%
%

sz = size(data);
if ~any(sz==2) || length(sz)>2
    error('Expecting data to be a n-by-2 dimensional data matrix')
elseif sz(2)~=2
    data = data';
    sz = fliplr(sz);
end

C = ones(sz(1),sz(1))*nan;
for i=1:sz(1)
    C(i,:) = (data(i,2)-data(:,2))./(data(i,1)-data(:,1));
end
m = nanmedian(C(:));                        % calculate slope estimate

if nargout==2
    b = median(data(:,2)-m*data(:,1));      % calculate intercept if requested
end

end