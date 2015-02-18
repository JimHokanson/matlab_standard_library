function axes_handles = makeDimsEqual(figure_or_axes_handles,dims)
%
%
%   axes_handles = sl.plot.postp.makeDimsEqual(figure_or_axes_handles,dims)
%
%   INPUTS
%   -----------------------------------------------------------------------
%   figure_or_axes_handles : a set of either figure handles or axes handles
%   (should be entirely one or the other 
%
%   YIKES, THIS FUNCTION NEEDS TO BE UPDATED AND/OR POSSIBLY DELETED
%   
%

import sl.plot.info.*
%isFigureHandle
%getDataAxesFromFigureHandles

%Ensure axes handles
%--------------------------------------------------------
if all(isFigureHandle(figure_or_axes_handles))
    axes_handles = getDataAxesFromFigureHandles(figure_or_axes_handles);
else
    axes_handles = figure_or_axes_handles;
end

n_handles = length(axes_handles);

if n_handles < 2
   return 
end

%Dims
%--------------------------------------------------------
numeric_dims = sl.xyz.getNumericDim(dims);

n_dims = length(numeric_dims);

DIM_STRINGS = {'xlim' 'ylim' 'zlim'};

for iDim = 1:n_dims
    cur_dim = numeric_dims(iDim);
    cur_str = DIM_STRINGS{cur_dim};
    
    %Establish limits
    %----------------------------------------------------------------------
    for iHandle = 1:n_handles
       cur_handle_dim_limits = get(axes_handles(iHandle),cur_str);
       if iHandle == 1
           dim_limits = cur_handle_dim_limits;
       else
           dim_limits(1) = min(dim_limits(1),cur_handle_dim_limits(1));
           dim_limits(2) = max(dim_limits(2),cur_handle_dim_limits(2));
       end
    end
    
    %Enforce limits
    %----------------------------------------------------------------------
    set(axes_handles,cur_str,dim_limits)
end