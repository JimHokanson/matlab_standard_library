function [in,new_v] = processVararginWithRemainder(in,v,varargin)
%X Process varargin with non-matches being exported as remainder
%
%   [in,varargin] = sl.in.processVararginWithRemainder(in,varargin,optional_inputs_varargin)
%
%   Note this code supports non prop/value pair inputs that get passed
%   on to the remainder - only prop/value pairs can update the input
%   structure. To do this it assumes that all valid property names are 
%   not values of another property. For example that you don't have:
%       
%             name     value    name     value
%       v = {'my_prop',3,'my_next_prop','my_prop};
%
%       Here 'my_prop' is used as a property and value, which would be
%       invalid. This 
%
%   Outputs
%   -------
%   in : updated struct
%   varargin : cell of prop/value pairs
%       Currently only a cell output is supported.
%
%   Optional Inputs
%   ---------------
%   None yet supported
%
%   Examples
%   ---------
%   %Written for:
%   p2.plotMarkers(ismin_I,'o','is_time',false)
%   %Internally (plotMarkers) we have:
%   in.is_time = true;
%   [in,varargin] = sl.in.processVararginWithRemainder(in,varargin);
%   %...
%   %which makes the following call using the remaining varargin
%   %=> varargin now only has {'o'} since is_time has been pulled out
%   %and has updated the 'in' struct
%   plot(times,obj.d(I),varargin{:})
%   
%
%
%   Improvements
%   ------------
%   1) Allow output varargin to either be a struct or a cell (Currently
%   always a cell)
%   

    fn = fieldnames(in);


    if isstruct(v)
        error('struct input not yet supported')
    else
        %*************
        %We assume that our fieldnames won't be values for other properties
        for i = 1:length(fn)
            name = fn{i};
            I = find(cellfun(@(x) isequal(x,name),v));
            if length(I) == 1
                in.(name) = v{I+1};
                v(I:I+1) = [];
            elseif length(I) > 1
                error('Multiple property matches found for: %s',name);
            end
        end
    end
    
    new_v = v;
    
    %This old approach required property/value pairs ...

%     [in,extras] = sl.in.processVarargin(in,v,'allow_non_matches',true);
%     
%     new_varargin = extras.unmatched_args_as_cell;
    
end