function output = getSHA1(data)
%getSHA1 Creates message digest using SHA-1 hash function
%
%   output = sl.crypt.getSHA1(data)
%
%   Example:
%   ----------------------------------
%   data = sl.io.fileRead(file_path,'*uint8');
%
%   See Also:
%   sl.io.fileread

%data = 'The quick brown fox jumps over the lazy dog';
digest = org.apache.commons.codec.digest.DigestUtils;
temp   = lower(dec2hex(typecast(digest.sha(data),'uint8')))';
output = temp(:)';

end