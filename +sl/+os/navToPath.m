function navToPath(file_or_folder_path)
%navToPath  Opens os file-viewer to folder or file
%
%   sl.os.navToPath(file_or_folder_path)
%
%   Opens the specified file or folder using a file-system viewer (i.e.
%   Windows explorer, Apple navigator??, etc.) 
%
%   Files are shown in their containing folder. 
%
%   Folders are opened directly (not shown in their parent). 
%
%   INPUT
%   =======================================================================
%   file_or_folder_path : The path to a file or a folder.
%
%   IMPROVEMENTS:
%   =======================================================================
%   1) Documentation
%   2) File support for unix and macs
%   3) Provide root support - show folder in parent folder
%
%   See Also:
%   winopen

%in.show_folder_in_parent = true;
%in = sl.in.processVarargin(in,varargin);

%Resolution to file or folder
%--------------------------------------------------------------------------
%NOTE: exist dir tests for file or folder :/
%We need to first test for a file, then test for a folder ...
if exist(file_or_folder_path,'file')
    file_path = file_or_folder_path;
    is_file   = true;
elseif exist(file_or_folder_path,'dir')
    folder_path = file_or_folder_path;
    is_file     = false;
else
    error('Specified file/folder not found')
end

if is_file
    if ispc
        %http://support.microsoft.com/kb/152457
        %There are other options available ...
        %NOTE: winopen will open the file using the default application
        %which is not what we want ...s
        system(['explorer.exe /select,' file_path]);

    else
        error('Function not yet expanded to support current os')
    end
else
    if ispc
        winopen(folder_path)
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