function s2 = getSubsetByNames(s,names_to_keep,varargin)
%x Moves elements from one structure to another
%
%   s2 = sl.struct.getSubsetByNames(s,names_to_keep)
%
%   Inputs
%   ------
%   names_to_keep : 
%
%   Outputs
%   -------
%   s2 : structure
%       The same size as 's', but with only the requsted 'names_to_keep'
%
%   Examples
%   --------
%   s = struct;
%   s.a = 1;
%   s.b = 2;
%   s.c = 3;
%   s(2).a = 4;
%   s(2).b = 5;
%   s(2).c = 6;
%   s2 = sl.struct.getSubsetByNames(s,{'a','b'})
%
%   s2 => 
%       1×2 struct array with fields:
% 
%         a
%         b

in.new_names = {};
in = sl.in.processVarargin(in,varargin);

if isempty(in.new_names)
    new_names = names_to_keep;
else
   if length(in.new_names) ~= length(names_to_keep)
       error('mismatch in length of names_to_keep and new_names')
   end
   new_names = in.new_names;
end


s2 = sl.struct.initialize(new_names,size(s));
for i = 1:length(names_to_keep)
    cur_name = names_to_keep{i};
    new_name = new_names{i};
    [s2.(new_name)] = deal(s.(cur_name));
end

end