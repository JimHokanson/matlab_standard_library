function rounded_data = roundToPrecision(data,precision,fhandle)
%round2  Rounds number to nearest multiple of arbitrary precision.
%
%   rounded_data = sl.array.roundToPrecision(data,precision,*fhandle)
%   
%   Rounds data to the specified precision value.
%
%   Optional Inputs:
%   ----------------
%   fhandle : (default: @round) 
%              Function handle to use instead of round.
%              Recommended values are @floor, @ceil, @fix
%
%   Examples:
%   ---------
%   1) 
%   data = 0:0.1:1
%   rounded_data = sl.array.roundToPrecision(data,0.2)
%                 % 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
%   rounded_data => 0 0.2 0.2 0.4 0.4 0.6 0.6 0.6 0.8 1.0 1.0
%
%   2)
%   data = 0:0.1:1
%   rounded_data = sl.array.roundToPrecision(data,0.2,@floor)
%                 % 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
%   rounded_data => 0 0   0.2 0.2 0.4 0.4 0.4 0.6 0.8 0.8 1.0
%


if numel(precision) ~= 1
  error('n must be scalar')
end

if ~exist('fhandle','var')
   fhandle = @round; 
elseif ~isa(fhandle,'function_handle')
   error('Input fhandle must be a function handle')
end

rounded_data = fhandle(data./precision).*precision;
