function H = hipass_filter(ht,wd)
% hi-pass filter function
% ...designed for use with Fourier-Mellin stuff
res_ht = 1/(ht-1);
res_wd = 1/(wd-1);

eta = cos(pi*(-0.5:res_ht:0.5));
neta = cos(pi*(-0.5:res_wd:0.5));
X = eta'*neta;

H=(1.0-X).*(2.0-X);
%figure,mesh(H),title('The high-pass filter')