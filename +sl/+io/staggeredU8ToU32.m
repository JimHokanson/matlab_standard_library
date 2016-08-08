function output = staggeredU8ToU32(u8_data,start_indices)
%
%
%   output = sl.io.staggeredU8ToU32(u8_data,start_indices)
%
%   *******
%   TODO: Move this to a typecasting library.
%
%   The goal of this function is to take data that is currently uint8 
%   and to grab uint32 data from that uint8 data but only
%   at specific indices.
%
%   In other words, you might want to grab bytes 1:4 as 1 uint32 value and
%   bytes 156,157,158, & 159 as another uint32 value. Rather than
%   typecasting everything to uint32, especially given potential alighment
%   issues, you would use this function as:
%
%       sl.io.staggeredU8ToU32(u8_data,[1 156])
%
%       NOTE: The other indices are not passed in, only the starts, because
%       from being uint32 we know we need 4 indices for each value.
%
%   This function is primarly concerned with speed and coding. By unrolling
%   a loop it speeds things up a bit. Once you understand the function it
%   also makes things look a little cleaner.
%
%
%
%   OUTPUTS
%   ----------------------------------------------------
%   output : [n x 1], uint32

if isempty(start_indices)
   output = zeros(0,1,'uint32');
   return
end

temp = zeros(length(start_indices),4,'uint8');
temp(:,1) = u8_data(start_indices);
temp(:,2) = u8_data(start_indices+1);
temp(:,3) = u8_data(start_indices+2);
temp(:,4) = u8_data(start_indices+3);
temp2 = temp';
output = typecast(temp2(:),'uint32');