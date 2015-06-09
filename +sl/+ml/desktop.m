classdef desktop
    %
    %   Class:
    %   sl.ml.desktop
    %
    %   desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
    %   http://www.mathworks.com/matlabcentral/newsreader/view_thread/155225
    %   http://www.mathworks.com/matlabcentral/fileexchange/16650-setfigdockgroup
    
    properties
    end

    methods (Access = private)
        function obj = desktop()
            %Nothing so far ...
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

