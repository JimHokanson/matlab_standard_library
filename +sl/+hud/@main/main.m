classdef main
    %
    %   Class:
    %   sl.hud.main
    %
    %   This may eventually not launch a main GUI, but rather multiple GUIs
    %
    %   ------------------
    %   1) Programming shortcuts
    %   2) Function usage help
    %   3) Better file navigation
    %   4) User shortcuts?
    %
    %   TODO: We need to make this insensitive to clear all
    
    %{
        button_currentFcnName
    %}
    
    %http://blogs.mathworks.com/community/2007/05/18/do-you-dock-figure-windows-what-does-your-desktop-look-like/
    
    %http://www.mathworks.com/matlabcentral/fileexchange/16650-setfigdockgroup
    
    %{
    desktop=com.mathworks.mde.desk.MLDesktop.getInstance;
    container=desktop.getGroupContainer(‘Figures’).getTopLevelAncestor;
    container.setSize(width,height); % e.g., (500,300)
    You can also do the following useful actions:
    container.setAlwaysOnTop(1); % or 0 to return to normal
    container.setMaximized(1); % or 0 to return to normal
    container.setMinimized(1); % or 0 to return to normal
    container.setVisible(1); % or 0 to hide – ignore the java error…
    container.methodsview; % show full list of possible actions
    
    %}
    
    properties
    	h_fig
        h
    end
    
    methods
        function obj = main()
            gui_path = fullfile(sl.stack.getMyBasePath,'hud_main.fig');
            
            obj.h_fig = openfig(gui_path);
            
            obj.h = guihandles(obj.h_fig);
            
            setappdata(obj.h_fig,'obj',obj); 
            
            set(obj.h.button_currentFcnName,'Callback',@(~,~)getCurrentFunctionName('clipboard',true));
            obj.h.button_expandToFile.Callback = @(~,~)h__expandToFile();
            %call to function downloaded from FEX
            setFigDockGroup(obj.h_fig,'HUD')
            
            %sl.hg.figure.makeFigureAlwaysOnTop(obj.fig_handle);
        end
    end
    
    methods (Static)
        function edit()
            %
            %   sl.hud.main.edit()
           guide(fullfile(sl.stack.getMyBasePath,'hud_main.fig'));
        end
    end
    
    methods
    end
    
end
function h__expandToFile
wtf = sl.ml.editor.getInstance;
target_path = wtf.active_filename;
v = sl.ml.current_folder_viewer;
t = v.table;
t.collapseFirstLevel();
v.expandTo(target_path);
end

