function sectionMethods(section_names,fcn_callback_string,varargin)
%
%   sl.obj.disp.sectionMethods(section_names,fcn_callback,varargin)
%
%   Optional Inputs:
%   ----------------

in.add_names_to_callback = true;
in.header_string = 'Method Types';
in.section_descriptions = {};
in = sl.in.processVarargin(in,varargin);


if in.add_names_to_callback
   fcn_callback_strings = sl.cellstr.sprintf([fcn_callback_string '(''%s'')'],section_names);
else
   fcn_callback_strings = fcn_callback_string; 
end

%Steps:
%get all things with section_names right aligned

section_name_string_lengths = cellfun('length',section_names);

max_length_name = max(section_name_string_lengths);
max_length_name = max(max_length_name,length(in.header_string));

temp_section_strings = cellfun(@sl.ml.cmd_window.createLinkForCommands,...
    section_names,fcn_callback_strings,'un',0);


fh = @(x,y)sl.str.padText(x,max_length_name,'text_loc','right','disp_len',y);

final_section_strings = cellfun(fh,temp_section_strings,...
    num2cell(section_name_string_lengths),'un',0);

header_string_padded = fh(in.header_string,length(in.header_string));    
    
%TODO: Add on descriptions if present **********
%--------------------------------------
all_strings = [header_string_padded final_section_strings];
all_strings = sl.cellstr.sprintf('%s:',all_strings);

final_disp_string = sl.cellstr.join(all_strings,'d','\n');

disp(final_disp_string)


end