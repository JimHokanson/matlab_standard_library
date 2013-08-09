function output = typecastMatrix(data,format,keep_columns)
%
%
%   output = sl.io.typecastMatrix(data,format,keep_columns)
%
%   
%   keep_columns -> data spans rows
%   ~keep_columns -> data spans columns
%   
%   Improvements
%   -----------------------------------------------------------------------
%   1) Provide error processing when reshape fails

n_rows = size(data,1);
n_cols = size(data,2);

%TODO: Add try catch with details on error (thrown by reshape)
%This occurs when reshape size is wrong

if keep_columns
   temp_output = typecast(data(:),format);
   output      = reshape(temp_output,n_cols,length(temp_output)/n_cols)'; 
else
   temp_data   = data';
   temp_output = typecast(temp_data(:),format);
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