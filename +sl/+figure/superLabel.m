function [super_axes_h,h] = superLabel(label_type,text,varargin)
%x Places a label for a group of subplots
%
%   [ax,h] = sl.figure.superLabel(label_type,text,varargin)
%
%   Original code from:
%   http://www.mathworks.com/matlabcentral/fileexchange/7772-suplabel
%
%   Inputs:
%   -------
%   label_type : {'x' 'y' 'yy' 't'}
%       x - xlabel
%       y - ylabel
%       yy - right hand side ylabel
%       t - title
%   text : string
%       Label text
%
%   Outputs:
%   --------
%   ax :
%   h :
%
%   Examples:
%   ---------
%   [ax,h] = sl.figure.superLabel('t','Super Title!')
%
% EXAMPLE: (OUT OF DATE)
%  subplot(2,2,1);ylabel('ylabel1');title('title1')
%  subplot(2,2,2);ylabel('ylabel2');title('title2')
%  subplot(2,2,3);ylabel('ylabel3');xlabel('xlabel3')
%  subplot(2,2,4);ylabel('ylabel4');xlabel('xlabel4')
%  [ax1,h1]=suplabel('super X label');
%  [ax2,h2]=suplabel('super Y label','y');
%  [ax3,h2]=suplabel('super Y label (right)','yy');
%  [ax4,h3]=suplabel('super Title'  ,'t');
%  set(h3,'FontSize',30)


%modified 3/16/2010 by IJW to make axis behavior re "zoom" on exit same as
%at beginning. Requires adding tag to the invisible axes

in.fig_handle = [];
in.axes_buf = 0.04;
in = sl.in.processVarargin(in,varargin);


if isempty(in.fig_handle)
    in.fig_handle = gcf;
end

super_axes_h = findobj(in.fig_handle,'type','axes','tag','suplabel');

if isempty(super_axes_h)
    
    ah = findall(gcf,'type','axes');
    if isempty(ah)
        super_axes_position = [0.08 0.08 0.84 0.84];
    else
        left_min   = Inf;
        bottom_min = Inf;
        left_max   = 0;
        bottom_max = 0;
        
        axes_buf = in.axes_buf;
        
        %TODO: We shouldn't permanently change this ...
        set(ah,'units','normalized')
        
        %This is where the magic happens
        for ii=1:length(ah)
            if strcmp(get(ah(ii),'Visible'),'on')
                this_position = get(ah(ii),'Position');
                left_min   = min(left_min,this_position(1));
                bottom_min = min(bottom_min,this_position(2));
                left_max   = max(left_max,this_position(1)+this_position(3));
                bottom_max = max(bottom_max,this_position(2)+this_position(4));
            end
        end
        super_axes_position = [...
            left_min   - axes_buf, ...
            bottom_min - axes_buf, ...
            left_max - left_min + axes_buf*2, ...
            bottom_max - bottom_min + axes_buf*2];
    end
    
    super_axes_h = axes('Units','Normal','Position',super_axes_position,'Visible','off','tag','suplabel');
end

%Why the need for visible on????
if strcmp('t',label_type)
    set(get(super_axes_h,'Title'),'Visible','on')
    h = title(text);
    set(h,'VerticalAlignment','middle')
elseif strcmp('x',label_type)
    set(get(super_axes_h,'XLabel'),'Visible','on')
    h = xlabel(text);
elseif strcmp('y',label_type)
    set(get(super_axes_h,'YLabel'),'Visible','on')
    h = ylabel(text);
elseif strcmp('yy',label_type)
    set(get(super_axes_h,'YLabel'),'Visible','on')
    h = ylabel(text);
    set(super_axes_h,'YAxisLocation','right')
end

%for k=1:length(currax), axes(currax(k));end % restore all other axes


