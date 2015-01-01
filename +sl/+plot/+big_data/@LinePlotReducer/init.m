function init(o,varargin)
%
%   sl.plot.big_data.LinePlotReducer.init
%
%   The initialization only serves to parse the input data. Nothing is
%   rendered (plotted).
%
%   See Also:
%   sl.plot.big_data.LinePlotReducer.renderData

% The first argument might be a function handle or it might
% just be the start of the data.
start = 1;

%Function handle determination
%---------------------------------------
if isa(varargin{start}, 'function_handle')
    o.plot_fcn = varargin{1};
    start = start + 1;
else
    o.plot_fcn = @plot;
end

%Axes specified??
%---------------------------------------
%If not, handle on first renderData ...
if isscalar(varargin{start}) && ishandle(varargin{start}) && ...
        strcmp(get(varargin{start}, 'Type'), 'axes')
    
    o.h_axes   = varargin{start};
    o.h_figure = get(o.h_axes, 'Parent');

    start = start + 1;
end

h__parseDataAndLinespecs(o,varargin{start:end})

end

function h__parseDataAndLinespecs(o,varargin)

% Function to check if something's a line spec
is_line_spec = @(s) ischar(s) && isempty(regexp(s, '[^rgbcmykw\-\:\.\+o\*xsd\^v\>\<ph]', 'once'));

% A place to store the linespecs as we find them.
temp_specs = {};
temp_x = {};
temp_y = {};

% Loop through all of the inputs.
%------------------------------------------
previous_type = 's'; %s - start
n_groups      = 0; %Increment when both x & y are set ...
n_inputs      = length(varargin);
for k = 1:n_inputs
    current_argument = varargin{k};
    if isnumeric(current_argument) || isa(current_argument,'sci.time_series.time')
        % If we already have an x, then this must be y.
        if previous_type == 'x'
            
            % Rename for simplicity.
            ym = current_argument;
            xm = varargin{k-1};
            
            % We can accept data in rows or columns. If this is
            % 1-by-n -> 1 series from columns
            % m-by-n -> n series from columns
            % m-by-1 -> 1 series from rows (transpose)
            
            if isobject(xm)
                %Assume of type sci.time_series.time for now
                if size(ym,1) ~= xm.n_samples
                   ym = ym'; 
                end
            else
                if size(xm, 1) == 1
                    xm = xm.';
                end
                if size(ym, 1) == 1
                    ym = ym.';
                end
                % Transpose if necessary.
                if size(xm, 1) ~= size(ym, 1)
                    ym = ym';
                end
            end
            
            % Store y, x, and a map from y index to x index.
            temp_x{end+1} = xm;
            temp_y{end+1} = ym;
            n_groups = n_groups + 1;
            % We've now matched this x.
            previous_type = 'y';
            
            % If we don't have an x, this must be x.
        else
            previous_type = 'x';
        end
    elseif is_line_spec(varargin{k})
        %TODO: Should ensure correct previous type - x or y
        previous_type = 'l';
        %Must be a linespec or the end of the data
        temp_specs{n_groups} = current_argument;
    else
        %Must be done with everything, remainder are options ...
        o.extra_plot_options = varargin(k:end);
        break
    end
end

if previous_type == 'x'
    % If we had an x and were looking for a y, it
    % probably was actually a y with an implied x.
    
    % Rename for simplicity.
    ym = varargin{k};
    
    % We can accept data in rows or columns. If this is
    % 1-by-n -> 1 series from columns
    % m-by-n -> n series from columns
    % m-by-1 -> 1 series from rows (transpose)
    if size(ym, 1) == 1
        ym = ym.';
    end
    
    % Make the implied x explicit. %TODO: Allow being empty ...
    temp_x{end+1} = (1:size(ym, 1))';
    temp_y{end+1} = ym;
    n_groups = n_groups + 1;
    temp_specs{n_groups} = {};
elseif previous_type == 'y'
    temp_specs{n_groups} = {};
end

o.x = temp_x;
o.y = temp_y;
o.linespecs = temp_specs;

end