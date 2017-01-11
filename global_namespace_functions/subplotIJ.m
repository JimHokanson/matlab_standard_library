function h = subplotIJ(n_rows,n_cols,row_index,col_index)
%
%   h = subplotIJ(n_rows,n_cols,row_index,col_index)
%   
%   TODO: Document this function
    I = col_index + (row_index-1)*n_cols;
    
    h = subplot(n_rows,n_cols,I);

end