function output = joinStringPairs(pair1,pair2,delimiter)
%joinStringPairs
%
%   output = sl.cellstr.joinStringPairs(pair1,pair2,delimiter)
%
%   Inputs
%   ------
%   pair 1:
%   pair 2: "  "
%
%   EXAMPLE
%   -------
%   left = {'last1' 'last2'};
%   right = {'first1' 'first2'};
%   output = sl.cellstr.joinStringPairs(left,right,', ');
%   %=> {'last1, first1'}    {'last2, first2'}

%This ran at about 1/2 speed compared to the loop in 2013a
%output = cellfun(@(x,y) [x delimiter y],pair1,pair2,'un',0);

nPairs = length(pair1);
output = cell(size(pair1));
for iPair = 1:nPairs
    output{iPair} = [pair1{iPair} delimiter pair2{iPair}];
end

end

function helper__examples()



end