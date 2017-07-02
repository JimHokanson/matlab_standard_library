function value = getBitNumber(input,start,stop)
%x
%   value = sl.io.tc.getBitNumber(input,start,stop)
%
%   

%{
value = sl.io.tc.getBitNumber(uint8(156),3,5)

%}

%This would be better as mex
bit_mask = zeros(1,1,'like',input);
for i = start:stop
    bit_mask = bitset(bit_mask,i);
end

temp = bitand(input,bit_mask);

if start > 1
    value = bitshift(temp,-(start-1));
else
    value = temp;
end



end