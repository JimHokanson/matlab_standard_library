function varargout = horizontalLines(y_positions,local_options,line_options)
%
%   line_handles = sl.plot.type.horizontalLines(y_positions,local_options,line_options)
%
%   JAH TODO: Update documenation
%
%   Check this out: http://www.mathworks.com/matlabcentral/fileexchange/1039-hline-and-vline
%
%   Local Options:
%   --------------
%   x_values: [n 2] numeric array
%       Column 1: x_starts
%       Column 2: x_stops
%   x_pct : [n 2] numeric array
%       For when the values are meant to specified in terms of the viewing
%       limits. 
%       NOT YET IMPLEMENTED: 

if nargin == 2
    line_options = {};
end

in.y_pct_vary_with_zoom = false; %NYI - on zoom, change values
in.x_pct_vary_with_zoom = false; %NYI - on zoom, change values
in.y_as_pct = false; %NYI
in.x_values = [];
in.x_pct = [];
in = sl.in.processVarargin(in,local_options);

%NOTE: We need to know the y limit of the parents

n_lines = max([length(y_positions) length(in.x_values) length(in.x_pct)]);

if n_lines > y_positions
    if length(y_positions) == 1
        %scaler passed in, replicated based on x specification
        y_positions = repmat(y_positions,[n_lines 1]);
    else
        error('WTFasdfasdfasdf: TODO: Make me clearer')
    end
end

ys = [y_positions(:) y_positions(:)];

%TODO: This needs to be fixed
xs = in.x_values;

if isempty(in.x_values) && isempty(in.x_pct)
   %TODO : Eventually we need to respect a parent intput in line_options
   xs = get(gca,'xlim');
end


line_handles = line(xs',ys',line_options{:});
if nargout
    varargout{1} = line_handles;
end

