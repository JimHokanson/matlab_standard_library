classdef current_line_info < sl.obj.display_class
    %
    %   Class:
    %   sl.help.current_line_info
    %
    %   See Also:
    %   ---------
    %   sl.ml.popup_windows.function_help_display
    
    %{
    
    %Testing code:
    raw_text = 'sl.path.addPackages(''hdf5_matlab'
    obj = sl.help.current_line_info(raw_text,'')
    %sl.path.addPackages
    
    raw_text = 'mean(x(1'               %What do we want to do here?
    %mean
    
    raw_text = 'load filename'          %Call via string inputs
    %load
    
    raw_text = 'mean(''testing('
    
    fp = 'C:\D\repos\matlab_git\mat_std_lib\+sl\+help\@current_line_info\test_dir\example_line_v3.m'
    obj = sl.mlint.mex.lex(fp)
    
    
    ???What about multiline entries ...
    raw_text = sprintf('sl.path.addPackages(...\n')
    %}
    
    properties
       raw_text
       is_call_resolved
       resolved_name
    end
    
    methods
        function obj = current_line_info(raw_text,context)
            %
            %   obj = sl.help.current_line_info(raw_text,context)
            %
            %   Inputs:
            %   -------
            %   raw_text : 
            %       The text should only go to the cursor location.
            %   context : 
            %       I'm not sure what I want here ...
            %       command window or filename
            %       for now:
            %       - '' : command window
            %       - filename : path of file where it is coming from ...
            %
            
            obj.raw_text = raw_text;
                    
            %Can we find an unterminated quoted string and use that to our 
            %advantage to find the text ????
            %
            %Algorithm:
            %----------
            %0) Use lex ...
            %1) Ignore everything prior to an equal sign
            
            %Get lex
            %-------
            %Need to write to file I think :/
            %http://www.mathworks.com/matlabcentral/answers/223050-can-you-pass-a-string-to-parse-into-mlintmex-rather-than-a-filename
            fp = fullfile(sl.TEMP_DIR,'sl_current_line_info.m');
            
            sl.io.fileWrite(fp,raw_text);
            
            lex = sl.mlint.mex.lex(fp);
            
            keyboard
            
            %Find open paren
            %---------------
            %* They're might be a better approach for this
            %
            type_info = lex.types;
            %type_map_info = lex.unique_types_map
            temp = char(zeros(1,length(type_info)));
            temp(strcmp(type_info,'(')) = 'a';
            temp(strcmp(type_info,')')) = 'b';
            
            I_open_paren = regexp(temp,'a(?!b)');
            
            %TODO: Go back to types preceding the open paren
            %and form a name
            
            
            
        end
    end
    
end

