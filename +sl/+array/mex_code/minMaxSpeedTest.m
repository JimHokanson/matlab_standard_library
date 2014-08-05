function wtf
% sl.array.wtf
r = rand(1000000,1);

s2 = 1;
e2 = 1;
s1 = 50000;
e1 = 200000;

N = 1000;

tic
for s1 = 1:N
temp = r(s1:e1,s2:e2);
[r2,i2] = min(temp,[],1);
[r3,i3] = max(temp,[],1);
end
toc;

tic
for s1 = 1:N
[r2,i2] = min(r(s1:e1,s2:e2),[],1);
[r3,i3] = max(r(s1:e1,s2:e2),[],1);
end
toc;


tic;
for s1 = 1:N
[a,b,c,d] = sl.array.minMaxOfDataSubset(r,[s1 e1],[s2 e2],1);
end
toc;