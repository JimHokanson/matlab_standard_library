function testmerge
% function testmerge
% test mergesa()

ntest = 10;
m = 1e6;
n = 1e6;
t = zeros(ntest,2);
ncols = 3;
for k = 1:ntest
    fprintf('test #%d/%d\n', k, ntest);
    a = sort(ceil(20*rand(m,ncols)));
    b = sort(ceil(20*rand(n,ncols)));
    
    tic;
    c1 = mergesa(a,b,'rows');
    t(k,1) = toc;
    
    tic;
    c2 = sortrows([a; b]);
    t(k,2) = toc;
    
    if ~isequal(c1,c2)
        keyboard
    end
end
tmedian = median(t);

figure
plot(t);
grid on
xlabel('test number');
ylabel('time [s]');
title(sprintf('size arrays = [%d,%d] and [%d,%d]', m, ncols, n, ncols));
legend(sprintf('mergesa =%g [s]', tmedian(1)),...
       sprintf('sort    =%g [s]', tmedian(2)), ...
       'Location', 'best');