function obj = fromFigure(fig_handle,varargin)
%x Construct object from figure handle
%
%   sp = sl.plot.subplotter.fromFigure(fig_handle,varargin)
%
%   Attempts to create object from figure handle. Requires
%   trying to get subplot shape (unless shape is specified)
%
%   Optional Inputs
%   ---------------
%   shape : 2 element vector [n_rows, n_columns]
%   may_be_single : default false
%       If true, we may only have a single plot and not
%       really a subplot ...
%           Apparently this may not be needed ....
%
%   Improvements
%   ------------
%   1) Support partial subplots

%Changed the calling form from:
%1) fig_handle, *shape
%to
%2) fig_handle, varargin
if nargin == 2
    add_shape = true;
    temp_shape = varargin{1};
    varargin(1) = [];
else
    add_shape = false;
end

in.shape = [];
in.may_be_single = false;
in = sl.in.processVarargin(in,varargin);

if add_shape
    in.shape = temp_shape;
end

if ~isvalid(fig_handle)
    error('Invalid figure handle, figure likely closed')
end

try
    %Push this to getSubplotAxesHandles??
    if ~isempty(in.shape)
        handles = findobj(gcf,'Type','axes');
        %Not sure handles is ever defined with respect to order
        %
        %   Really want to do by:
        %   [1   3
        %
        %    2   4]
        %
        %   Might have something like this spatially
        %   1
        %        3
        %   2     4
        %
        
        %I guess per shape we could divide into quadrants and
        %get closest???
        
        %I guess what we want is:
        %1) every row higher than previous rows
        %2) every column further left next column
        %
        %   Can we assume no mixing of tops (YES) - big savings
        %
        %   e.g., nothing from row 2 can be higher than row 1
        %
        %So verification is easy ...
        %
        %But we can't brute force the permutations
        
        keyboard
        
        error('Not yet implemented properly')
        
        %keyboard
        
        grid_handles = reshape(flip(handles),in.shape(1),in.shape(2));
    else
        %TODO: This sometimes fails but we should fail
        %internally
        temp = sl.hg.figure.getSubplotAxesHandles(fig_handle);
        grid_handles = temp.grid_handles;
    end
    sz = size(grid_handles);
catch ME
    %I saw this for a figure that was empty ...
    %Also a partial figure ...
    %
    %Also
    if in.may_be_single
        error('Case not yet handled')
        keyboard
    else
        rethrow(ME)
    end
end

obj = sl.plot.subplotter(sz(1),sz(2),'clf',false);
obj.handles = num2cell(grid_handles);
obj.h_fig = fig_handle;
end

function h__fromShape()

end