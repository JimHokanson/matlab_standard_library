function w=window2d(p,q,wtype,param)
% USAGE: w=window2d(p,q,wtype,param)
% return 2-dimensional hamming window
%
% centred on (p/2,q/2)
% (p,q) = dimensions of window
%
% (height,width) = dimensions of image to be applied to...
%
% TYPES are BARTLETT, BLACKMAN, BOXCAR, CHEBWIN, HAMMING, HANN and KAISER
%
% Adam Wilmer, October 2002

% disp('HAMMING2 : check that this is actually a proper 2-dimensional Hamming window...')

w = zeros(p,q);

switch lower(wtype)
case 'none'
    w = ones(p,q);
case 'bartlett' 
    wlp = bartlett(p);
    wlq = bartlett(q);
    w = wlp(:) * wlq(:).';   % Outer product  
    
case 'blackman'
    wlp = blackman(p);
    wlq = blackman(q);
    w = wlp(:) * wlq(:).';   % Outer product
    
case 'boxcar'
    wlp = boxcar(p);
    wlq = boxcar(q);
    w = wlp(:) * wlq(:).';   % Outer product
    
case 'chebwin'
    if (nargin==4)
        r = param;                  % this is the desired sidelobe attenuation in dB
    else
        r=100;
    end
    w1p = chebwin(p,r);          % Some 1D window
    w1q = chebwin(q,r);
    w = w1p(:) * w1q(:).';   % Outer product  
    
case 'hamming'
    w1p = hamming(p);          % Some 1D window
    w1q = hamming(q);
    w = w1p(:) * w1q(:).';   % Outer product
    
case 'hann'
    w1p = hann(p);          % Some 1D window
    w1q = hann(q);
    w = w1p(:) * w1q(:).';   % Outer product  
    
case 'kaiser'
    if (nargin==4)
        beta = param;                  % this is the desired sidelobe attenuation in dB
    else
        beta=10;
    end
    w1p = kaiser(p,beta);          % Some 1D window
    w1q = kaiser(q,beta);
    w = w1p(:) * w1q(:).';   % Outer product  
    
case 'triang'
    w1p = triang(p);          % Some 1D window
    w1q = triang(q);
    w = w1p(:) * w1q(:).';   % Outer product 
    
case('hann_rotational')     % use a rotationally symmetric type window
    if (p~=q)
        disp('cannot use rotational-type window for non-square images at present...')
    end
    p
    N = p;
    w=hann(N);
    M = (N-1) / 2;
    n = 2 / M * (-M:M);
    [x,y] = meshgrid(n);
    r = sqrt( x.^2 + y.^2 );
    w_2D = zeros(N);   
    size(n)
    size(w)
    size(r)

    w_2D(:) = interp1(n, w, r(:));
    w_2D(isnan(w_2D)) = 0;
    w = w_2D;
    
otherwise
    disp('Window choice (',wtype,')is not recognised -- choose another...')
    help window2d;
    return;
end

%figure,mesh(w),title(['The ',wtype,' window function.'])