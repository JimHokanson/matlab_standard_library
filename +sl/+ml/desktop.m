classdef desktop
    %
    %   Class:
    %   sl.ml.desktop
    %
    %   d = sl.ml.desktop.getInstance()
    %
    %   desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
    %   http://www.mathworks.com/matlabcentral/newsreader/view_thread/155225
    %   http://www.mathworks.com/matlabcentral/fileexchange/16650-setfigdockgroup
    
    properties
        d %jDesktop
        main_frame
        
        
    end
    
    properties (Dependent)
        %http://undocumentedmatlab.com/blog/customizing-matlabs-workspace-table
        client_titles %cellstr
        status_text
        is_busy
        is_debugging
    end
    
    methods
        function value = get.client_titles(obj)
           value = cellstr(char(obj.d.getClientTitles)); 
        end
        function value = get.status_text(obj)
            try    % Working in R2009a and 2011b:
                value = char(obj.main_frame.getStatusBar.getText());
            catch  % Working in R2011b:
                value = char(obj.main_frame.getMatlabStatusText());
            end
        end
        function value = get.is_busy(obj)
            value = strcmpi(obj.status_text,'Busy');
            %Other text:
            %Waiting for input %When in keyboard mode
            %Reply = ~isempty(statusText);
        end
        function value = get.is_debugging(obj)
            %When I was writing this function, while in debug mode
            %the status text temporarily changed ... (not sure why)
            value = strcmpi(obj.status_text,'Waiting for input') || ...
                strcmpi(obj.status_text,'Paused in debugger');
        end
    end
    
    methods (Access = private)
        function obj = desktop()
            %Nothing so far ...
            
            try
                obj.d = com.mathworks.mde.desk.MLDesktop.getInstance;
            catch
                obj.d = com.mathworks.ide.desktop.MLDesktop.getMLDesktop;
            end
            
            obj.main_frame = obj.d.getMainFrame;
            
        end
    end
    
    methods
        %function
    end
    
    methods (Static)
        function output = getInstance()
            %x Access method for singleton
            persistent local_obj
            if isempty(local_obj)
                local_obj = sl.ml.desktop();
            end
            output = local_obj;
        end
    end
    
end

