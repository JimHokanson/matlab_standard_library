function output = findFiles(root_folder_path,varargin)
%
%   sl.code.findFiles(root_folder_path,varargin)
%
%   Inputs
%   ------
%   root_folder_path : 
%
%   Optional Inputs
%   ---------------
%   replace_with : string NOT YET IMPLEMENTED
%   use_regex : logical (default false) NOT YET IMPLEMENTED
%   named :
%   containing :
%   file_types : string or cellstr ( default {'*.m'} )
%       All values should start with a leading '*' character
%   include_subfolders : logical (default true)
%
%   Improvements
%   ------------
%   1) build in support for understanding code & comments
%   2) allow switching use of strfind vs regex

%{

root_folder_path = 'C:\repos\matlab_git\matlab_NEURON';
sl.code.findFiles(root_folder_path);

root_folder_path = 'C:\repos\matlab_git\matlab_NEURON';
sl.code.findFiles(root_folder_path,'named','g*');

root_folder_path = 'C:\repos\matlab_git\matlab_NEURON';
output = sl.code.findFiles(root_folder_path,'containing','sl.');

root_folder_path = 'C:\repos\matlab_git\matlab_NEURON\matlab_code\+NEURON\+sl'
output = sl.code.findFiles(root_folder_path,'containing','sl.');
output.replaceMatches('NEURON.sl.')

output = sl.code.findFiles(root_folder_path,'containing','NEURON.NEURON');
output.replaceMatches('NEURON')

output = sl.code.findFiles(root_folder_path,'containing',' handle_light');
output.replaceMatches(' NEURON.sl.obj.handle_light')

output = sl.code.findFiles(root_folder_path,'containing','= processVarargin');
output.replaceMatches(' NEURON.sl.in.processVarargin')

output = sl.code.findFiles(root_folder_path,'containing','in  NEURON.sl.in.processVarargin(in,varargin)');
output.replaceMatches('in = NEURON.sl.in.processVarargin(in,varargin)')

%}

in.replace_with = ''; %NYI
in.use_regex = false; %NYI
in.named = '';
in.containing = ''; %If in.regex, this is regex and not a simple string to match
in.file_types = {'*.m'};
in.include_subfolders = true; %DONE
in = sl.in.processVarargin(in,varargin);

all_extensions = in.file_types;
if ischar(all_extensions)
    all_extensions = {all_extensions};
end

%1) Get files to process
%-----------------------
%TODO: It would be nice if we could search for all of these at once 
all_file_paths = {};
for iExtension = 1:length(all_extensions)
    current_extension = all_extensions{iExtension};
    if current_extension(1) ~= '*'
        error('All extensions should start with a leading *')
    end
    file_paths = sl.dir.getList(root_folder_path,...
        'output_type','paths', ...
        'search_type','files',...
        'recursive',in.include_subfolders,...
        'extension',current_extension(2:end),... %Remove the *
        'file_pattern',in.named);
    all_file_paths = [all_file_paths file_paths]; %#ok<AGROW>
end

%TODO: Build in support for ending early

%TODO: Build in expansion support on overflow ...
cur_index = 0;
r_file_paths = cell(1,1000); %r => result
r_context_text = cell(1,1000);
r_I = zeros(1,1000);

%2) Filter on containing (TODO: Check if this is requested)
%----------------------------------------------------------
n_chars_forward_grab = length(in.containing) + 20;
for iFile = 1:length(all_file_paths)
   cur_file_path = all_file_paths{iFile};
   text = sl.io.fileRead(cur_file_path,'*char');
   
   %TODO: Also support regexp here as well
   I = strfind(text,in.containing);
   
   for iMatch = 1:length(I)
      cur_I = I(iMatch);
      cur_index = cur_index + 1;
      r_file_paths{cur_index} = cur_file_path;
      try
          r_context_text{cur_index} = text(cur_I-10:cur_I+n_chars_forward_grab);
      catch
          
          r_context_text{cur_index} = in.containing;
      end
      r_I(cur_index) = cur_I;
   end
end
%find_files_result(in,file_paths,I)
output = sl.code.find_files_result(in,root_folder_path,...
    r_file_paths(1:cur_index),...
    r_I(1:cur_index),r_context_text(1:cur_index));

end