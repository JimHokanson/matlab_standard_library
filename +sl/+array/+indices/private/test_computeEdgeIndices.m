% test_computeEdgeIndices

if ~exist('ts','var')
    filename = fullfile(MATLAB_SVN_ROOT,'spikeHandling','private','spikes.mat');
    load(filename);
    
    sigma  = kw/pi;
    T1 = t1 - 5.0*sigma;
    T2 = t1 + 5.0*sigma;
    
    Niter = 20;
end
% test handling of empty events array
[I1old,I2old] = computeEdgeIndices([], T1, T2);
[I1mex,I2mex] = mex_computeEdgeIndices([],T1,T2);

if any(any([I1old(:) I2old(:)]-[I1mex(:) I2mex(:)]))
   fprintf(2,'WARNING: RESULTS DID NOT MATCH\n') 
end
clear I1* I2*

% speed test
tic
for ii = 1:Niter
    [I1old,I2old] = computeEdgeIndices(ts, T1, T2);
end
a = toc;

tic
for ii = 1:Niter
    [I1mex,I2mex] = mex_computeEdgeIndices(ts,T1,T2);
end
b = toc;

if any(any([I1old(:) I2old(:)]-[I1mex(:) I2mex(:)]))
   fprintf(2,'WARNING: RESULTS DID NOT MATCH\n') 
end
fprintf('%g x faster\n',a/b);