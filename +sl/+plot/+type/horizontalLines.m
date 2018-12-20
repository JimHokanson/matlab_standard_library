function varargout = horizontalLines(y_positions,varargin)
%
%   line_handles = sl.plot.type.horizontalLines(y_positions,varargin)
%
%   JAH TODO: Update documenation
%
%   Optional Inputs
%   ---------------
%   y_as_pct: logical (default false)
%       If true, the y_positions are interpreted as being a fraction of the
%       range of the current axes [0 1]
%       
%   x_values: [n 2] numeric array
%       Column 1: x_starts
%       Column 2: x_stops
%   x_pct : [n 2] numeric array
%       For when the values are meant to specified in terms of the viewing
%       limits. 
%
%       *** Other options are passed directly to the line constructor
%
%   Examples
%   --------
%   x = [10 30; 50  90];
%   sl.plot.type.horizontalLines(0.05,'y_as_pct',true,'x_values',x,'color','k');


in.y_pct_vary_with_zoom = false; %NYI - on zoom, change values
in.x_pct_vary_with_zoom = false; %NYI - on zoom, change values
in.y_as_pct = false; 
in.x_values = [];
in.x_pct = []; %NYI

[in,line_options] = sl.in.processVararginWithRemainder(in,varargin);

%NOTE: We need to know the y limit of the parents

n_lines = max([length(y_positions) size(in.x_values,1) size(in.x_pct,1)]);



if n_lines > y_positions
    if length(y_positions) == 1
        %scaler passed in, replicated based on x specification
        y_positions = repmat(y_positions,[n_lines 1]);
    else
        error('WTFasdfasdfasdf: TODO: Make me clearer')
    end
end

if in.y_as_pct
   y_lim = get(gca,'ylim');
   y_range = y_lim(2)-y_lim(1);    
   y_positions = y_lim(1)+y_positions(:).*y_range;
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

