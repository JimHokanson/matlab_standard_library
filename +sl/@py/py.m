classdef py
    %
    %   Class
    %   sl.py
    %
    %   This is very much in development
    
    properties
    end
    
    methods (Static)
        function v = version_info()
            %
            %   v = sl.py.version_info()
            %
            %   Example Output
            %   --------------
            %        version: '3.5'
            %     executable: 'C:\Users\Jim\Anaconda3\python.exe'
            %        library: 'C:\Users\Jim\Anaconda3\python35.dll'
            %           home: 'C:\Users\Jim\Anaconda3'
            %       isloaded: 1
            
            %v = pyversion; 
            
            v = evalc('pyversion');
        end
        function flag = is_setup()
            %
            %   v = sl.py.is_setup()
            
            [~,~,flag] = pyversion();
        end
        function install_default()
            if ispc
                %where() command should point to python.exe
                [~,result] = system('where python');
                file_path = strtrim(result);
                if exist(file_path,'file')
                   pyversion(file_path)
                else
                    error('Unable to find installed version of python')
                end
            else
                error('Other systems not yet supported')
            end
        end
        function addPath(varargin)
            %
            %   sl.py.addPath()
            %
            %   -end
            %   -begin
            
            if nargin == 0
                error('sl.py.addPath requires at least one input')
            end
            
            last_value = varargin{end};
            position = 1;
            if last_value(1) == '-'
                switch lower(last_value)
                    case '-end'
                        position = 0;
                    case '-begin'
                    otherwise
                        error('Unrecognized position option')
                end
                paths_to_add = varargin(1:end-1);
                if isempty(paths_to_add)
                   error('Paths to add is empty') 
                end
            else
                paths_to_add = varargin;
            end
            
            
            
            if position
                paths_to_add = sl.py.to_py.cellstr_to_list(paths_to_add);
                extend(py.sys.path,paths_to_add);
            end
            
            %insert(py.sys.path,int32(0),'');
            
        end
        %Perhaps these should go into a modules class
        %sl.py.modules
        %   - keys(py.sys.modules)
        function module = importModule(module_name)
            %
            %   sl.py.importModule(module_name)
            %
            module = py.importlib.import_module(module_name); 
        end
        function reloadModule(module_name_or_object)
            %
            %   sl.py.reloadModule(module_name)
            %
            %
            %http://www.mathworks.com/help/matlab/matlab_external/call-modified-python-module.html
           %2.7 py.reload
           %py.imp.reload 3.3
           if ischar(module_name_or_object)
               temp = py.sys.modules;
               module = temp{module_name_or_object};
           else
               module = module_name_or_object;
           end
           py.importlib.reload(module);
        end
        function varargout = path(p1,p2)
            %
            %   1) path - pretty prints path
            %   2) p = path
            %   3) path(p) changes to specific path
            %   4) path(path) refreshes
            %   5) path(p1,p2)
            %   6) path(path,p)
            %   7) path(p,path)
            
            %TODO: The output may be requested from 3 - 7
            %Need to switch on nargout and nargin
            
            if nargin == 0
                current_path = sl.py.to_ml.list_to_cellstr(py.sys.path)';
                if nargout == 0
                    disp(current_path);
                else
                    varargout{1} = current_path;
                end
            else
               error('not yet implemented') 
            end
                    
                
            
        end
    end
    
end

