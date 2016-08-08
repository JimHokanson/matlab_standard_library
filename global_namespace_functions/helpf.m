function helpf(fcn_name,varargin)
%x  Returns help for a function, Jim's way
%
%   The idea with this function is to allow displaying the help function
%   as a set of sections.
%
%   Improvements:
%   -------------
%   1) Allow displaying of only certain sections via the command, e.g.
%   something like:
%       helpf -s input optional_inputs
%   2) Create links to recognized functions => look for names
%   following colon. Also handle: see also
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

%Implementation Notes:
%---------------------
%In the first pass, we display the menu by parsing the help text.

if fcn_name == 1
    section_text = varargin{1};
    fcn_name = varargin{2};
    h__displaySection(section_text,fcn_name)
else
    h__displayMenu(fcn_name,varargin{:});
end

end

function h__displaySection(section_text,fcn_name)

%We pass back the text to this function to display using
%helpf(1,raw_text,name)
%
%   Inputs:
%   -------
%   section_text : string
%       Text to display. It has been encoded because we store the
%       text in a command to display the menu and this command is a
%       html anchor tag, so characters like <> would presumably
%       throw the command display off.
%   fcn_name : string
%       Original input name so that we can return back to "the menu"
%

disp(urldecode(section_text))

menu_command = sprintf('helpf(''%s'')',fcn_name);

str = sl.ml.cmd_window.createLinkForCommands('to menu',menu_command);

disp(str)
fprintf('\n'); %Adding a newline, otherwise things get a bit tight

end

function h__displayMenu(fcn_name)

%Get the original help string
%----------------------------
%This might eventually be better as extracted from help. The lines
%below are from help() but might not be stable.
%
%  alternative approach:
%  ---------------------
%  str = evalc('help(...))
%
%  It would however require that we remove hyperlinks ...

process = helpUtils.helpProcess(1, 1, {fcn_name});

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
%TODO: This fails sometimes, presumably for cases of no title strings ...
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
        title_strings{iSection},sprintf('helpf(1,''%s'',''%s'')',urlencode(temp),fcn_name));
    disp(str)
end

end