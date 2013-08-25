function w=window1d(p,wtype,param)
% USAGE: w=window1d(p,wtype,param)
% return 1-dimensional window of type 'wtype'
%
% centred on (p/2)
% p = length of window
%
% TYPES are BARTLETT, BLACKMAN, BOXCAR, CHEBWIN, HAMMING, HANN and KAISER
%
% Adam Wilmer, October 2002

w = zeros(p);

switch lower(wtype)
case 'none'
    w = ones(p,1);   
case 'bartlett' 
    w = bartlett(p); 
    
case 'blackman'
    w = blackman(p);
    
case 'boxcar'   % same as 'none' really so don't really see the point in this one
    w = boxcar(p);
    
case 'chebwin'
    if (nargin==4)
        r = param;                  % this is the desired sidelobe attenuation in dB
    else
        r=100;
    end
    w = chebwin(p,r);          % Some 1D window
    
case 'hamming'
    w = hamming(p);          % Some 1D window
    
case 'hann'
    w = hann(p);          % Some 1D window
    
case 'kaiser'
    if (nargin==4)
        beta = param;                  % this is the Kaiser window beta parameter
    else
        beta=10;
    end
    w = kaiser(p,beta);          % Some 1D window
    
case 'triang'
    w = triang(p);          % Some 1D window

otherwise
    disp('Window choice is not recognised -- choose another...')
    help window1d;
    return;
end
