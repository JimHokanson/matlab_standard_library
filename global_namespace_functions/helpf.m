function helpf(name,varargin)
%x  Returns help for a function, Jim's way
%
%   The idea with this function is to allow displaying the help function
%   as a set of sections.  
%
%   Improvements:
%   -------------
%   1) Allow displaying of only certain sections via the command
%   2) Create links to recognized functions => look for names
%   following colon. Also handle see also
%   3) Can we allow an html popup? (via an option)
%   4) Make sure we can handle the non-sectioned help function
%   5) Allow for function prototyping, and display this
%   by default. This will require a lot of work.
%
%
%   Example:
%   --------
%   helpf sl.dir.getList
%
%   Common Sections:
%   ----------------
%   - Calling Forms
%   - Input(s)
%   - Optional Input(s)
%   - Output(s)
%   - See Also
%   - Improvements
%   - Example(s)

%{
* We pass back the text to this function to display using
%helpf(1,raw_text,name)

%}

    if name == 1
       text_to_display = varargin{1};
       name = varargin{2};
       disp(urldecode(text_to_display))
       
       menu_command = sprintf('helpf(''%s'')',name);
       
       str = sl.ml.cmd_window.createLinkForCommands(...
           'to menu',menu_command);
       
       disp(str)
       fprintf('\n'); %Adding a newline, otherwise things get a bit tight
       %
       return
    end

    
    %Get the original help string
    %----------------------------
    %This might eventually be better as extracted from help. 
    %  str = evalc('help(...))
    %It would however require that we remove hyperlinks ...
    process = helpUtils.helpProcess(1, 1, {name});

    process.getHelpText;
        
    help_string = process.helpStr;

    
    %Split on dividers and obtain parts
    %-------------------------------------
    %
    %e.g.
    %
    %   Section Title:
    %   --------------
    %   Text
    
    %Let's require at least 3 ...
    section_pattern = '\n\s*-{3,}'; 
    
    
    %We could also look at 
    [r,stop_I] = regexp(help_string,section_pattern,'split','end');
    
    %These are the titles for the 
    [title_strings,temp_I] = regexp(r(1:end-1),'\n[^\n]+$','once','match','start');
    
    title_strings = cellfun(@strtrim,title_strings,'un',0);
    
    text_start_I = [1 stop_I];
    title_start_I = text_start_I(1:end-1)+[temp_I{:}];
    
    section_start_I = [1 title_start_I];
    section_stop_I  = [title_start_I-1 length(help_string)];

    title_strings = [{'Introduction'} title_strings];
    
    %Do the actual displaying
    %---------------------------
    n_sections = length(title_strings);
    for iSection = 1:n_sections
       temp = help_string(section_start_I(iSection):section_stop_I(iSection));
       str = sl.ml.cmd_window.createLinkForCommands(...
           title_strings{iSection},sprintf('helpf(1,''%s'',''%s'')',urlencode(temp),name));
       disp(str)
    end
    
        
end