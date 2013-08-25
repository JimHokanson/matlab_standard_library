function cps = crosspowerspectrum(in1,in2)
% USAGE : cps = crosspowerspectrum(in1,in2)
%
% function to calculate the PHASE-CORRELATION, hence function name may be a bit misleading!!
%
% Adam Wilmer, 3-9-02

F1 = fft2(in1);
F2 = fft2(in2);

% Create phase difference matrix
pdm = exp(i*(angle(F1)-angle(F2)));

% turn into cross phase-correlation
cps = real(ifft2(pdm));

% had problems with NaN's coming out so check this
if(mean(mean(isnan(cps)))>0.95)
    disp('PROBLEM ALERT: phasecorrelation contains a lot of NaNs (check FFTs exist as they cannot cope with certain inputs for some reason)')
    return
end