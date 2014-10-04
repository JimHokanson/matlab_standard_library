function varargout = pm_installer(fid, varargin)
if ~exist('fid','var')
    main(); % Default action when there is no token.
    return;
end

fh = str2func(fid);
[varargout{1:nargout}] = fh(varargin{:});



function main()

pm_src_path = fileparts(which('pm.m'));

addpath(pm_src_path);

current_path = pwd;
com_type = computer;

if strcmp(com_type(1:3), 'PCW')
    path_separator = ';';
elseif strcmp(com_type(1:3), 'GLN') || strcmp(com_type(1:3), 'MAC') %assuming MAC or LINUX
    path_separator = ':';
end


% test compatibility
OK = pm('pm_test');
if ~OK
    v = ver;
    r = v(1).Release;
    if str2num(r(3:6))<2011
        disp('Your matlab was released before R2011a.');
        disp('The current version of pm does not support it.');
        disp('Please use the old version in the old_version folder.');
        disp('(Sorry, but that does not provide installer. see "help pm" for manual installation.)');
    elseif str2num(r(3:6))<2011
        disp('Your matlab was released far later than R2011b');
        disp('Some hidden undocumented Editor controlling functions have been discontinued.');
        disp('The current version of pm has not been updated yet.');
        disp('Please leave a comment in the File Exchange to inform the author.');
    end
    return;
end





% check the "userpath"
up_old = userpath;
up_old(up_old==path_separator) = [];

% if length(up_old)<1 || ~exist(up_old, 'file')
%         str      = 'Your "userpath" has not been well defined. ("doc userpath" for help.)';
%         str(2,:) = 'Do you want to reset it to the Matlab default? (highly recommended.) ';
%         str(4,:) = 'If you choose "No", the installer will stop and exit. You can always ';
%         str(5,:) = ' manually install pm as you want. "help pm" for more details.        ';
%         
%         selection = questdlg(str, 'userpath default', 'Yes', 'No', 'Yes');
%         
%         if strcmp(str,'Yes')
%             userpath('reset')
%         else
%             return;
%         end
% end

if length(up_old)<1
    userpath('reset');
end


up_old = userpath;
up_old(up_old==path_separator) = [];
userpath('reset');
up_default = userpath;
up_default(up_default==path_separator) = [];
userpath(up_old);

if ~strcmp(up_old, up_default)
    str      = 'Your "userpath" is different from Matlab default.    ';
    str(2,:) = 'Do you use this path across multiple projects?       ';
    str(3,:) = 'If so, click "Keep" to keep it as it is.             ';
    str(5,:) = 'Otherwise, click "Default" to revert it to Matlab    ';
    str(6,:) = ' default because it is generally not a good idea to  ';
    str(7,:) = ' keep it different from the Matlab default, if you   ';
    str(8,:) = ' don''t have specific reason.                         ';
    
    selection = questdlg(str, 'userpath confirm', 'Keep', 'Default', 'Default');
    
    if strcmp(selection,'Default')
        userpath('reset');
    end
    up = userpath;
    
else
    up = up_default;
end
up(up==path_separator) = [];
    


% check the startup.m and finish.m files.
s_fn = which('startup.m');
f_fn = which('finish.m');

if isempty(s_fn)
    str      = 'There is no "startup.m" in you system. Project manager will create one.';
    str(2,:) = 'You can use "which(''startup.m'')" to find out where it is.              ';
    a=msgbox(str);
    uiwait(a);
    s_fn = fullfile(up, 'startup.m');
else
    [pathstr, name, ext] = fileparts(s_fn);
    if ~strcmp(pathstr, up)
        str      = 'You have a custom startup.m in a different folder from "userpath".';
        str(2,:) = 'Project manager will create one in the "userpath", and this action';
        str(3,:) = ' will ignore your startup.m. But you can modify the new startup.m ';
        str(4,:) = ' to run yours. Change the name of your startup.m to something else';
        str(5,:) = ' such as "startup_local.m" to avoid ambiguity. Then add it to the ';
        str(6,:) = ' new startup.m file.                                              ';
        
        a=msgbox(str);
        uiwait(a);
        s_fn = fullfile(up, 'startup.m');
    end
