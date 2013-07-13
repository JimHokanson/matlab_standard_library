classdef (Hidden) filter_methods
    %
    %   Class:
    %   sl.dir.filter_methods
    %
    %   Filter methods should filter a list of directoryt or files ...
    %
    %   See Also:
    %   sl.dir.list_methods
    
    %Usage by filtering method
    %----------------------------------------------------------------------
    %ByName_v1
    %   - dirs_ignore
    %   - first_chars_ignore
    
    
    methods (Static)
        function delete_mask = ByName_v1(file_names,options)
            %
            %
            %   options used
            %       .dirs_ignore
            %       .first_chars_ignore
            
            if isempty(file_names)
                delete_mask = [];
                return
            end
            
            delete_mask = f_dirs_ignore(options.dirs_ignore,file_names);
            if ~isempty(options.first_chars_ignore)
                %This ran into a dimensionality issue of 0x0 with a 1x0 ... :/
                delete_mask =  delete_mask | f_first_chars_ignore(options.first_chars_ignore,file_names);
            end
            
        end
    end
    
end



%Implementation of options ...
%--------------------------------------------------------------------------
function delete_mask = f_dirs_ignore(ignore_dirs,file_names)

%ismember is slow, incorporate ismember_str ...
delete_mask = ismember(file_names,ignore_dirs);
end

function delete_mask = f_first_chars_ignore(first_chars_ignore,file_names)

n_files = length(file_names);
first_chars = blanks(n_files);
for iFile = 1:n_files
    first_chars(iFile) = file_names{iFile}(1);
end

if length(first_chars_ignore) < 5
    %NOTE: Might make this a function ...
    delete_mask = false(1,length(first_chars));
    for iIgnore = 1:length(first_chars_ignore)
        delete_mask(strfind(first_chars,first_chars_ignore(iIgnore))) = true;
    end
else
    delete_mask = ismember(first_chars,first_chars_ignore);
end
end

