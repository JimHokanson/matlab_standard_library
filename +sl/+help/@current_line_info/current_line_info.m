classdef current_line_info < sl.obj.display_class
    %
    %   Class:
    %   sl.help.current_line_info
    %
    %   See Also:
    %   ---------
    %   sl.ml.popup_windows.function_help_display
    %
    %   Status:
    %   -------
    %   The code is currently parsing the line. It does not handle
    %   the format in which spaces are used to denote inputs. We are also
    %   not trying to resolve the line, which will be really important for
    %   getting help from variables.
    %   
    %   Next:
    %   -----
    %   Try and interpret context to resolve the function from variables
    
    %{
    
    %Testing code:
    raw_text = 'sl.path.addPackages(''hdf5_matlab'
    obj = sl.help.current_line_info(raw_text,'')
    %sl.path.addPackages
    
    raw_text = 'mean(x(1'               %What do we want to do here?
    %x
    
    raw_text = 'load filename'          %Call via string inputs
    %load - Not currently working
    
    raw_text = 'mean(''testing('
    %mean
    
    %TESTING LINE
    obj = sl.help.current_line_info(raw_text,'')
    
    
    fp = 'C:\D\repos\matlab_git\mat_std_lib\+sl\+help\@current_line_info\test_dir\example_line_v3.m'
    obj = sl.mlint.mex.lex(fp)
    
    
    ???What about multiline entries ...
    raw_text = sprintf('sl.path.addPackages(...\n')
    %}
    
    properties
       status_msg
       paren_found = false
       raw_text
       possible_call_found = false %True if we have something that might
       %work, don't know if it exists or not but it is our best guess
       found_name
       
       %resolved_name
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
            tic
            obj.raw_text = raw_text;
            
            NAME_TYPE = '<NAME>';
            PERIOD_TYPE = '.';
            
            %Can we find an unterminated quoted string and use that to our 
            %advantage to find the text ????
            %
            %Algorithm:
            %----------
            %1) Use lex to identify lexical components of line
            %2) Find open parens
            %3) Create entry
            
            %Get lex
            %-------
            %Need to write to file I think :/
            %http://www.mathworks.com/matlabcentral/answers/223050-can-you-pass-a-string-to-parse-into-mlintmex-rather-than-a-filename
            fp = fullfile(sl.TEMP_DIR,'sl_current_line_info.m');
            
            sl.io.fileWrite(fp,raw_text);
            
            lex = sl.mlint.mex.lex(fp);
            
            lex_types = lex.types;
            
            %Find open paren
            %---------------
            %* They're might be a better approach for this
            %
            
            %type_map_info = lex.unique_types_map
            temp = char(zeros(1,length(lex_types)));
            temp(strcmp(lex_types,'(')) = 'a';
            temp(strcmp(lex_types,')')) = 'b';
            
            I_open_paren = regexp(temp,'a(?!b)');
            
            if isempty(I_open_paren)
                return
            end
                
            I_open_paren = I_open_paren(end);
            
            obj.paren_found = true;
            
            %Get name
            %---------
            %* Currently we won't support any indexing
            
            if I_open_paren == 1
                obj.status_msg = 'paren found was the first element, exiting early';
                return
            end
            
            cur_I = I_open_paren-1;
            
            if ~strcmp(lex_types(cur_I),NAME_TYPE)
                obj.status_msg = 'expected name type to precede paren, but name type was not found';
                return 
            end
            
            done = cur_I <= 2;
            while ~done
               if strcmp(lex_types(cur_I-1),PERIOD_TYPE) && strcmp(lex_types(cur_I-2),NAME_TYPE)
                   cur_I = cur_I - 2;
                   done = cur_I <= 2;
               else
                   done = true;
               end
            end
            
            obj.possible_call_found = true;
            obj.found_name = [lex.strings{cur_I:I_open_paren-1}];

            toc


            
            
            
        end
    end
    
end

