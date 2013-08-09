function output = joinStringPairs(pair1,pair2,delimiter)

%This ran at about 1/2 speed compared to the loop in 2013a
%output = cellfun(@(x,y) [x delimiter y],pair1,pair2,'un',0);

nPairs = length(pair1);
output = cell(1,nPairs);
for iPair = 1:nPairs
    output{iPair} = [pair1{iPair} delimiter pair2{iPair}];
end

end