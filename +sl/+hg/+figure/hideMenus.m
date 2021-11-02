function hideMenus(h_fig,varargin)
%
%   sl.hg.figure.hideMenus(h_fig,varargin)
%
%   sl.hg.figure.hideMenus(h_graphics,varargin)
%
%   Hides figure menus such as the help or file menus. By default all
%   Matlab menus are hidden. Options to bypass hiding everything are not
%   yet implemented ...
%
%   Inputs
%   ------
%   h_fig : matlab.ui.Figure
%   h_graphics : matlab.graphics.Graphics
%       Results of findall(h_fig) or some other approach for finding 
%       relevant handles in the figure
%
%   Optional Inputs
%   ---------------
%   Not yet implemented ...
%
%   Example
%   -------
%   plot(1:10)
%   %Hides everythingk only option implemented currently!!
%   sl.hg.figure.hideMenus(gcf);
%
%   See Also
%   --------
%   sl.hg.figure.hideIcons


in.hide = {};
in.keep = {};
in = sl.in.processVarargin(in,varargin);

ALL_MATLAB_MENU_TAGS = {'figMenuHelp','figMenuWindow','figMenuDesktop',...
    'figMenuTools','figMenuInsert','figMenuView','figMenuEdit','figMenuFile'};

%something like this for name matching ... (cast to lowercase)
% s = struct;
% s.help = 'figMenuHelp';
% s.figmenuhelp = 'figMenuHelp';

if isempty(in.hide) && isempty(in.keep)
    tags_to_hide = ALL_MATLAB_MENU_TAGS;
else
   error('Not yet implemented') 
end

if isa(h_fig,'matlab.ui.Figure')
    a = findall(h_fig);
else
    a = h_fig;
end
%Note, I'm not clear on the parent object of all h_graphics
%that would allow us to ensure we have something valid

%Note, we could also check for the new figures and throw an error (or build
%in support for those new figures (although those don't have menus by
%default ...)

for i = 1:length(tags_to_hide)
    cur_tag = tags_to_hide{i};
    b = findall(a,'Tag',cur_tag);
    if ~isempty(b)
        set(b,'Visible','Off')
    end
end
end
