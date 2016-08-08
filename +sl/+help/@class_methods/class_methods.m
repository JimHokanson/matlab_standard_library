classdef class_methods
    %
    %   Class:
    %   sl.help.class_methods
    %
    %   The goal of this class is to store method information
    
    
    properties
        method_names
        h1_strings
    end
    
    methods
        function obj = class_methods(class_name)
            %
            %  obj = sl.help.class_methods(class_name)
            %   
           keyboard 
           
           %How to get help
           %1) Read main class file
           %TODO: It would be nice to have a method
           %which reads a line from a text file
           %
           %
           %    text_reader = sl.io.text_reader(file_path);
           %    line = text_reader.nextLine;
           %
           %    NOTE: Under the hood this would probably read the file
           %    in buffered amounts and then see if line has been found
           %
           %
           %    Actually, to start, let's just read the first
           %    n characters, then on miss, read everything
           
           mc = meta.class.fromName(class_name);
           methods = mc.MethodList;

           
           class_path = which(class_name);
           raw_text = sl.io.fileRead(class_path,'*char');
           
           %NOTE: It would be much better to use mlint above
           
           sl.mlint.all
           
           %raw_text = 
           
        end
    end
    
end

