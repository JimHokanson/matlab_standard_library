function rounded_data = roundToPrecision(data,precision,fhandle)
%round2  Rounds number to nearest multiple of arbitrary precision.
%
%   rounded_data = sl.array.roundToPrecision(data,precision,*fhandle)
%   
%   Rounds data to the specified precision value.
%
%   OPTIONAL INPUTS
%   =======================================================================
%   fhandle : (default: @round) Function handle to use instead of round.
%             Recommended values are @floor, @ceil, @fix
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Provide examples ...

if numel(precision) ~= 1
  error('n must be scalar')
end

if ~exist('fhandle','var')
   fhandle = @round; 
elseif ~isa(fhandle,'function_handle')
   error('Input fhandle must be a function handle')
end

rounded_data = fhandle(data./precision).*precision;
