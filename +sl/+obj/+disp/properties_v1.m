function varargout = properties_v1(objs,varargin)
%x
%
%   sl.obj.disp.properties_v1(objs,varargin)
%
%   Optional Inputs:
%   ----------------
%   print : logical (default false)
%       If true the string is printed to the command window.
%
%   Improvments
%   -----------
%   1) TODO: Fix edit links for properties so that they go to the property
%   instead of just opening the class. This may require a bit of mlint
%   help.
%   2) Implement the evaluations myself instead of using evalc
%   3) Allow not evaluating certain properties based on comment tags OR
%   meta properties (e.g. dependent) OR via inputs to this function

in.print = false;
in = sl.in.processVarargin(in,varargin);

[all_spaces,all_names,all_values] = h__getPropParts(objs);

full_class_name = class(objs);
n_properties = length(all_spaces);

%Part 2: Display each property
%--------------------------------------
str_ca = cell(1,n_properties);
for iProp = 1:n_properties
    %TODO: These links don't work as intended. I am working on a mlint
    %solution to this but it is going to take a while ...
    %
    %   Property Display format:
    %   ------------------------
    %   1) For a single object
    %   property_name : value
    %   
    %   2) For multiple objects
    %   property_name
    %
    cur_prop_name = all_names{iProp};
    leading_space = all_spaces{iProp};
    
    
    full_prop_name = sprintf('%s.%s',full_class_name,cur_prop_name);
    edit_link = h__createEditLink(cur_prop_name,full_prop_name);
    if length(objs) > 1
        str_ca{iProp} = sprintf('%s%s\n',leading_space,edit_link);
    else
        cur_prop_str  = all_values{iProp};
        str_ca{iProp} = sprintf('%s%s:%s\n',leading_space,edit_link,cur_prop_str);
    end
end

final_prop_str = [str_ca{:}];

if nargout
    varargout{1} = final_prop_str;
end

if in.print
    fprintf(1,final_prop_str);
end

end

function edit_link = h__createEditLink(disp_str,edit_str)

edit_cmd  = sprintf('edit %s',edit_str);
edit_link = sl.ml.cmd_window.createLinkForCommands(disp_str,edit_cmd);

end


function [all_spaces,all_names,all_values] = h__getPropParts(objs)
%The current approach grabs the default display and then adds on
%edit links.
%
%TODO: Eventually it would be good to write our own property display
%methods instead of extracting the displays from Matlab. This would
%allow us to not evaluate certain properties if they are time consuming.
%We'll do this one we get the markup language in place


%The default display is something like:
%
%   data with properties:
%
%       d: [4001x1 double]
%    time: [1x1 sci.time_series.time]

default_disp_str = evalc('builtin(''disp'',objs)');
lines = sl.str.getLines(default_disp_str);

%Note, we can't remove empty lines as it might be part of a multi-line
%display.
%1) Class display line
%2) spacer line
%end-1:end - end of the display is padded with 2 empty lines
lines([1:2 end-1:end]) = [];

multiple_objs = length(objs) > 1;

%NOTE: We are assuming that no property display is ever more
%than one line.
%Unfortunately it turns out that this is not always true. The code below
%has been rewritten to make 2 passes.
%
%Grab:
%1) leading spaces
%2) property name
%3) property display value string
if multiple_objs
    %Multiple objects, we only display the leading space
    %and property name
    temp = regexp(lines,'(\s+)([^:]*)','tokens','once');
else
    temp = regexp(lines,'(\s+)([^:]*):(.*)','tokens','once');
end

%Part 1: Grab all the components
%-------------------------------------
n_lines = length(lines);

if multiple_objs
    all_spaces = cellfun(@(x)x{1},temp,'un',0);
    all_names  = cellfun(@(x)x{2},temp,'un',0);
    all_values = []; %Not used
else
    
    last_valid_line = 0;
    is_valid = true(1,n_lines);
    all_spaces = cell(1,n_lines);
    all_names  = cell(1,n_lines);
    all_values = cell(1,n_lines);
    
    for iProp = 1:n_lines
        cur_set  = temp{iProp};
        if isempty(cur_set)
            %Add on value to previous entry
            is_valid(iProp)  = false;
            last_valid_value = all_values{last_valid_line};
            all_values{last_valid_line} = sprintf('%s\n%s',last_valid_value,lines{iProp});
        else
            all_spaces{iProp} = cur_set{1};
            all_names{iProp}  = cur_set{2};
            all_values{iProp} = cur_set{3};
            
            last_valid_line   = iProp;
        end
    end
    
    all_spaces(~is_valid) = [];
    all_names(~is_valid)  = [];
    all_values(~is_valid) = [];
end
end