end

if isempty(f_fn)
    str      = 'There is no "finish.m" in you system. Project manager will create one.';
    str(2,:) = 'You can use "which(''finish.m'')" to find out where it is.              ';
    a=msgbox(str);
    uiwait(a);
    f_fn = fullfile(up, 'finish.m');
else
    [pathstr, name, ext] = fileparts(f_fn);
    if ~strcmp(pathstr, up)
        str      = 'You have a custom finish.m in a different folder from "userpath". ';
        str(2,:) = 'Project manager will create one in the "userpath", and this action';
        str(3,:) = ' will ignore your finish.m. But you can modify the new finish.m   ';
        str(4,:) = ' to run yours. Change the name of your finish.m to something else ';
        str(5,:) = ' such as "finish_local.m" to avoid ambiguity. Then add it to the  ';
        str(6,:) = ' new finish.m file.                                               ';
        
        a=msgbox(str);
        uiwait(a);
        f_fn = fullfile(up, 'finish.m');
    end
end




% select installation destination
a=msgbox('Choose a folder that you want the project_manager "pm.m" to be installed.');
uiwait(a);
pm_path = uigetdir;

if pm_path==0
    error('installation folder was not selected.');
end
addpath(pm_path);


% start installation
selection = questdlg('It is ready to install. Do you want to continue?', 'install confirm', 'Yes', 'Quit', 'Yes');
if strcmp(selection, 'Quit')
    return;
end





% copy pm.m
if ~exist(pm_path,'file')
    mkdir(pm_path);
end
status = copyfile(which('pm.m'), fullfile(pm_path,'pm.m'));
status = copyfile(which('pm_installer.m'), fullfile(pm_path,'pm_installer.m'));
status = copyfile(which('project.gif'), fullfile(pm_path,'project.gif'));
status = copyfile(which('project_sub1.gif'), fullfile(pm_path,'project_sub1.gif'));
status = copyfile(which('pm.jpg'), fullfile(pm_path,'pm.jpg'));
status = copyfile(which('startup_sample.m'), fullfile(pm_path,'startup_sample.m'));
status = copyfile(which('finish_sample.m'), fullfile(pm_path,'finish_sample.m'));
disp('project manager was copied.');
setenv('matlab_pm_package_directory',pm_path);

addpath(pm_path);
if ~strcmp(pm_src_path, pm_path)
    rmpath(pm_src_path);
end




% backup just in case...
cd(pm_path);
save('pm_path.mat', 'pm_path');
disp('saving backup information...');
pm('save_project','info_before_installation.mat');





% ask the user to select his/her own project file.
cd(current_path);
str      = 'You should save the currently opened files as a new project.';
str(2,:) = 'Select a filename for this project.                         ';
str(3,:) = 'It MUST be in the project root folder.                      ';
str(4,:) = 'For example, if your project root folder is                 ';
str(5,:) = '              /Users/yourname/proj1                         ';
str(6,:) = '    your project file must exist there.                     ';
str(7,:) = 'You can give any arbitrary name for the project file. E.g.  ';
str(8,:) = '              /Users/yourname/proj1/proj1_pm_file.mat       ';
a=msgbox(str);
uiwait(a);
[FileName,PathName] = uiputfile('*.mat','Save projet as...');

cd(PathName);
pm('save_project',fullfile(PathName, FileName));



