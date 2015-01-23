function help_str = getH1Line(method_name)
%getH1Line  Returns the first line in a help file, often designated 'H1'
%
%   help_str = getH1Line(method_name)
%
%   NOTE: This doesn't work for Hidden classses :/
%   We could fix this by doing it ourselves, but this is very tricky:
%   Help could be above or below ...
%   Need to be able to resolve input to file
%
%   If I ever get around to writing my own help function, this would be
%   really easy ...
%
%  tags: help, parsing
%  see also: help

%This is really really slow ...
help_raw = help(method_name);

help_str = regexp(help_raw,'^\s*\w+\s+(.+)','tokens','dotexceptnewline','once');

if ~isempty(help_str)
    help_str = help_str{1};
else
    %This at least shows the first line if it doesn't follow the rules above
    if ~isempty(help_raw)
        help_str = regexp(help_raw,'\n','split');
        help_str = strtrim(help_str{1});
    else
        help_str = '';
    end
end

end