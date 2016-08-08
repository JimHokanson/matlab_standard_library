function applyIDCTQuick

%{

n = size(b,1);
m = size(b,2);


precompute ...
ww = sqrt(2*n) * exp(1i*(0:n-1)*pi/(2*n)).';


  bb = b(1:n,:);

  ww(1) = ww(1)/sqrt(2);
  W = ww(:,ones(1,m));
  yy = W.*bb;

  % Compute x tilde using equation (5.93) in Jain
  y = ifft(yy);
  
  % Re-order elements of each column according to equations (5.93) and
  % (5.94) in Jain
  a = zeros(n,m);
  a(1:2:n,:) = y(1:n/2,:);
  a(2:2:n,:) = y(n:-1:n/2+1,:);




%}
