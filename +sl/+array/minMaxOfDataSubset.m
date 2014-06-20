function minMaxOfDataSubset(varargin)
%
%
%   minMaxOfDataSubset(data,start1,stop1,start2,stop2,dim_1_or_2)
%
%   TODO: Provide error checking here, rename mex   


error('Mex not compiled')

end


%{

cd(fullfile(fileparts(which('sl.array.minMaxOfDataSubset')),'mex_code'))

mex minMaxOfDataSubset.cpp


%}

function h__testCode()

r = rand(1000000,5);

s2 = 1;
e2 = 3;
s1 = [5000 10000 15000 20000];
e1 = s1+4999;

N = 1000;

% tic
% for s1 = 1:N
% temp = r(s1:e1,s2:e2);
% [r2,i2] = min(r,[],1);
% [r3,i3] = max(temp,[],1);
% end
% toc;

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
[a,b,c,d] = minMaxOfDataSubset(r,s1,e1,s2,e2,1);
end
toc;

end