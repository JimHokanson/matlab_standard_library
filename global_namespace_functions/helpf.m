function helpf(name,varargin)
%x  Returns help for a function, Jim's way
%
%   The idea with this function is to allow displaying the help function
%   as a set of sections.  
%
%   Improvement:
%   ------------
%   1) Allow displaying of only certain sections via the command
%   2) Create links to recognized functions => look for names
%   following colon. Also handle see also
%   3) Can we use html 
%   4) Make sure we can handle the non-sectioned help
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
%   - 

%{
* We pass back the text to this function to display using
%helpf(1,raw_text,name)

%}

    if name == 1
       disp(urldecode(varargin{1}))
       name = varargin{2};
       str = sl.ml.cmd_window.createLinkForCommands(...
           'to menu',sprintf('helpf(''%s'')',name));
       disp(str)
       disp('') %Adding a newline
       return
    end

    %This might eventually be better as extracted from help. It would require
    %that we remove hyperlinks ...
    process = helpUtils.helpProcess(1, 1, {name});

    process.getHelpText;
        
    help_string = process.helpStr;

    %Split on ---
    %
    %e.g.
    %
    %   Section Title:
    %   --------------
    %   Text
    
    %section_pattern = 
    
    %Let's require at least 3 ...
    %We could also look at 
    [r,stop_I] = regexp(help_string,'\n\s*-{3,}','split','end');
    
    %These are the titles for the 
    [title_strings,temp_I] = regexp(r(1:end-1),'\n[^\n]+$','once','match','start');
    
    title_strings = cellfun(@strtrim,title_strings,'un',0);
    
    text_start_I = [1 stop_I];
    title_start_I = text_start_I(1:end-1)+[temp_I{:}];
    
    section_start_I = [1 title_start_I];
    section_stop_I  = [title_start_I-1 length(help_string)];

    title_strings = [{'Introduction'} title_strings];
    
    
    
    n_sections = length(title_strings);
    all_strings = cell(1,n_sections);
    for iSection = 1:n_sections
       temp = help_string(section_start_I(iSection):section_stop_I(iSection));
       str = sl.ml.cmd_window.createLinkForCommands(...
           title_strings{iSection},sprintf('helpf(1,''%s'',''%s'')',urlencode(temp),name));
       %all_strings{iSection} = str;
       disp(str)
    end
    
    
    %????? What to display?
    %The function prototype?
    %Followed by links to each section
    
    %r = regexp(help_string,'\n[^\n]\n-{3,}');
        
end