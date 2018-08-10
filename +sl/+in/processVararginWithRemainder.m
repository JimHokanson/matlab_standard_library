function [in,new_v] = processVararginWithRemainder(in,v,varargin)
%X Process varargin with 
%
%   [in,varargin] = sl.in.processVararginWithRemainder(in,varargin,optional_inputs_varargin)
%
%   Outputs
%   -------
%   in : updated struct
%   varargin : cell of prop/value pairs
%
%   Optional Inputs
%   ---------------
%   None yet supported
%
%   Examples
%   ---------
%   %Written for:
%   p2.plotMarkers(ismin_I,'o','is_time',false)
%   %Internally we have:
%   in.is_time = true;
%   [in,varargin] = sl.in.processVararginWithRemainder(in,varargin);
%   %...
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
            I = find(cellfun(@(x) isequal(x,name),v),1);
            if ~isempty(I)
                in.(name) = v{I+1};
                v(I:I+1) = [];
            end
        end
    end
    
    new_v = v;
    
    %This old approach required property/value pairs ...

%     [in,extras] = sl.in.processVarargin(in,v,'allow_non_matches',true);
%     
%     new_varargin = extras.unmatched_args_as_cell;
    
end