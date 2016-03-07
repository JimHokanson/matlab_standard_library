classdef parsed_cursor_line_info < sl.obj.display_class
    %
    %   Class:
    %   sl.ml.parsed_cursor_line_info
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
    %
    %   I think I want to redo this so that I have the following:
    %   1) know what the current variables are:
    %   2) know which input of the current function I am at (e.g. 1,2,3,4
    %  
    %   a(b(c =>  callers = {'a' 'b' 'c'} %Then need to resolve a,b,c in
    %   the context of where I am (base, debugged workspace, file outside
    %   of debugging)
    %
    %   a(1,2,b(2,c( inputs {3,2,1}
    %       i.e. a is currently on the 3rd input
    %            b is currently on the 2nd input
    %            c is currently on the 1st input

    
    %{
    
    %Testing code:
%     profile on
%     for i = 1:100
%     raw_text = 'sl.path.addPackages(''hdf5_matlab';
%     obj = sl.help.current_line_info(raw_text,'');
%     end
%     profile off
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
        %New properties
        calls
        inputs
        
        is_debugging
        in_base
        in_file
        
        status_msg = ''
        paren_found = false
        raw_text
        possible_call_found = false %True if we have something that might
        %work, don't know if it exists or not but it is our best guess
        found_name
        
        %resolved_name
    end
    
    methods
        function obj = current_line_info(raw_text,from_command_window,active_document)
            %
            %   obj = sl.help.current_line_info(raw_text,context)
            %
            %   Inputs:
            %   -------
            %   raw_text :
            %       The text should only go to the cursor location.
            %   from_command_window : logical NYI
            %       If true, the calls should be evaluated from the
            %       context of the command window.
            %   active_document : NYI
            %       Pass this in if the calls should be evaluated from the
            %       context of being within active_document
            %
            
            

            obj.raw_text = raw_text;
            
            %Can we find an unterminated quoted string and use that to our
            %advantage to find the text ????
            %
            %Algorithm:
            %----------
            %1) DONE Use lex to identify lexical components of line
            %2) DONE Find open parens
            %3) DONE Create entry
            %4) Resolve to function
            
            %Get lex
            %-------
            lex = h__getLex(obj);
            %lex : sl.mlint.mex.lex
                        
            %Find open paren
            %---------------
            I_open_paren = h__findOpenParen(obj,lex);
            if ~isempty(obj.status_msg)
                return
            end
            
            %Get Name:
            %---------
            %Go from: (as an example)
            %   =>  [a,b] = sl.in.processVarargin(
            %to:
            %   'sl.in.processVarargin'
            h__getName(obj,lex,I_open_paren)
            if ~isempty(obj.status_msg)
                return
            end
            
            %Resolve:
            %--------
            %Command window:
            %either in debugger OR base namespace
            
            
            
            
        end
    end
    
end

function lex = h__getLex(obj)

%Need to write to file I think :/
%http://www.mathworks.com/matlabcentral/answers/223050-can-you-pass-a-string-to-parse-into-mlintmex-rather-than-a-filename
fp = fullfile(sl.TEMP_DIR,'sl_current_line_info.m');

sl.io.fileWrite(fp,obj.raw_text);

lex = sl.mlint.mex.lex(fp);

end

function I_open_paren = h__findOpenParen(obj,lex)
%* They're might be a better approach for this
%

lex_types = lex.types;

%type_map_info = lex.unique_types_map
temp = char(zeros(1,length(lex_types)));
temp(strcmp(lex_types,'(')) = 'a';
temp(strcmp(lex_types,')')) = 'b';

I_open_paren = regexp(temp,'a(?!b)');

if isempty(I_open_paren)
    obj.status_msg = 'Unable to find an open paren';
    return
end

I_open_paren = I_open_paren(end);

obj.paren_found = true;
end

function h__getName(obj,lex,I_open_paren)
%
%   * Currently we won't support any indexing
%
%   Populates:
%   ----------
%   .status_msg
%   .possible_call_found
%   .found_name

NAME_TYPE = '<NAME>';
PERIOD_TYPE = '.';

lex_types = lex.types;

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
end

