function output = staggeredU8ToU64(u8_data,start_indices)
%
%
%   sl.io.staggeredU8ToU64


%Transpose ???

temp = zeros(length(start_indices),8,'uint8');
temp(:,1) = u8_data(start_indices);
temp(:,2) = u8_data(start_indices+1);
temp(:,3) = u8_data(start_indices+2);
temp(:,4) = u8_data(start_indices+3);
temp(:,5) = u8_data(start_indices+4);
temp(:,6) = u8_data(start_indices+5);
temp(:,7) = u8_data(start_indices+6);
temp(:,8) = u8_data(start_indices+7);
temp2 = temp';
output = typecast(temp2(:),'uint64');


% temp = zeros(8,length(start_indices),'uint8');
% temp(1,:) = u8_data(start_indices);
% temp(2,:) = u8_data(start_indices+1);
% temp(3,:) = u8_data(start_indices+2);
% temp(4,:) = u8_data(start_indices+3);
% temp(5,:) = u8_data(start_indices+4);
% temp(6,:) = u8_data(start_indices+5);
% temp(7,:) = u8_data(start_indices+6);
% temp(8,:) = u8_data(start_indices+7);
% 
% output = typecast(temp(:),'uint64');


% temp = zeros(8*length(start_indices),1,'uint8');
% temp(1:8:end) = u8_data(start_indices);
% temp(2:8:end) = u8_data(start_indices+1);
% temp(3:8:end) = u8_data(start_indices+2);
% temp(4:8:end) = u8_data(start_indices+3);
% temp(5:8:end) = u8_data(start_indices+4);
% temp(6:8:end) = u8_data(start_indices+5);
% temp(7:8:end) = u8_data(start_indices+6);
% temp(8:8:end) = u8_data(start_indices+7);
% 
% output = typecast(temp,'uint64');