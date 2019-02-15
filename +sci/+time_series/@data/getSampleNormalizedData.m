function raw_data = getSampleNormalizedData(obj,n_samples)
%
%
%   raw_data = getSampleNormalizedData(obj,n_samples)
%
%   This function samples the data such that it occupies the specified # of
%   samples. For example you can use this to have all waveforms take up 100
%   samples regardless of whether they were originally 50 or 500 samples.
%

%This could be removed quite easily ...
if obj.n_channels > 1
    error('Unsupported case')
end

%? What if we have less samples than we want????

raw_data = interp1(obj.d,linspace(1,obj.n_samples,n_samples));



end