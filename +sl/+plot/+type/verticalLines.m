function varargout = verticalLines(x_positions,varargin)
%
%   line_handles = sl.plot.type.verticalLines(x_positions,varargin)
%
%   Inputs:
%   -------
%
%   
%
%   Optional Inputs, all line properties as well as:
%   ------------------------------------------------
%   x_as_pct : false
%       If true the x values should be related to the
%
%   y_values: [n 2] numeric array
%       Column 1: y starts
%       Column 2: y stops
%   y_pct : [n 2] numeric array
%       For when the values are meant to specified in terms of the viewing
%       limits. 
%       NOT YET IMPLEMENTED: 
%
%   TODO: Finish documentation

%A potentially useful reference
%Check this out: http://www.mathworks.com/matlabcentral/fileexchange/1039-hline-and-vline

in.y_pct_vary_with_zoom = false; %NYI - on zoom, change values
in.x_pct_vary_with_zoom = false; %NYI - on zoom, change values
in.x_as_pct = false; %NYI
in.y_values = [];
in.y_pct = [];
[local_options,line_options] = sl.in.removeOptions(varargin,fieldnames(in),'force_cell',true);
in = sl.in.processVarargin(in,local_options);

%NOTE: We need to know the y limit of the parents

n_lines = max([length(x_positions), size(in.y_values,1), size(in.y_pct,1)]);

if n_lines > x_positions
    if length(x_positions) == 1
        %scaler passed in, replicated based on x specification
        x_positions = repmat(x_positions,[n_lines 1]);
    else
        error('WTFasdfasdfasdf: TODO: Make me clearer')
    end
end

xs = [x_positions(:) x_positions(:)];

if ~isempty(in.y_values)
   ys = in.y_values;
else
   [is_found,value] = sl.in.getOptionalParameter(line_options,'parent');
   if is_found
       ax_use = value;
   else
       ax_use = gca;
   end
   
   temp = get(ax_use,'ylim');
   if isempty(in.y_pct)
       ys = temp;
   else
       ys = in.y_pct;
       ys(:,1) = ys(:,1)*temp(1);
       ys(:,2) = ys(:,2)*temp(2);
   end
end

if size(ys,1) < n_lines
   ys = repmat(ys,[n_lines 1]);
end

line_handles = line(xs',ys',line_options{:});
if nargout
    varargout{1} = line_handles;
end

