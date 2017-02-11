classdef main
    %
    %   Class
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
    	fig_handle
        h
    end
    
    methods
        function obj = main()
            gui_path = fullfile(sl.stack.getMyBasePath,'hud_main.fig');
            
            obj.fig_handle = openfig(gui_path);
            
            obj.h = guihandles(obj.fig_handle);
            
            setappdata(obj.fig_handle,'obj',obj); 
            
            set(obj.h.button_currentFcnName,'Callback',@(~,~)getCurrentFunctionName('clipboard',true));
            
            %FEX
            setFigDockGroup(obj.fig_handle,'HUD')
            
            %sl.hg.figure.makeFigureAlwaysOnTop(obj.fig_handle);
        end
    end
    
    methods (Static)
        function edit()
           guide(fullfile(sl.stack.getMyBasePath,'hud_main.fig'));
        end
    end
    
    methods
    end
    
end

