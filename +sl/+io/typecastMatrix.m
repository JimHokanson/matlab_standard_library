function output = typecastMatrix(data,output_format,keep_columns)
%x Converts a matrix to an array with appropriate typecasting
%
%   output = sl.io.typecastMatrix(data,format,keep_columns)
%
%   Inputs
%   ------
%   data : matrix
%   output_format : 
%   keep_columns :
%       - true - an element spans rows
%       - false - an element spans columns
%       Put another way if the data spans rows, then the # of columns
%       will be the same for the input and the output (thus the name
%       'keep_columns')
%
%   Examples
%   --------
%   data = uint8([1 3 0 0; 
%                 2 4 0 0]);
%   output = sl.io.typecastMatrix(data,'uint32',false)
%   %output => [769; 1026];
%
%   output = sl.io.typecastMatrix(data,'uint16',true)
%   %output => [513 1027 0 0];
%   
%   Improvements
%   -----------------------------------------------------------------------
%   1) Provide error processing when reshape fails

if isempty(data)
   output = [];
   return
end

n_rows = size(data,1);
n_cols = size(data,2);

%TODO: Add try catch with details on error (thrown by reshape)
%This occurs when reshape size is wrong
%
%I've also passed a cell array in ...

if keep_columns
   temp_output = typecast(data(:),output_format);
   output      = reshape(temp_output,n_cols,length(temp_output)/n_cols)'; 
else
   temp_data   = data';
   temp_output = typecast(temp_data(:),output_format);
   output      = reshape(temp_output,length(temp_output)/n_rows,n_rows)'; 
end



end

% function helper__examples()
% 
%   Test should make sure that for multiple values per row
%   or column (after typcasting, that order is maintained, this
%   is what switching inputs in the reshape and then transposing
%   at the end should do
%
% end