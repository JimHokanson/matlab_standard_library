function varargout = verticalLines(x_positions,local_options,line_options)
%
%   line_handles = sl.plot.type.verticalLines(y_positions,local_options,line_options)
%
%   JAH TODO: Update documenation
%
%   Check this out: http://www.mathworks.com/matlabcentral/fileexchange/1039-hline-and-vline
%
%   Local Options:
%   --------------
%   y_values: [n 2] numeric array
%       Column 1: y starts
%       Column 2: y stops
%   y_pct : [n 2] numeric array
%       For when the values are meant to specified in terms of the viewing
%       limits. 
%       NOT YET IMPLEMENTED: 

if nargin == 2
    line_options = {};
end

in.y_pct_vary_with_zoom = false; %NYI - on zoom, change values
in.x_pct_vary_with_zoom = false; %NYI - on zoom, change values
in.x_as_pct = false; %NYI
in.y_values = [];
in.y_pct = [];
in = sl.in.processVarargin(in,local_options);

%NOTE: We need to know the y limit of the parents

n_lines = max([length(x_positions) size(in.y_values,1) size(in.y_pct,1)]);

if n_lines > x_positions
    if length(x_positions) == 1
        %scaler passed in, replicated based on x specification
        x_positions = repmat(x_positions,[n_lines 1]);
    else
        error('WTFasdfasdfasdf: TODO: Make me clearer')
    end
end

xs = [x_positions(:) x_positions(:)];

%TODO: This needs to be fixed
ys = in.y_values;

if isempty(in.y_values) && isempty(in.y_pct)
   %TODO : Eventually we need to respect a parent intput in line_options
   ys = get(gca,'ylim');
end

if size(ys,1) < n_lines
   ys = repmat(ys,[n_lines 1]);
end

line_handles = line(xs',ys',line_options{:});
if nargout
    varargout{1} = line_handles;
end

