function output = sprintf(format,varargin)
%sprintf_array  Each index of the input arrays is put into a sprintf command
%
%   output = sl.cellstr.sprintf(format,varargin)
%
%   varargin should be arrays or cell arrays of the same size
%   See examples below ...
%
%   EXAMPLES:
%   ====================================================
%   output = sl.cellstr.sprintf('%d-%d',1:4,2:5)
%   output => 
%       {'1-2'    '2-3'    '3-4'    '4-5'}
%
%
%   output = sl.cellstr.sprintf('%d-%s',1:4,{'a' 'b' 'c' 'd'})
%   output =>
%    '1-a'    '2-b'    '3-c'    '4-d'
%
%   IMPROVEMENTS:
%   =======================================================================
%   1) Allow singular inputs as well ...
%

len_all = cellfun('prodofsize',varargin);
if ~all(len_all == len_all(1))
    error('All variable inputs must have the same length')
end

nStrings = len_all(1);
%NOTE: I have at least one case that relies on this being true ...
%Not sure what happens if others differ ...
output = cell(size(varargin{1}));

nParams = length(varargin);
input_params  = cell(1,nParams);

for iStr = 1:nStrings
    for iParam = 1:nParams
       if iscell(varargin{iParam})
          %Assigning cell to cell
          input_params(iParam) = varargin{iParam}(iStr);
       else
          %Careful: notice assigning numeric to cell
          input_params{iParam} = varargin{iParam}(iStr);
       end
    end 
    output{iStr} = sprintf(format,input_params{:});
end
