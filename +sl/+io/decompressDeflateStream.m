function varargout = decompressDeflateStream(varargin)
%
%   data_out = sl.io.decompressDeflateStream(uint8_data,n_bytes_out)
%
%   Inputs
%   ------
%   uint8_data
%       Data compressed using Deflate algorithm.
%   n_bytes_out
%       # of bytes to expect at the output.
%
%   Outputs
%   -------
%   data_out : [uint8]
%       Uncompressed data.
%
%   Improvements
%   ------------
%   1) Make the # of bytes out optional (LOW PRIORITY)
%   

error('Required C code not compiled')