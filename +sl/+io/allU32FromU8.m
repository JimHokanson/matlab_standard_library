function u32_data = allU32FromU8(u8_data)
%allU32FromU8  Computes all possible uint32 typecasts of uint8 data
%
%   u32_data = sl.io.allU32FromU8(u8_data)
%
%   This creates all possible u32 values from u8 data. This function
%   trades memory for performance. It can be used to avoid indexing and
%   typecasting calls at the expense of holding 4x as much data.
%
%   Example of this is different from normal typecasting
%   -----------------------------------------------------------------------
%   For example, instead of:
%   typecast(u8_data(1:4),'uint32')
%   typecast(u8_data(6:9),'uint32')
%
%   we can do: 
%   u32_data(1)
%   u32_data(6)
%
%   Importantly, this is not typecast(u8_data,'uint32') as this assumes
%   things are byte aligned, which in the above example things are not.
%   
%   a a a a b c c c c <- uint8 bytes
%   a and c bytes for the uint32's
%
%   Indexing of multiple values:
%   -----------------------------------------------------------------------
%   Normally, it is an error to index multiple values from the output.
%
%   u32_data(1:9) doesn't make much sense
%
%   To get multiple values you should step by 4
%   u32_data(1:4:9)
%
%   NOTE: This is equivalent to:
%   typecast(u8_data(1:12),'uint32')
%
%   This function is generally meant to optimize repetitive single indexing
%   calls where the alignment of each element is not known ahead of time

n_1 = floor(0.25*length(u8_data));
n_2 = floor(0.25*(length(u8_data)-1));
n_3 = floor(0.25*(length(u8_data)-2));
n_4 = floor(0.25*(length(u8_data)-3));

u32_data = zeros(4,n_1);

u32_data(1,1:n_1) = double(typecast(u8_data(1:4*n_1),'uint32'));
u32_data(2,1:n_2) = double(typecast(u8_data(2:(4*n_2+1)),'uint32'));
u32_data(3,1:n_3) = double(typecast(u8_data(3:(4*n_3+2)),'uint32'));
u32_data(4,1:n_4) = double(typecast(u8_data(4:(4*n_4+3)),'uint32'));