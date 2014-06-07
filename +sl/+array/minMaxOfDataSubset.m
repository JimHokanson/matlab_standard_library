%function minMaxOfDataSubset()
%
%
%   minMaxOfDataSubset(data,[start1 stop1],[start2 stop2],dim_1_or_2)
%


%end


%{

cd(fullfile(fileparts(which('sl.array.minMaxOfDataSubset')),'mex_code'))

mex minMaxOfDataSubset.cpp


%}

function h__testCode()

r = rand(1000000,1);

s2 = 1;
e2 = 1;
s1 = 50000;
e1 = 200000;


tic
for i = 1:100
temp = r(s1:e1,s2:e2);
[r2,i2] = min(temp,[],1);
[r3,i3] = max(temp,[],1);
end
toc;

tic
for i = 1:100
[r2,i2] = min(r(s1:e1,s2:e2),[],1);
[r3,i3] = max(r(s1:e1,s2:e2),[],1);
end
toc;


tic;
for i = 1:100
[a,b,c,d] = sl.array.minMaxOfDataSubset(r,[s1 e1],[s2 e2],1);
end
toc;

end