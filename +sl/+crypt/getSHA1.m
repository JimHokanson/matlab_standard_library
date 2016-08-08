function output = getSHA1(data_or_file_path,varargin)
%getSHA1 Creates message digest using SHA-1 hash function
%
%   output = sl.crypt.getSHA1(data_or_file_path)
%
%   Example:
%   ----------------------------------
%   data_or_file_path : 
%       - uint8 of data in file
%       - path to file (NOTE: This may be a Java file (java.io.File)
%
%   See Also:
%   sl.io.fileRead

in.is_file = false; %If true, data should be a file_path
in = sl.in.processVarargin(in,varargin);

if in.is_file
   data = sl.io.fileRead(data_or_file_path,'*uint8');
else
   data = data_or_file_path;
   %TODO: Test is uint8
end

%data = 'The quick brown fox jumps over the lazy dog';
digest = org.apache.commons.codec.digest.DigestUtils;
temp   = lower(dec2hex(typecast(digest.sha(data),'uint8')))';
output = temp(:)';

end