function s3 = merge(s1,s2)
%
%   output = sl.struct.merge(s1,s2)
%
%   Note, s2 gets merged into s1
%
%   Example
%   -------
%   s1 = struct;
%   s1.a = 1;
%   
%   s2 = struct;
%   s2.b = 2;
%
%   s3 = sl.struct.merge(s1,s2);
%       struct with fields:
% 
%         a: 1
%         b: 2
%
%   %reverse order
%   s3 = sl.struct.merge(s2,s1);
%       struct with fields:
% 
%         b: 2
%         a: 1

s3 = s1;
fn = fieldnames(s2);
for i = 1:length(fn)
    cur_name = fn{i};
    s3.(cur_name) = s2.(cur_name);
end


end