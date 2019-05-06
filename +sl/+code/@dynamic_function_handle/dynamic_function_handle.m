classdef dynamic_function_handle < handle
    %
    %   Class:
    %   sl.code.dynamic_function_handle
    %
    %   Written to support user functions written at run time. The function
    %   only persists as long as the instance of this class persists.
    %
    %   See examples in comments below.
    %
    %   Call function with run() method
    
    %{
    
    %Sample functions ...
    %---------------------------------------
    function cheese
        disp('cheese')
    end
    
    function hi_mom()
        a = 1;
        b = 2;
        fprintf('a: %d\n',a);
        fprintf('b: %d\n',b);
    end
    
    function [a,b,c] = tele(a,b,c)
        a = 2*a;
        b = 3*b;
        c = 4*c;
    end
    %---------------------------------------
    
    %Copy function from above then run this
    str = clipboard('paste')
    obj = sl.code.dynamic_function_handle(str);
    
    %For the functions with no inputs
    obj.run()
    
    %for tele
    [a,b,c] = obj.run(1,2,3)
    %}
    

    properties
        d1 = '--- call via: outputs = obj.run(inputs) ---'
        fh
        user_data %For user to populate if desired
        user_name %For user reference
        %- gets added to temp file name
        %- doesn't impact code execution
        root_path
        file_path
    end
    
    methods
        function obj = dynamic_function_handle(str,varargin)
            %
            %   obj = sl.code.dynamic_function_handle(str,varargin)

            in.name = '';
            in = sl.in.processVarargin(in,varargin);

            obj.user_name = in.name;
            
            [~,initial_name] = fileparts(tempname());
            
            if ~isempty(in.name)
                final_name = sprintf('%s_%s.m',in.name,initial_name);
            else
                final_name = sprintf('%s.m',initial_name);
            end
            
            obj.root_path = fullfile(sl.getRoot,...
                'global_namespace_functions','temp__dynamic_functions');
            
            obj.file_path = fullfile(obj.root_path,final_name);
            
            sl.io.fileWrite(obj.file_path,str);
            
            obj.fh = str2func(final_name(1:end-2));
        end
        function delete(obj)
            try %#ok<TRYNC>
                delete(obj.file_path);
            end
        end
        function varargout = run(obj,varargin)
            [varargout{1:nargout}] = obj.fh(varargin{:});
        end
    end
end