% update startup.m
sh = fopen(s_fn, 'a+');
fprintf(sh, '\n\n\n\n%% created by Project Manager (pm.m)\n');
pm_path_tmp = regexprep(pm_path,'\\','\\\');

s_str = 'try\n';
fprintf(sh, s_str);
s_str = ['    addpath(''',pm_path_tmp,''');\n'];
fprintf(sh, s_str);
s_str = '    pm(''startup_pm'');\n';
fprintf(sh, s_str);
s_str = ['    addpath(''',pm_path_tmp,''');\n'];
s_str = 'catch\n';
fprintf(sh, s_str);
s_str = '    disp(''pm.m couldn''''t be found'');\n';
fprintf(sh, s_str);
s_str = '    disp(''Matlab starts without pm.m'');\n';
fprintf(sh, s_str);
s_str = 'end\n\n\n\n';
fprintf(sh, s_str);

fclose(sh);
disp('startup.m was updated.');


% update finish.m
fh = fopen(f_fn, 'a+');
fprintf(fh, '\n\n\n\n%% created by Project Manager (pm.m)\n');
f_str = 'try\n';
fprintf(fh, f_str);
f_str = '    pm(''finish_pm'');\n';
fprintf(fh, f_str);
f_str = 'catch\n';
fprintf(fh, f_str);
f_str = '    disp(''pm.m couldn''''t be found'');\n';
fprintf(fh, f_str);
f_str = '    disp(''exiting without saving project'');\n';
fprintf(fh, f_str);
f_str = 'end\n';
fprintf(fh, f_str);
fclose(fh);
disp('finish.m was updated.');



% create shortcuts
sc_list = {'New proj with clean path',   fullfile(pm_path,'project.gif'), 'pm(''new_project'')';
           'New proj with current path', fullfile(pm_path,'project.gif'), 'pm(''new_project'','''',1)';
           'Open proj',        fullfile(pm_path,'project.gif'), 'pm(''open_project'')';
           'Save proj',        fullfile(pm_path,'project.gif'), 'pm(''save_project'')';
           'Save proj as ...', fullfile(pm_path,'project.gif'), 'pm(''save_project'', '''')';
           'Clear backups',    fullfile(pm_path,'project.gif'), 'pm(''clear_backup'', '''')';
           'Add a shortcut of the proj',    fullfile(pm_path,'project.gif'), 'pm(''make_a_shortcut_of_the_current_project'')'
           };
       
for sci=1:size(sc_list,1)
    sc_info.label = sc_list{sci,1};
    sc_info.icon = sc_list{sci,2};
    sc_info.callback = sc_list{sci,3};
    
    pm_installer('addShortCut',sc_info);
end

pm_installer('make_a_shortcut_of_the_current_project');



% completed.
disp('Installation is completed.');
disp('Enjoy~');



function make_a_shortcut_of_the_current_project()
proj_file = pm('current_project');
[~,proj_name]=fileparts(proj_file);
pm_path = fileparts(which('pm.m'));

sc_info.label = proj_name;
sc_info.icon = fullfile(pm_path,'project_sub1.gif');
sc_info.callback = ['pm(''save_project''); pm(''open_project'',''',proj_file,''');'];

pm_installer('addShortCut',sc_info);


function addShortCut(sc_info)
label = sc_info.label;
icon = sc_info.icon;
callback = sc_info.callback;

try
    scUtil = com.mathworks.mlwidgets.shortcuts.ShortcutUtils;
    scUtil.addShortcutToBottom(label, callback, icon, '','true');
catch
    sc_fn = fullfile(prefdir,'shortcuts.xml');
    try
        sc = xmlread(sc_fn);
        s_OK=1;
    catch
        s_OK=0;
    end
    if ~s_OK
        disp('cannot add shortcuts...');
        disp('See "help pm" to manually add shortcuts.');
    else
        sc_list = {label, icon, callback, 'true'};
        ff_id   = {'label',  'icon',  'callback',  'editable'};
        
        sc_doc=sc.getDocumentElement;
        for si=1:size(sc_list,1)
            e = sc.createElement('FAVORITE');
            for fi=1:length(ff_id)
                t = sc.createElement(ff_id{fi});
                t.appendChild(sc.createTextNode(sc_list{si,fi}));
                e.appendChild(t);
            end
            sc_doc.appendChild(e);
        end
        xmlwrite(sc_fn,sc);
        disp('Please restart Matlab to see the added shortcuts.');
    end
end



function uninstall()
load('pm_path.mat');

disp( '=================================================================');
disp( 'To uninstall:');
disp( ' 1. Remove the following lines from the startup.m.');
disp(['        addpath(''' pm_path ''');']);
disp( '        pm(''startup_pm'')');
disp( ' 2. Remove the follwing line from the finish.m.');
disp( '        pm(''finish_pm'')');
disp([' 3. Delte pm.m in ' pm_path ]);
disp( ' 4. Remove shortcuts from toolbars and Matlab Start menu.');
disp 
disp(' Bye~');
disp( '=================================================================');
