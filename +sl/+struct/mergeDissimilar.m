function sc = mergeDissimilar(sa,sb)
%
%   sc = sl.struct.mergeDissimilar(sa,sb)
%
%   Allow the following:
%   
%       sc = [sa sb] 
%
%       where sa and sb don't have the same fields.
%
%
%
%   Improvements:
%   ----------------------------------------------------------
%   1) This could be expanded to multiple structures
%   2) Remove duplicate setdiff - I've been meaning to
%      make this a function for a while ...
%      This has been implemented as a hack using intersect for now ...
%
%   TODO: Make note of field order.

% in.null_option = [];
% in = sl.in.processVarargin(in,varargin);

EMPTY_OPTION = [];

if isempty(sa)
    sc = sb;
    return
elseif isempty(sb)
    sc = sa;
    return
end

fa = fieldnames(sa);
fb = fieldnames(sb);

[~,ia,ib] = intersect(fa,fb);

%Remove common, assign remaining to other
%----------------------------------------------------
fa(ia) = [];
fb(ib) = [];

for iField = 1:length(fa)
   [sb.(fa{iField})] = deal(EMPTY_OPTION); 
end

for iField = 1:length(fb)
   [sa.(fb{iField})] = deal(EMPTY_OPTION); 
end

sc = [sa sb];

end

function helper__examples()

a.a = 'cheese';
a.b = 1;
a.c = 2;

z.a = 'test';
z.x = 3;
z.y = 4;

sc = sl.struct.mergeDissimilar(a,z);

end