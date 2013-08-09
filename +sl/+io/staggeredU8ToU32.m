function output = staggeredU8ToU32(u8_data,start_indices)
%
%
%   output = sl.io.staggeredU8ToU32(u8_data,start_indices)
%
%   OUTPUTS
%   ----------------------------------------------------
%   output : [n x 1], uint32

temp = zeros(length(start_indices),4,'uint8');
temp(:,1) = u8_data(start_indices);
temp(:,2) = u8_data(start_indices+1);
temp(:,3) = u8_data(start_indices+2);
temp(:,4) = u8_data(start_indices+3);
temp2 = temp';
output = typecast(temp2(:),'uint32');