function result = theilSen(data)
%
%   result = sci.time_series.calculators.regression.theilSen(data)

%http://scikit-learn.org/stable/modules/generated/sklearn.linear_model.TheilSenRegressor.html#sklearn.linear_model.TheilSenRegressor
%http://scikit-learn.org/stable/auto_examples/linear_model/plot_theilsen.html
%https://github.com/scikit-learn/scikit-learn/blob/14031f65d144e3966113d3daec836e443c6d7a5b/sklearn/linear_model/theil_sen.py

keyboard

%Note, we assume time is constant ...
d = data.getRawDataAndTime();

if data.n_channels ~= 1
   error('Code written assuming a single channel') 
end

%Assuming no NaNs ...
if any(isnan(d))
    error('NaN detected, assumption violated')
end

%For right now we'll do brute force, this gets messy fast
n_slopes = nchoosek(6588,2);
n_samples = data.n_samples;
first_slope = d(2)-d(1);

%randperm(n) => 

%Brute force ...
%----------------------


dx = 1:n_samples;
dx = (1./dx)';
C = NaN(n_samples,n_samples);
tic
for i=1:n_samples
    n_samples_keep = n_samples - i;
    C(i,(i+1):end) = (d(i)-d((i+1):end)).*dx(1:n_samples_keep);
end
m = nanmedian(C(:));                       % calculate slope estimate
toc


keyboard
tic; wtf1 = randi(n_samples,1e5,2); toc;
tic; wtf2 = randi(n_samples,1e6,2); toc;
tic; wtf3 = randi(n_samples,1e7,2); toc;

wtf1(wtf1(:,1)==wtf1(:,2),:) = [];
wtf1 = sort(wtf1,2);
wtf2(wtf2(:,1)==wtf2(:,2),:) = [];
wtf2 = sort(wtf2,2);
wtf3(wtf3(:,1)==wtf3(:,2),:) = [];
wtf3 = sort(wtf3,2);

median(d(wtf1(:,1))-d(wtf1(:,2)).*dx(wtf1(:,2)-wtf1(:,1)))
median(d(wtf2(:,1))-d(wtf2(:,2)).*dx(wtf2(:,2)-wtf2(:,1)))
median(d(wtf3(:,1))-d(wtf3(:,2)).*dx(wtf3(:,2)-wtf3(:,1)))

keyboard
end