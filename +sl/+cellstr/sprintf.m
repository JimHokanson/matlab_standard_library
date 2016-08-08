function output = sprintf(format,varargin)
%sprintf_array  Each index of the input arrays is put into a sprintf command
%
%   output = sl.cellstr.sprintf(format,varargin)
%
%   varargin should be arrays or cell arrays of the same size OR singular
%   elements.
%
%   NOTE: Strings are automatically converted to singular cells. True
%   character arrays need to be converted to cells via num2cell.
%
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
%
%
mask = cellfun('isclass',varargin,'char');
if any(mask)
   I = find(mask);
   for iChar = 1:length(I)
      cur_index = I(iChar);
      varargin{cur_index} = varargin(cur_index); 
   end
end

len_all = cellfun('prodofsize',varargin);
if ~all(len_all == max(len_all) | len_all == 1)
    error('All variable inputs must have the same length')
end

n_strings = max(len_all);
%NOTE: I have at least one case that relies on this being true ...
%Not sure what happens if others differ ...
output = cell(size(varargin{1}));

n_params      = length(varargin);
input_params  = cell(1,n_params);

for iStr = 1:n_strings
    for iParam = 1:n_params
       if iscell(varargin{iParam})
          %Assigning cell to cell
          if len_all(iParam) == 1
              input_params(iParam) = varargin{iParam};
          else
              input_params(iParam) = varargin{iParam}(iStr);
          end
       else
          if len_all(iParam) == 1 
              input_params(iParam) = varargin(iParam);
          else
             %Careful: notice assigning numeric to cell
              input_params{iParam} = varargin{iParam}(iStr); 
          end
       end
    end 
    output{iStr} = sprintf(format,input_params{:});
end
