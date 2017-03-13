a = 1:10;
b = a+.01;

% tolerance test
[c,iiA] = mex_setdiff_tol(a,b,.005);
assert( isempty(setxor(c,a)),'Small tolerance test failure')

[c,iiA] = mex_setdiff_tol(a,b,.1);
assert( isempty(c),'Large tolerance test failure')

b       = a(2:end);
[c,iiA] = mex_setdiff_tol(a,b,.1);
assert( c == a(1),'Lower edge condition test failure')

b       = a(1:end-1);
[c,iiA] = mex_setdiff_tol(a,b,.1);
assert( c == a(end),'Upper edge condition test failure')

b       = a;
b(5:7)  = b(5:7)+100;
[c,iiA] = mex_setdiff_tol(a,b,.1);
assert( all(ismember(a(5:7),c)),'generic failure')

% =========================================================================

a       = [1 1 1 1 3 3 3 3 2 2 2 ];
b       = [1 3];
[c,iiA] = mex_setdiff_tol(a,b,.1);
[c,iiA] = setdiff_2011b(a,b);
assert( length(c) == 1 && c == 2,'repeated value failure')
assert( iiA == 11,'incorrect index returned');

% =========================================================================

a       = 1:10;
b       = a+.01;
[c,iiA] = mex_setdiff_tol(a,b,-.1,true);
assert(isempty(c),'negative one-sided evaluation failure');

[c,iiA] = mex_setdiff_tol(a,b,.1,true);
assert(isequal(a,c),'positive one-sided evaluation failure');
fprintf('test success\n')

% =========================================================================
% Speed

a = randi(10e3,[1 1e4]);
b = randi(10e3,[1 1e4]);

klock = tic;
setdiff(a,b);
toc(klock);

klock = tic;
mex_setdiff_tol(a,b,.1);
toc(klock)

