function s2 = removeFieldsByIndices(s,indices)
%
%   
%   s2 = sl.struct.removeFieldsByIndices(s,indices)
%
%   Example
%   -------
%   s = struct;
%   s.a = 1;
%   s.b = 2;
%   s.c = 3;
%   s.d = 4;
%   s(2).a = 5;
%   s2 = sl.struct.removeFieldsByIndices(s,[1 3])
%
%     s2 =>
%       1×2 struct array with fields:
% 
%         a
%         c

%TODO: This doesn't support bad field names


%I'm not sure if this is the most efficienct approach. Presumably mex would
%be better

% get fieldnames of struct
f = fieldnames(s);

% set indices of fields to keep
idxkeep = 1:length(f);
idxremove = indices;
idxkeep(indices) = [];

% remove the specified fieldnames from the list of fieldnames.
f(idxremove,:) = [];

% convert struct to cell array
c = struct2cell(s);

% find size of cell array
sizeofarray = size(c);
newsizeofarray = sizeofarray;

% adjust size for fields to be removed
newsizeofarray(1) = sizeofarray(1) - length(idxremove);

% rebuild struct
s2 = cell2struct(reshape(c(idxkeep,:),newsizeofarray),f);

end