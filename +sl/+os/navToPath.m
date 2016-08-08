function navToPath(file_or_folder_path,varargin)
%navToPath  Opens os file-viewer to folder or file
%
%   sl.os.navToPath(file_or_folder_path)
%
%   Opens the specified file or folder using a file-system viewer, i.e.:
%       Windows Explorer
%       Apple Finder
%       etc.
%
%   Files are shown in their containing folder. 
%
%   Folders are opened directly (not shown in their parent). 
%
%   Inputs:
%   -------
%   file_or_folder_path : The path to a file or a folder.
%
%   Optional Inputs:
%   ----------------
%   
%
%   Improvements:
%   -------------
%   1) Documentation
%   2) File support for unix and macs
%
%   See Also:
%   ---------
%   sl.str.create_clickable_cmd.navigateToFileInOS

DIRECTORY_EXISTS_RESULT = 7;

in.open_folder = false;
in = sl.in.processVarargin(in,varargin);

%Resolution to file or folder
%--------------------------------------------------------------------------
exist_result = exist(file_or_folder_path,'file');
if exist_result == DIRECTORY_EXISTS_RESULT    
    folder_path = file_or_folder_path;
    is_file     = false;
elseif exist_result
    file_path = file_or_folder_path;
    is_file   = true;
else
    error_msg = sl.error.getMissingFileErrorMsg(file_or_folder_path);
    error(error_msg);
end

if is_file
    if ispc
        %http://support.microsoft.com/kb/152457
        %There are other options available ...
        %NOTE: winopen will open the file using the default application
        %which is not what we want
        system(['explorer.exe /select,"' file_path '"']);

    elseif ismac
        %Do I need to escape the file path somehow?
        system(['open -R ' file_path]);
    else
        error('Function not yet expanded to support current os')
    end
else
    if ispc
        if in.open_folder
            system(['explorer.exe /root,"' folder_path '"']);
        else
            system(['explorer.exe /select,"' folder_path '"']);
        end
    elseif ismac
        system(['open ' folder_path]);
    elseif isunix
        %?? - from Chris
        [~,res] = system('which nautilus');
        if ~isempty(strfind(res,'no'))
            formattedWarning('Could not find Nautilus')
        end
        % need to deliberately set the LD_LIBRARY_PATH because matlab contains
        % it own libstdc++ that is incompatible!
        system(['LD_LIBRARY_PATH=/usr/lib/:$LD_LIBRARY_PATH nautilus ', folder_path]);
    end
end

end