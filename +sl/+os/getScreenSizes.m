function s = getScreenSizes(varargin)
%
%   s = sl.os.getScreenSizes(varargin)
%
%   Optional Inputs
%   ---------------
%   type : default 'struct'
%       - 'struct'
%       - 'matrix'
%       - 'cell' NYI
%   ordering : NYI
%       left to right, top to bottom ...
%       i.e. ensure they are returned in a specific order
%
%   Output
%   -------
%   s :
%       'struct'
%       .left
%       .bottom
%       .width
%       .height
%       .top
%       .right
%   

in.type = 'struct';
in = sl.in.processVarargin(in,varargin);

%Format left,bottom,width,height
%
%Note, this approach gets stale if the monitors update :/
temp = get(0,'MonitorPosition');

switch lower(in.type)
    case 'struct'
        n_monitors = size(temp,1);
        s_all = cell(1,n_monitors);
        for i = 1:n_monitors
           row = temp(i,:);
           s2 = struct;
           s2.left = row(1);
           s2.bottom = row(2);
           s2.width = row(3);
           s2.height = row(4);
           s2.right = s2.left + s2.width - 1;
           s2.top = s2.bottom + s2.height - 1;
           s_all{i} = s2;
        end
        s = [s_all{:}];
    case 'cell'
        %NYI
    case 'matrix'
        s = temp;
end

end