a = 1:10;
b = a+.01;

% toleranmaske test
[mask,idx] = mex_ismember_tol(a,b,.005);
assert( ~any(mask) && all(idx == 0),'Small tolerance test failure')

[mask,idx] = mex_ismember_tol(a,b,.1);
assert( all(mask) && isequal(idx,[1:10]),'Large tolerance test failure')

b            = a(2:end);
[mask,idx]   = mex_ismember_tol(a,b,.1);
[mask2,idx2] = ismember(a,b);
assert( isequal(mask,mask2) && isequal(idx,idx2),'Lower edge condition test failure')

b            = a(1:end-1);
[mask,idx]   = mex_ismember_tol(a,b,.1);
[mask2,idx2] = ismember(a,b);
assert(isequal(mask,mask2) && isequal(idx,idx2),'Upper edge condition test failure')

b            = a;
b(5:7)       = b(5:7)+100;
[mask,idx]   = mex_ismember_tol(a,b,.1);
[mask2,idx2] = ismember(a,b);
assert(isequal(mask,mask2) && isequal(idx,idx2),'generic algorithm failure')

% =========================================================================

a       = [1 1 1 1 3 3 3 3 2 2 2 ];
b       = [1 3];
[mask,idx] = mex_ismember_tol(a,b,.1);
[mask2,idx2] = ismember(a,b);
assert(isequal(mask,mask2) && isequal(idx,idx2),'repeated value failure')

% =========================================================================
a       = 1:10;
b       = a+.01;
[mask,idx] = mex_ismember_tol(a,b,-.1,true);
assert(all(mask) && isequal(idx,1:10),'negative one-sided evaluation failure');

[mask,idx] = mex_ismember_tol(a,b,.1,true);
assert(~any(mask) && all(idx == 0),'positive one-sided evaluation failure');

% =========================================================================
a = randi(10e3,[1 1e3]);
b = randi(10e3,[1 1e3]);

klock = tic;
setdiff(a,b);
toc(klock);

klock = tic;
mex_setdiff_tol(a,b,.1);
toc(klock)

