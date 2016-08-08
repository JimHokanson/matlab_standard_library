n = 8;
m = 8;
ww = sqrt(2*n) * exp(1i*(0:n-1)*pi/(2*n)).';
ww(1) = ww(1)/sqrt(2);
W = ww(:,ones(1,m));

data = 255*ones(8,8,'uint8');
b = dct(data);

N = 1000;

tic
for i = 1:N
a = applyIDCTQuick(b,W,n,m);
end
toc

tic
for i = 1:N
y = idct(b);
end
toc