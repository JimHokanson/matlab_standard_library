function navToPath(file_or_folder_path)
%
%   sl.os.navToPath(file_or_folder_path)
%
%
%   IMPROVEMENTS:
%   =======================================================================
%   1) Documentation
%   2) File support for unix and macs
%   3) Provide root support - show folder in parent folder

%Resolution to file or folder
%--------------------------------------------------------------------------
if exist(file_or_folder_path,'file')
    file_path = file_or_folder_path;
    is_file = true;
elseif exist(file_or_folder_path,'dir')
    folder_path = file_or_folder_path;
    is_file = false;
else
    error('Specified file/folder not found')
end

if is_file
    if ispc
        %http://support.microsoft.com/kb/152457
        system(['explorer.exe /select,' file_path]) 
    else
        error('Function not yet expanded to support current os')
    end
else
    if ispc
        winopen(folder_path)
    elseif ismac
        system(['open ' folder_path]);
    elseif isunix
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