function [ax,h]=suplabel(text,label_id,varargin)
% Places text as a title, xlabel, or ylabel on a group of subplots.
% 
%   [ax,h]=sl.plot.annotation.suplabel(text,label_id,varargin)
%
%   Inputs
%   -------
%   text : string or cellstr
%       Note cellstr means multiline string
%   label_id : 
%       - 'x' 
%       - 'y' 
%       - 'yy' (right)   
%       - 't' (title)
%
%   Optional Inputs
%   ---------------
%   h_fig : default gcf
%       Figure handle
%   axes_position : default [0.08 0.08 0.84 0.84]
%       Where to place the invisible figure
%   axes_buffer : default 0.04
%       Padding that gets added to all existing axes to put in global
%       labels
%
%   Outputs
%   -------
%   ax : 
%       Handle to the hidden axes
%   h : 
%   
%
%   Example
%   -------
%   subplot(2,2,1);ylabel('ylabel1');title('title1')
%   subplot(2,2,2);ylabel('ylabel2');title('title2')
%   subplot(2,2,3);ylabel('ylabel3');xlabel('xlabel3')
%   subplot(2,2,4);ylabel('ylabel4');xlabel('xlabel4')
%   [ax1,h1]=suplabel('super X label');
%   [ax2,h2]=suplabel('super Y label','y');
%   [ax3,h2]=suplabel('super Y label (right)','yy');
%   [ax4,h3]=suplabel('super Title'  ,'t');
%   set(h3,'FontSize',30)
%
%   Improvements
%   ------------
%   1) I don't like that this modifies the units of the axes ...
%   2) 
%
%
%   Original Author: Ben Barrowes <barrowes@alum.mit.edu>
%   See licenses folder

in.axes_buffer = 0.04;
in.axes_position = [];
in.h_fig = [];
in = sl.in.processVarargin(in,varargin);

if isempty(in.h_fig)
    in.h_fig = gcf;
end

if isempty(in.axes_position)
    p_axes = [0.08 0.08 0.84 0.84];
    ah = findall(in.h_fig,'type','axes','-not','tag','suplabel');
    if ~isempty(ah)
        n_valid_axes = 0;
        leftMin = inf;  
        bottomMin = inf;  
        leftMax = 0;  
        bottomMax = 0;
        ax_buf = in.axes_buffer;
        set(ah,'units','normalized')
        ah=findall(gcf,'type','axes');
        for ii = 1:length(ah)
            if strcmp(get(ah(ii),'Visible'),'on')
                n_valid_axes = n_valid_axes + 1;
                thisPos = get(ah(ii),'Position');
                leftMin = min(leftMin,thisPos(1));
                bottomMin = min(bottomMin,thisPos(2));
                leftMax = max(leftMax,thisPos(1)+thisPos(3));
                bottomMax = max(bottomMax,thisPos(2)+thisPos(4));
            end
        end
        if n_valid_axes
            p_axes = [...
                leftMin-ax_buf,...
                bottomMin-ax_buf,...
                leftMax-leftMin+ax_buf*2,...
                bottomMax-bottomMin+ax_buf*2];
        end
    end
else
    p_axes = in.axes_position;
end

if nargin < 2
    label_id = 'x';
end

label_id = lower(label_id);

ax = axes('Units','Normal','Position',p_axes,'Visible','off','tag','suplabel');
%We don't want to manipulate this axes, want to be able to zoom, pan, etc.
%on others
uistack(ax,'bottom');
if strcmp('t',label_id)
    set(get(ax,'Title'),'Visible','on')
    h = title(text);
    set(h,'VerticalAlignment','middle')
elseif strcmp('x',label_id)
    set(get(ax,'XLabel'),'Visible','on')
    h = xlabel(text);
elseif strcmp('y',label_id)
    set(get(ax,'YLabel'),'Visible','on')
    h = ylabel(text);
elseif strcmp('yy',label_id)
    set(get(ax,'YLabel'),'Visible','on')
    h = ylabel(text);
    set(ax,'YAxisLocation','right')
end