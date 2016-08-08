function varargout = pm(fid, varargin)
%pm Project Manager
%
%   Installation:
%
%       Caution:
%
%       ** project manager resets your 'userpath' frequently. If you
%       don't know about 'userpath', never mind. If you control your
%       'userpath' extensively, reconsider using this program. Otherwise,
%       it is highly recommended to use the default Matlab 'userpath'. See
%       'help userpath' for more detail.
%
%       ** You can use automatic installation feature if you don't have
%       any complex customized startup.m/finish.m in many scattered places.
%       If you do have many startup.m/finish.m, renaming those is highly
%       recommended (such as startup_local.m/finish_local.m) and centralize
%       startup.m/finish.m in the Matlab default "userpath" folder.
%       If you want to keep many startup.m/finish.m files in different
%       folders, then please read manual installation part to use Project
%       Manager.
%
%       If your startup.m/finish.m is centeralized or you don't have it,
%       then you can use the following command to install Project Manager.
%
%           >> cd(path_to_downloaded_pm.m);
%           >> pm('install');
%
%   Warning - before you install manually:
%       First run the following code if you use manual installation.
%       If that gives you 'Sorry...', then do not use 'pm.m'. (Sorry...)
%
%           >> pm 
%
%       If it says your system looks compatible, then run the following
%       command first before using pm.m to save your current project.
%       When you save, be sure that you place the project file
%       in your project root directory.
%
%           >> pm('save_project')
%
%       If you don't run it, it may close all your documents, delete path
%       information though all of these will be saved in
%       'temp_pm_backup_<date,time>.mat' in the current directory. In
%       case you want to recover all of them, just open it using :
%
%           >> pm('open_project',backup_file_name)
%
%       Furthermore, pm.m does not automatically delete temporary backup
%       files. You should remove them occasionally. (Use 'clear_backup'
%       token.)
%
%       If you copied a project folder from other systems, then path
%       information might be different from the original one. You should
%       modify '<MyProjectName>_pathdef.m' file in the folder accordingly
%       before opening it in your matlab.
%
%       Note that the behavior of 'close_project' token has been modified.
%       
%
%   Manual installation:
%       1. Copy all files to a directory you want. Add it to the MATLAB path.
%       2. For full functionality, give it write permission.
%       3. See startup_sample.m and finish_sample.m for automation.
%       4. Run command
%           >> pm('save_project')
%       
%   Features:
%       'pm', which is a very simple and loose project manager, saves only the
%       following information for each project that is necessary to switch
%       between projects :
%         - Current working directory
%         - Project specific Path
%         - All opened m-files (order is not guaranteed in pm.)
%         - Current active m-file.
%
%       * I don't have Simulink and so can't imagine how 'pm' will work in Simulink.
%
%   Usage examples:
%       The first argument to pm.m is a token of action. The second or
%       later arguments are related to that token. There are ten tokens.
%
%          'save_project'
%          'open_project'
%          'new_project'
%          'current_project'
%          'close_project'
%          'backup'
%          'clear_backup'
%          'startup_pm'
%          'finish_pm'
%          'pm_test'
%          'make_a_shortcut_of_the_current_project'
%          'install'
%          'uninstall'
%
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       %% Save project
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       pm('save_project')  % opens a dialog box to select a project file
%                           % or saves the current project.
%       pm('save_project','') % save current project (or workspace) as a
%                             % new project (Save as new...)
%       pm('save_project','my_pm.mat') % saves the project in 'my_pm.mat'
%                                      % into the current working directory.
%       pm('save_project','c:\projects\proj1\my_pm.mat')
%                                      % you can specify the full path and
%                                      % name of the project file.
%
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       %% Open project
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       pm('open_project')             % opens a dialog box
%       pm('open_project','my_pm.mat')
%       pm('open_project','c:\projects\proj1\my_pm.mat')
%
%       pm('open_project','',0)  % the same as pm('open_project')
%       pm('open_project','',1)  % Paths to opened documents outside the
%                                % project root directory will be absolute.
%       pm('open_project','my_pm.mat',1)
%
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       %% New project
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       pm('new_project')              % opens a dialog box
%       pm('new_project','my_pm.mat')  % makes a new project named
%                                      % 'my_pm.mat' in the current directory
%       pm('new_project','c:\projects\proj1\my_pm.mat') % another example.
%
%       keep_path = 1;
%       pm('new_project','',keep_path)  % make a new project but keep the path of
%                                       % the previoius project or previous workspace.
%           % default value of keep_path is 0.
%
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       %% Get the name of the current project
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       pm('current_project') % shows the path to the current project.
%
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       %% Close project (note: behavior is different from the old version.
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       pm('close_project')   % closes current project, document, keep the
%                             %  current path information.
%
%       close_doc = 0;
%       keep_path = 0;
%       pm('close_project', close_doc, keep_path)
%                             % closes current project, does not close
%                             %  documents, and reset path information to 
%                             %  system default using 'restoredefaultpath'.
%                             
%           % default value of close_doc is 1, keep_path is 1.
%                             
%
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       %% Clear backup files starting with 'temp_pm_backup_*'
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       pm('clear_backup')
%
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       %% Check compatibility (it is a simple test and not guaranteed).
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       pm('pm_test')
%
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       %% Install/uninstall
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       pm('install')       % automated installation
%       pm('uninstall')     % shows information about how to remove pm.m
%
%
%   VERY Useful Shortcuts: <a href="matlab: web([docroot '/techdoc/matlab_env/bq37azl-1.html#bq37azl-6'])">MATLAB shortcuts</a>
%       pm.m is most useful when you add shortcuts in the matlab toolbar.
%       Here are a few examples that I use.
%
%       - Open
%           pm('open_project')
%
%       - Save
%           pm('save_project')
%
%       - Save as...
%           pm('save_project','')
%
%       - Close project
%           pm('clost_project')
%
%       - My project 1
%           pm('save_project')  % automatic save of the current project
%           pm('open_project','C:\projs\pj1\project_myprj_1.mat');
%
%       - My project 2
%           pm('save_project')
%           pm('open_project','C:\projs\pj2\project_myprj_2.mat');
%
%       - Clean-up
%           clear import; clear variables; close all hidden; clc;
%           pm('clear_backup');
%
%   Automation on quit or startup MATLAB:
%       - You can use 'startup.m' or 'finish.m' to automate the project
%           management when you startup or quit MATLAB. Use corresponding
%           token: 'startup_pm', 'finish_pm'.
%           See <a href="matlab: edit startup_sample">startup_sample.m</a> and <a href="matlab: edit finish_sample.m">finish_sample.m</a>.
%           See also <a href="matlab: doc startup.m">startup.m</a>, <a href="matlab: doc finish.m">finish.m</a>.
%       - Warning: To use this feature: 1. the directory containing 'pm.m'
%           must have write permission, because exit information is saved
%           in it. 2. The directory containing 'startup.m' and 'finish.m'
%           always must be in matlab search path (during startup MATLAB and
%           exiting MATLAB).
%
%   Notes:
%       - pm.m should be in the path.
%       - It does not clear the workspace.
%       - It does not save the workspace.
%       - You have to save all current documents to open another project.
%       - When open a new project, it does not automatically save the
%           current project. If you want automation, use shortcuts. See
%           above.
%       - Saving project will generate path file like my_pm_pathdef.m
%           Keep this in the same directory as the project file (my_pm.mat).
%       - paths to the opened m-files that are in the project root folder
%           or subdirectories of the project root folder are all relative
%           path. So, you can move whole project directory together. But
%           paths to other files that is outside of the root project folder
%           are absolute paths by default. You can make all paths relative.
%           See Usage examples above. <a href="matlab: web([docroot '/toolbox/slvnv/ug/f45716.html#f53374'])">Resolving the document path</a>
%       - Related to the previous path issue, all MATLAB path will be saved
%           as an absolute path. So if you move your project directory
%           somewhere and you've had subdirectories in your path, you need
%           to add those subdirectories again after you move your project,
%           and save the project.
%       - Current working directory is saved as relative path to the
%           project root directory IF it is a subdirectory of it, otherwise
%           it is saved as an absolute path.
%       - 'new_project', 'close_project', 'open_project' do not
%           automatically save current project, but they do backup.
%
%   Caution:
%       1. pm.m add its directory to path. So you may want to place pm.m in
%           some other general-purpose-tool folder something like 'Matlab
%           Central File Exchange' folder.
%       2. Docuemnt order in the editor is not guaranteed to be correctly
%           saved, because I couldn't find a service function that returns
%           the order of the documents. So, this may not work in other
%           MATLAB versions. In this situation, instead, you can arrange
%           documents as you want, close MATLAB, open MATLAB, and save
%           project again. This is clumsy, but it works because MATLAB
%           reload previous opened documents in the order.
%       3. The following builtin editor services are used. They are not
%           documented, and highly prone to the version of MATLAB. If these
%           services are not supported in your version of MATLAB, pm.m does
%           not work at all. pm('pm_test') checks these services. These
%           were added from the version of R2011a. If you have an earlier
%           version of Matlab, use older version of pm.m.
%               e = matlab.desktop.editor.getAll
%               e(i).Modified
%               e.close
%               matlab.desktop.editor.getActiveFilename
%               com.mathworks.mlwidgets.shortcuts.ShortcutUtils
%       4. The following two functions are documented. But they were added
%           recently. As far as I know, R2007a supports them, but my old
%           MATLAB 7.1 (2005) didn't support it.
%               setenv
%               getenv
%
%   See also:
%       <a href="matlab: doc startup.m">startup.m</a>
%       <a href="matlab: doc finish.m">finish.m</a>
%       <a href="matlab: web([docroot '/techdoc/matlab_env/bq37azl-1.html#bq37azl-6'])">MATLAB shortcuts</a>
%       <a href="matlab: web([docroot '/techdoc/matlab_env/brqxeeu-131.html#brqxeeu-140'])">Run Configurations</a>
%       <a href="matlab: web([docroot '/toolbox/slvnv/ug/f45716.html#f53374'])">Resolving the document path</a>



%% Pick the function corresponding to the given action token.
% Token name is the sub-function name. The following codes arrange other
% input arguments as input to the sub-function.

if ~exist('fid','var')
    OK=pm_test(); % Default action when there is no token.
%     if OK
%         disp(' ');
%         disp('=========================================================');
%         help pm;
%         disp('WARNING: run the following command first before you use pm.m, ');
%         disp('         otherwise it will close all your documents.');
%         disp('  >> pm(''save_project'')');
%         disp(' ');
%         disp('Enjoy~!');
%     end
    return;
end


fh = str2func(fid);
[varargout{1:nargout}] = fh(varargin{:});
userpath('reset');

end % function

% Generate testing m-file.


function install()
addpath(fileparts(which('pm.m')));
pm_installer();
end

function uninstall()
pm_installer('uninstall');
end

function make_a_shortcut_of_the_current_project()
pm_installer('make_a_shortcut_of_the_current_project');
end



function OK=pm_test()
% This function tests compatibility.
% There should not be any error.
% This test does not test 'closeAll'.
OK=1;
disp(' ');
disp('=========================================================');
disp('Checking editor services...');
try
    myEdit('pm.m');
catch
    disp('Cannot use ''edit'' or ''matlab.desktop.editor.openDocument'' function.');
    OK=0;
end
try
    e=matlab.desktop.editor.getAll;
catch
    disp('Cannot find matlab.desktop.editor.getAll function.');
    OK=0;
end
try
    e=matlab.desktop.editor.getActive;
catch
    disp('Cannot find matlab.desktop.editor.getActive function.');
    OK=0;
end
try
    e=matlab.desktop.editor.getActiveFilename;
catch
    disp('Cannot find matlab.desktop.editor.getActiveFilename function.');
    OK=0;
end
try
    e=matlab.desktop.editor.getActive;
    if length(e)>0
        a=e.Modified;
    else
        myEdit('pm.m');
        e=matlab.desktop.editor.getActive;
        a=e.Modified;
    end
catch
    disp('Cannot find matlab.desktop.editor.getAll->Modified property.');
    OK=0;
end

if ~OK
    disp('=========================================================');
    disp(' ');
    disp('Sorry. You cannot use pm.m');
    return;
end

k=matlab.desktop.editor.openDocument(which('pm.m'));
k.close;



OK2=1;

disp('Checking MATLABDesktop.xml');
f = fullfile(prefdir,'MATLABDesktop.xml');
if ~exist(f,'file')
    disp('There is not MATLABDesktop.xml. Document order cannot be saved.');
    OK2=0;
else
    text = fileread(f);
    
    c = which('pm.m');
    if isempty(strfind(text,c))
        disp('Document order may not be correctly saved.');
        OK2=0;
    end
end

try
    e=com.mathworks.mlwidgets.shortcuts.ShortcutUtils;
catch
    disp('Cannot find com.mathworks.mlwidgets.shortcuts.ShortcutUtils.');
    disp('Shortcuts might not be automatically added. Or you should restart Matlab whenever new shortcuts are added.');
    OK=0;
end


% disp('Checking run_configurations.xml');
% config_list = parseConfigs();
% if isnumeric(config_list)
%     disp('Sorry. You cannot use unit-testig.');
%     OK2=0;
% end
disp('=========================================================');
disp(' ');
if OK2
    disp('You system looks compatible.');
else
    disp('You system looks compatible although some features are not guaranteed.');
end
end % function




function new_project(pm_filename, keep_path)
if ~exist('keep_path','var') || isempty(keep_path)
    keep_path = 0;
end
%% Project filename
clc;
if ~exist('pm_filename','var')
    pm_filename = '';
end
[valid,pm_path,pm_name] = my_fileparts(pm_filename,'write','Create a New Project');
if valid==0
    disp('Not a valid project filename');
    return;
end
clear pm_filename;
backup();

%% 1. Close all documents
myCloseAll();

%% 2. Go to the project root directory.
cd(pm_path);
% edit;

%% 3. Set path
if ~keep_path
    pm_path = fileparts(which('pm.m'));
    restoredefaultpath;
    addpath(pm_path);
    savepath;
    userpath('reset');
    % up = userpath;
    % cd(up);
end
addpath(fileparts(mfilename('fullpath')));

%% 4. Save
% Then save the file.
pm('save_project',fullfile(pm_path,[pm_name,'.mat']));

disp(['New project [ ',pm_name,' ] is generated.']);
disp('Use "clear import" to clear only imported java packages.');
disp('Use "clear variables" to clear variables in previous workspace.');
disp('Use "clear all" to clean everything.');
disp('Use "close all" to close all previous figures.');

end % function




function close_project(close_doc, keep_path)
if ~exist('close_doc','var') || isempty(close_doc)
    close_doc = 1;
end
if ~exist('keep_path','var') || isempty(keep_path)
    keep_path = 1;
end
clc;
backup();

a=getenv('matlab_pm_current_project');
if isempty(a)
    disp('No project is currently open.');
    disp('If you belive you''re seeing an opened project, save it first.');
    return;
end
[pm_path, pm_name] = fileparts(a);

%% 1. Close all documents
if close_doc
    myCloseAll();
end

%% 2. Set path
if ~keep_path
    pm_path = fileparts(which('pm.m'));
    restoredefaultpath;
    addpath(pm_path);
    savepath;
    userpath('reset');
    up = userpath;
    cd(up(1:end-1));
end
addpath(fileparts(mfilename('fullpath')));

%% 3. Clear the env variable.
setenv('matlab_pm_current_project','');

disp(['Project [ ',pm_name,' ] is closed.']);
disp('Use "clear import" to clear only imported java packages.');
disp('Use "clear variables" to clear variables in previous workspace.');
disp('Use "clear all" to clean everything.');
disp('Use "close all" to close all previous figures.');
end % function



function a=current_project()
a=getenv('matlab_pm_current_project');
if isempty(a)
    disp('No project is open.');
else
    [pm_path,pm_name]=fileparts(a);
    disp(['Project name: ', pm_name]);
    disp(['Project file: ', a]);
    disp(['Project path is saved in: ', a(1:end-4), '_pathdef.m' ]);
end
end % function



function save_project(pm_filename,makeAllPathRelative,quiet_save,backup_mode)
if ~exist('backup_mode','var') || isempty(backup_mode)
    backup_mode = 0;
end
if ~exist('quiet_save','var') || isempty(quiet_save)
    quiet_save = 0;
end
if ~exist('makeAllPathRelative','var') || isempty(makeAllPathRelative)
    makeAllPathRelative = 0;
end
current_p=pwd;
%% Project filename
if ~exist('pm_filename','var')
    s=getenv('matlab_pm_current_project');
    if isempty(s)
        pm_filename = '';
    else
        pm_filename = s;
    end
end
[valid,pm_path,pm_name] = my_fileparts(pm_filename,'write','Save Project As...');
if valid==0
    disp('Not a valid project filename');
    return;
end
clear pm_filename;

if exist(fullfile(pm_path,[pm_name,'.mat']), 'file')
    load(fullfile(pm_path,[pm_name,'.mat']));
end

%% Collect project information
% 1. path of the current working directory
tmp_cp = pwd;
if length(pm_path)<length(tmp_cp) && strfind(tmp_cp,pm_path)
    a=pm('myMakeRelativePath',pwd,pm_path,[],[],0); % Make relative.
    tmp_cp = a{1};
elseif strcmp(pm_path,tmp_cp)
    tmp_cp = '.';
end
pm_info.project_current_directory = tmp_cp;

% 2. information of opened m-files
[pm_info.opened_mfiles, pm_info.active_mfile] = getEditorInfo(pm_path, makeAllPathRelative);

% 3. matlab path information
% pm_info.path = path;
cd(pm_path);
savepath([pm_name,'_pathdef.m']);
cd(pm_info.project_current_directory);

% 4. Add current project root path information for future use...
pm_info.last_project_root_directory = pm_path;

%% Save
% Then save the file.
save(fullfile(pm_path,[pm_name,'.mat']), 'pm_info');
if ~backup_mode
    setenv('matlab_pm_current_project',fullfile(pm_path,[pm_name,'.mat']) );
end
if ~quiet_save
    disp(['Project [ ',pm_name,' ] is saved at: ']);
    disp(['  ',fullfile(pm_path,[pm_name,'.mat'])]);
    disp(['  ',fullfile(pm_path,[pm_name,'_pathdef.m'])]);
end
cd(current_p);
end %function




function open_project(pm_filename,quiet_open,open_documents,startup_mode)
if ~exist('startup_mode','var') || isempty(startup_mode)
    startup_mode = 0;
end
if ~exist('quiet_open','var') || isempty(quiet_open)
    quiet_open = 0;
end
if ~exist('open_documents','var') || isempty(open_documents)
    open_documents = 1;
end
%% Project filename
if ~exist('pm_filename','var')
    pm_filename = '';
end
[valid,pm_path,pm_name] = my_fileparts(pm_filename,'read','Open Project');
if valid==0
    disp('Not a valid project filename');
    return;
end
%clc;
clear pm_filename;
if ~startup_mode ; backup(quiet_open); end

if strcmp(getenv('matlab_pm_current_project'),fullfile(pm_path,[pm_name,'.mat']) )
    disp(['Project [ ',pm_name,' ] is already open.']);
    disp(['If you believe you open different project, then close current project first.']);
    return;
end

%% Close all m-files before opening a project.
if open_documents
    myCloseAll();
end
setenv('matlab_pm_current_project','') % Clear this first for safety.
 
%% Load project information
cd(pm_path);
load([pm_name,'.mat']);

%% Configure project

% 1. Set path for the project
% path(pm_info.path);
cd(pm_path);
if exist([pm_name,'_pathdef.m'],'file')
    if isfield(pm_info,'last_project_root_directory')
        last_project_root_directory = pm_info.last_project_root_directory;
    else
        last_project_root_directory = pm_path;
    end
    if ~isempty(last_project_root_directory) && ...
            ~strcmp(last_project_root_directory, pm_path) % Adjust path
        disp('============================================');
        disp('Detected project root directory change.');
        disp('Modifying path information');
        disp('============================================');
        path_str = eval([pm_name,'_pathdef']);

        
%         while 1
%             a=strfind(path_str,last_project_root_directory);
%             if isempty(a); break;  end
%             path_str = [path_str(1:a(1)-1), pm_path,path_str(a(1)+length(last_project_root_directory):end)];
%         end
        path_str = strrep(path_str,last_project_root_directory,pm_path);
        

        path(path_str);
    else
        path( eval([pm_name,'_pathdef'])  );
    end
else
    warning(['There must be [ ', pm_name,'_pathdef.m ] file in the same directory as project file']);
    disp('By default, it uses the path of the previous project.');
    disp('If you want to use system default, use the command "restoredefaultpath".');
end


% 2. Open m-files for the project
cd(pm_path);
if open_documents
    applyEditorInfo(pm_info.opened_mfiles, pm_info.active_mfile)
end


% 3. Go to the last working directory
cd(pm_info.project_current_directory);

if ~quiet_open
    disp(['Project [ ',pm_name,' ] is loaded.']);
    disp('Use "clear import" to clear only imported java packages.');
    disp('Use "clear variables" to clear variables in previous workspace.');
    disp('Use "clear all" to clean everything.');
    disp('Use "close all" to close all previous figures.');
end

setenv('matlab_pm_current_project',fullfile(pm_path,[pm_name,'.mat']) );

end %function




function pm_filename=backup(quiet_backup)
if ~exist('quiet_backup','var') | isempty(quiet_backup)
    quiet_backup = 0;
end

p=getenv('matlab_pm_current_project'); % save current project name
d=getenv('matlab_pm_startup_directory');

c=clock;
pm_datetime = ['temp_pm_backup_', ...
    num2str(floor(c(1))),'y_',num2str(floor(c(2))),'m_',num2str(floor(c(3))),'d_', ...
    num2str(floor(c(4))),'h_',num2str(floor(c(5))),'m_',num2str(floor(c(6))),'s.mat'];

if ~quiet_backup
    disp('Project backup is in progress ...');
    disp(['  backup id: ',pm_datetime(1:end-4)]);
end

if isempty(p)
    if isempty(d)
        pm_filename = fullfile(pwd,pm_datetime);
    else
        pm_filename = fullfile(d,pm_datetime);
    end
else
    [pm_path,pm_name]=fileparts(p);
    pm_filename = fullfile(pm_path,[pm_name,'_',pm_datetime]);
end
backup_mode = 1;
save_project(pm_filename,'',quiet_backup,backup_mode);
setenv('matlab_pm_current_project',p);

if ~quiet_backup
    disp('Backup is done.');
    disp(' ');
end
end % function



function clear_backup(quiet_clear)
if ~exist('quiet_clear','var') | isempty(quiet_clear)
    quiet_clear = 0; % so it is verbose.
end
disp('Deleting project backup files ...');
a=input('Do you want to continue (y/n)? ','s');
if ~strcmp(lower(a),'y')
    disp('Canceled');
    return;
end
p=getenv('matlab_pm_current_project');
d=getenv('matlab_pm_startup_directory');
delete(fullfile(p,'*temp_pm_backup_*'));
delete(fullfile(d,'*temp_pm_backup_*'));
delete('*temp_pm_backup_*'); % delete all temp files in the current directory.
if ~quiet_clear
    disp('Done.');
end
end % function



function startup_pm()
%disp('project manager starts...');
setenv('matlab_pm_startup_directory',pwd);
pack_path = fileparts(which('pm.m'));
setenv('matlab_pm_package_directory',pack_path);
current_path = pwd;
cd(pack_path);
quiet_open = 1;
if exist('matlab_pm_exit_info.mat','file')
    load matlab_pm_exit_info;
    %last_project
    %pause;
    if exist(last_project,'file')
        if ~exist('save_success','var') || isempty(save_success) || save_success==0
            disp('The last Matlab instance has not properly finished.');
            disp(' (or, there could be another Matlab instance, too.)');
            reply = input('Do you want to re-open files (y/n)?','s');
            if strcmpi(reply,'y')
                open_documents = 1;
            else
                open_documents = 0;
            end
        elseif save_success==1
            if pm('check_startup_filelist',last_project)
                open_documents = 0; % exploit MATLAB's internal mechanism. With this '0', it'll keep previously opened files open.
            else
                open_documents = 1;
            end
        else
            error('What''s going on??? #424234');
        end
        save_success=0;
        save matlab_pm_exit_info last_project save_success;
        startup_mode = 1;
        pm('open_project',last_project,quiet_open,open_documents,startup_mode);
        if ~isempty(strfind(last_project,'temp_pm_backup_'))
            setenv('matlab_pm_current_project','');
        else
            [pm_path,pm_name] = fileparts(last_project);
            disp(['Project [ ',pm_name,' ] is loaded.']);
            disp('Use "clear import" to clear only imported java packages.');
            disp('Use "clear variables" to clear variables in previous workspace.');
            disp('Use "clear all" to clean everything.');
            disp('Use "close all" to close all previous figures.');
        end
    else
        cd(current_path);
        disp(['Cannot locate project file: ',last_project]);
        disp('The last project is not successfully loaded.');
    end
else
    cd(current_path);
    disp('Cannot locate ''matlab_pm_exit_info.mat''.');
    disp('The last project is not successfully loaded.');
end
quiet_clear =1;
%clear_backup(quiet_clear);
%disp('project manager startup is done.');
end % function



function finish_pm()
p=getenv('matlab_pm_current_project');
d=getenv('matlab_pm_package_directory');
%clear_backup();
if ~isempty(p)
    pm('save_project');
    last_project = p;
else
    last_project = pm('backup');
end
a=pwd;
if ~isempty(d)
    cd(d);
else
    k=fileparts(which('pm.m'));
    if ~isempty(k)
        cd(k);
    end
end
save_success=1;
save matlab_pm_exit_info last_project save_success;
cd(a);
end % function


function yes = isSaved()
p=getenv('matlab_pm_current_project');
if isempty(p)
    yes=0;
end
[pm_path,pm_name] = fileparts(p);

%% Get old project information
load(p);
pm_info_old = pm_info;
a=pwd;
cd(pm_path);
old_path=eval([p_name,'_pathdef']);
cd(a);
clear pm_info;

%% Gather new project information
makeAllPathRelative = 0; % Need to check if old file neams are relative or absolute paths.
od = pm_info_old.opened_mfiles;
for i=1:length(od)
    if strcmp(od{i}(1:2),'..')
        makeAllPathRelative = 1;
        break;
    end
end
pm_info_new.project_current_directory = pwd;
[pm_info_new.opened_mfiles, pm_info_new.active_mfile] = pm('getEditorInfo',pm_path,makeAllPathRelative);
new_path = path;

%% Current working directory comparison
if ~strcmp(pm_info_old.project_current_directory, pm_info_new.project_current_directory)
    yes=0;
    return;
end
%% Compare opened documents
od = pm_info_old.opened_mfiles;
nd = pm_info_new.opened_mfiles;
for i=1:min(length(od),length(nd))
    if ~strcmp(od{i},nd{i})
        yes=0;
        return;
    end
end
%% Compare active docuemnt
if ~strcmp(pm_info_old.active_mfile{1}, pm_info_new.active_mfile{1})
    yes=0;
    return;
end
%% Compare path
if ~strcmp(old_path, new_path)
    yes=0;
    return;
end
%% Everything is OK.
yes=1;
end % function



function unit_test_project_edit()
pm_filename=getenv('matlab_pm_current_project');
if isempty(pm_filename)
    disp('No project is open.');
    return;
end
load(pm_filename);
pm_info.filename = pm_filename;
pm_ut(pm_info);
end % function

function unit_test_project()
pm_filename=getenv('matlab_pm_current_project');
if isempty(pm_filename)
    disp('No project is open.');
    return;
end
load(pm_filename);
if ~isfield(pm_info, 'test_suite') | isempty(pm_info.test_suite)
    disp('No run configuration is selected for batch run.');
    return;
end

all_configs = parseConfigs();
if isnumeric(all_configs)
    disp('No run configuration in your MATLAB.');
    return;
end

% exclude non-existent one.
test_suite = pm_info.test_suite;
for tsi = length(test_suite):-1:1
    t = test_suite(tsi);
    ok=0;
    for cci=1:length(all_configs)
        c = all_configs(cci);
        % TODO: this portion is version sensitive.
        if strcmp(t.id, c.id) %strcmp(t.name,c.name) && strcmp(t.file,c.file) && strcmp(t.id, c.id)
            ok=1;
            test_suite(tsi) = c; % Copy the most recent configuration.
            break;
        end
    end
    if ~ok
        test_suite(tsi)=[];
    end
end
handles.test_suite = test_suite;


[pm_path,pm_name]=fileparts(pm_filename);
runTestSuite(test_suite,pm_path,pm_name);
end % function






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%
%%%%% Utility functions for pm.m
%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [valid,pm_path,pm_name,ext] = my_fileparts(pm_filename,read_or_write,title_str)
valid = 1;
%% If the pm_filename is empty, get one from the user.
if isempty(pm_filename)
    if strcmp(read_or_write,'read')
        [FileName,PathName] = uigetfile('*.mat',title_str);
    elseif strcmp(read_or_write,'write')
        [FileName,PathName] = uiputfile('*.mat',title_str);
    end
    if FileName==0
        valid=0; pm_path=''; pm_name=''; ext=''; versn='';
        return;
    end
    pm_filename = fullfile(PathName,FileName);
end

%% Check the integrity of the pm_filename
[pm_path,pm_name] = fileparts(pm_filename); % extract path and name. (pm_path can be empty and relative)
pm_filename = fullfile(pm_path,[pm_name,'.mat']); % filename with path and .mat extension
if ~exist(pm_filename,'file')
    if strcmp(read_or_write,'read') % If we are reading from a project file, and if there is not the file, it is error.
        error(['The file, ',pm_filename,', does not exist']);
    elseif strcmp(read_or_write,'write')
        save(pm_filename,'pm_filename'); % If not, make one.
    end
end

%% Get the full path.
% We need full path, not the relative path. Therefore, we need the
% following steps.
if ~isempty(pm_path)
    cd(pm_path); % move to the pm_path if it is not the current directory.
end
pm_filename = which([pm_name,'.mat']); % Get the full-path filename.
[pm_path,pm_name,ext] = fileparts(pm_filename); % Extract path and name.

end %function



function myCloseAll()
% e is the handle to the editor.

% get the list of opened files.
openDocuments = matlab.desktop.editor.getAll;

% If any document is not saved, generate error.
dirty = 0;
for i=1:length(openDocuments)
    dirty = dirty + openDocuments(i).Modified;
%     if ~exist(files(i,:),'file')
%         dirty = dirty + 1;
%     end
end
if dirty > 0
    disp(' ');
    disp('Failed to open/save the project. Save m-files first.');
    disp(' ');
    error('Save files');
end

openDocuments.close;

end % function



function [opened_mfiles, active_mfile] = getEditorInfo(pm_path, makeAllPathRelative)
of = matlab.desktop.editor.getAll;
cl = {};
for i=1:length(of)
    cl{end+1} = of(i).Filename;
end
opened_mfiles = myMakeRelativePath(cl,pm_path,[],[],makeAllPathRelative);
active_mfile  = myMakeRelativePath(matlab.desktop.editor.getActiveFilename,pm_path,[],[],makeAllPathRelative);
end % function



function applyEditorInfo(opened_mfiles, active_mfile)
for i=1:length(opened_mfiles)
    if exist(opened_mfiles{i},'file')
        myEdit(opened_mfiles{i});
    else
        warning(['No such file :  ', opened_mfiles{i}]);
    end
end
% Open active file.
if exist(active_mfile{1}, 'file')
    myEdit(active_mfile{1});
else
    warning(['No such file :  ', active_mfile{1}]);
end
end % function




function cl = myMakeRelativePath(cl,rp,prefix,ie,makeAllPathRelative)
% This function generates relative path relative to a given root path.
%   cl: char file list
%   rp: root path
%   ie: indices of excluded paths for modification.
% For example, if a file is in 'C:\a\b\c\m.m' and the root path is 'C:\a',
% then it returns 'b\c\m.m'.
%

% change char to cell
if ischar(cl)
    k={};
    for i=1:size(cl,1)
        c = cl(i,:);
        for j=length(c):-1:1 % chomp
            if isspace(c(j))
                c(j)=[];
            else
                break;
            end
        end
        k{i} = c;
    end
    cl=k;
    cl = myGetCorrectOrder(cl);
elseif iscell(cl)
    cl = myGetCorrectOrder(cl);
end
if ~exist('prefix','var')
    prefix='';
end
if ~exist('ie','var')
    ie=[];
end



com_type = computer;

if strcmp(com_type(1:3), 'PCW')
    %% Lower the case??
    % Here Windows system is assumed. For other systems, change accordingly.
    % rp = lower(rp);
    rp(rp=='/')='\'; % set the fileseparator to Windows system.
    if rp(end)=='\' % remove the fileseparator at the end, if any.
        rp(end)=[];
    end
    
    im=[]; % indices of modified paths.
    rl = length(rp);
    for i=1:length(cl)
        if any(i==ie)
            continue;
        end
        c = cl{i};
        %     c=lower(c);
        c(c=='/')='\';
        if length(c)>rl && strcmp(c(1:rl),rp) % If the path includes root path, then it will be changed to relative path.
            cl{i} = [prefix,cl{i}(rl+2:end)];
            im=[im,i];
        end
    end
elseif strcmp(com_type(1:3), 'GLN') || strcmp(com_type(1:3), 'MAC') %assuming MAC or LINUX
    rp(rp=='\')='/'; % set the fileseparator to Windows system.
    if rp(end)=='/' % remove the fileseparator at the end, if any.
        rp(end)=[];
    end
    
    im=[]; % indices of modified paths.
    rl = length(rp);
    for i=1:length(cl)
        if any(i==ie)
            continue;
        end
        c = cl{i};
        %     c=lower(c);
        c(c=='\')='/';
        if length(c)>rl && strcmp(c(1:rl),rp) % If the path includes root path, then it will be changed to relative path.
            cl{i} = [prefix,cl{i}(rl+2:end)];
            im=[im,i];
        end
    end
    
end

% do recursively.
ie = [ie,im];
prefix = ['..',filesep,prefix];
[rp,t] = fileparts(rp);
if isempty(t)
    return;
end
if makeAllPathRelative
    cl = myMakeRelativePath(cl,rp,prefix,ie,makeAllPathRelative);
end
end %function




function cl = myGetCorrectOrder(cl)
%% Hack
% This function is totally a hack, because there is no documented or
% exposed information about this functionality. So it can be highly
% prone to the MATLAB version and future policy. Also it does not
% guarantee the functionality. (FIXIT if it is available in the future.)
f = fullfile(prefdir,'MATLABDesktop.xml');
if ~exist(f,'file')
    return;
end

text = fileread(f);

ind=1:length(cl);
for i=1:length(cl)
    a=strfind(text,cl{i});
    if ~isempty(a) && a(1)>0
        ind(i) = a(1);
    else
        if i==1
            ind(i) = -1000;
        else
            ind(i) = ind(i-1)+1;
        end
    end
end

[s,o]=sort(ind);

cl=cl(o);
end % function





function ok=check_startup_filelist(last_project)

load(last_project);
lp_om = pm_info.opened_mfiles;
cp_om = pm('getEditorInfo',fileparts(last_project), 0);

count = 0;
for i=1:length(lp_om)
    if any(ismember(cp_om,lp_om(i)))
        count = count+1;
    end
end

if length(lp_om)==0 && length(cp_om)==0 || count/length(lp_om) >= 0.8
    ok=1;
else
    ok=0;
    disp('More than 20% of opened documents does not match with the saved information.');
    disp('There might have been multiple instances of MATLAB running and');
    disp('the last instance might have closed unexpectedly.');
    disp('Reloading the last properly saved project file.');
end

end



function myEdit(filename)
try
    edit(which(filename));
catch
    matlab.desktop.editor.openDocument(which(filename));
end
end

% % % 
% % % function pos = strLinePos(str, newLine)
% % % %% This function returns line positions
% % % % This function can be used to divide str using 'newLine' as a delimiter.
% % % % You can use any string in 'newLine'.
% % % if isempty(str) % if there is no string, return empty result.
% % %     pos=[];
% % % end
% % % 
% % % if ~exist('newLine','var') | isempty(newLine)
% % %     f = fullfile(prefdir,'history.m');
% % %     if ~exist(f,'file')
% % %         warning('Cannot determine system specific newLine characters... Using Windows one...');
% % %         newLine = [char(13), char(10)];
% % %     else
% % %         tmp = fileread(f);
% % %         t=strfind(tmp,char(10));
% % %         if tmp(t(1)-1) == char(13)
% % %             newLine = [char(13), char(10)]; %% NOTE: see Terminator and follow links for more information.
% % %         end
% % %     end
% % % end
% % % 
% % % NLpos = strfind(str,newLine);
% % % sp = [1,NLpos+numel(newLine)]';
% % % ep   = [NLpos-1, length(str)]';
% % % pos = [sp,ep];
% % % end %function
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % % % %             % or find the error position from each file.
% % % % % %             % str = fileread(stack(si).file);
% % % % % %             % linePos = strLinePos(str);
% % % % % %             % err_pos = linePos(stack(si).line,:);
% % % % % %             % ec=str(err_pos(1):err_pos(2)); disp([ec]);
% % % % % %             
% % % % % %         %         linePos = strLinePos(codes);
% % % % % %         %         err_pos = linePos(stack(end).line,:);
% % % % % %         %         ec=codes(err_pos(1):err_pos(2));
% % % % % %         %         s=num2str(stack(end).line-1);
% % % % % %         %         ec = [s,repmat(' ',1,6-length(s))
% % % % % %         %         disp([ec]);
% % % % % %         
% % % % % % % % Check newLine character (Windows vs other OS)
% % % % % % % f = fullfile(prefdir,'run_configurations.m');
% % % % % % % if ~exist(f,'file')
% % % % % % %     config_list = -1;
% % % % % % %     return;
% % % % % % % end
% % % % % % % tmp = fileread(f);
% % % % % % % t=strfind(tmp,char(10));
% % % % % % % if tmp(t(3)-1) == char(13)
% % % % % % %     newLine = [char(13), char(10)]; %% NOTE: see Terminator and follow links for more information.
% % % % % % % end
% % % % % % 










function config_list = parseConfigs()
% This is also hack.
f = fullfile(prefdir,'run_configurations.m');
if ~exist(f,'file')
    config_list = -1;
    return;
end

text = fileread(f);
token = '%% @name';

pos = strfind(text,token);
pos(end+1) = length(text)+1;

for i=1:length(pos)-1
    % TODO: This portion is sensitive to matlab version.
    % Edit accordingly in the future.
    
    % extract information.
    
    % First run configuration.
    str = text(pos(i):pos(i+1)-1);
    % Extract name
    [a,b,c,m] = regexp(str, '%% @name.+','dotexceptnewline');
    if m{1}(end)==char(13)
        m{1}(end)=[];
    end
    name = m{1}(10:end);
    % or
    % name = regexp(str,'(?<=(%% @name\s+))\w+','match');
    
    % Extract filename
    [a,b,c,m] = regexp(str, '%  @associatedFile.+','dotexceptnewline');
    if m{1}(end)==char(13)
        m{1}(end)=[];
    end
    file = m{1}(20:end);
    
    % Extract code portion. b_end_id+3 is the start index of real
    % configuration.
    [a,b_end_id,c,m] = regexp(str, '%  @uniqueId.+','dotexceptnewline');
    if m{1}(end)==char(13)
        m{1}(end)=[];
    end
    if ~isempty(regexp(str, '@uniqueId'))
        id = m{1}(14:end);
    else
        config_list=-1;
    end
    
    config_list(i).name = name;
    config_list(i).file = file;
    config_list(i).id   = id;
    config_list(i).codes= str(b_end_id+4:end); %% Just pick portion that you can see in the run-configuration-editor.
end
end %function




function runTestSuite(test_suite,pm_path,pm_name)
%% Start of testing.
disp(' ');
disp('================================================================');
disp('================================================================');
disp(['Start of testing project [ ',pm_name,' ]']);
disp(['Project Path: ',pm_path]);
for tsi = 1:length(test_suite)
    %% Temporary file genearation for each 'run configuration'
    t = test_suite(tsi);
    fname = fullfile(pm_path,[pm_name,'_test.m']);
    fh=fopen(fname,'w');
    if fh==-1
        disp('Cannot open/write to temporary file for testing: ');
        disp(['   ',fname]);
        return;
    end
    fprintf(fh,'%s',t.codes);
    fclose(fh);
    clear([pm_name,'_test'])
    try
        rehash
    catch ME
        try
            rehash toolbox;
        catch ME1
            rethrow(ME1);
        end
    end
    
    %%
    disp('==========================');
    disp(['Running configuration name: ', t.name]);
    disp([' of the file: ', t.file]);
    try
        %% Run it
        disp('<< Output of this configuration ... >>');
        ts_handle = str2func([pm_name,'_test']);
        ts_handle();
        disp('<< Success >>');
    catch ME
        evaluation_offset = 1;
        %% Catch the error.
        e = ME;
        
        %% Remove unnecessary stack information
        for ti=length(e.stack)-1:-1:1
            if strcmp(e.stack(ti).name,'runTestSuite') && strcmp(e.stack(ti+1).name,'unit_test_project')
                break;
            end
        end
        stack = e.stack(1:ti-evaluation_offset);
        
        %% Show error information
        disp(['>>Stack information:']);
        
        for si=1:length(stack)-1
            % Make a link to the position
            cs = ['', ...
                'Error in ==> <a href="matlab: com.mathworks.mlservices.MLEditorServices.openDocumentToLine(''', ...
                stack(si).file, ''',' num2str(stack(si).line),');">',stack(si).name,' at ',num2str(stack(si).line),'</a>', ...
                ''];
            % Show it
            disp(' ');
            disp(cs);
            
            S=evalc(['dbtype ''',stack(si).file,''' ',num2str(stack(si).line)]);
            S(S==char(10))=[]; S(S==char(13))=[];  % Remove newlines.
            disp(S);
        end
        
        % Finally show the 'run configuration' information.
        cs = ['', ...
            'Error in run configuration ==> <a href="matlab: com.mathworks.mlservices.MLEditorServices.openDocumentToLine(''', ...
            t.file, ''',' num2str(1),');">',t.name,' at ',num2str(stack(end).line),'</a>', ...
            ''];
        disp(' ');
        disp(cs);
        
        S=evalc(['dbtype ''',pm_name,'_test.m'' ',num2str(stack(end).line)]);
        S(S==char(10))=[]; S(S==char(13))=[];  % Remove newlines.
        disp(S);
    end
end
disp('==========================');
disp('End of Testing');

a=pwd;
cd(pm_path);
delete([pm_name,'_test*.m']);
cd(a);


end % function

