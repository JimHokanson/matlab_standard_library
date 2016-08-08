function varargout = pm_ut(varargin)
% PM_UT M-file for pm_ut.fig
%      PM_UT, by itself, creates a new PM_UT or raises the existing
%      singleton*.
%
%      H = PM_UT returns the handle to a new PM_UT or the handle to
%      the existing singleton*.
%
%      PM_UT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PM_UT.M with the given input arguments.
%
%      PM_UT('Property','Value',...) creates a new PM_UT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pm_ut_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pm_ut_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pm_ut

% Last Modified by GUIDE v2.5 27-Feb-2009 11:54:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pm_ut_OpeningFcn, ...
                   'gui_OutputFcn',  @pm_ut_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before pm_ut is made visible.
function pm_ut_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pm_ut (see VARARGIN)

% Choose default command line output for pm_ut
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pm_ut wait for user response (see UIRESUME)
% uiwait(handles.figure1);
pm_info = varargin{1};
[pm_path,pm_name] = fileparts(pm_info.filename);
if isfield(pm_info,'test_suite')
    test_suite = pm_info.test_suite;
else
    test_suite = [];
end
all_configs = pm('parseConfigs');

handles.pm_info = pm_info;
handles.pm_path = pm_path;
handles.pm_name = pm_name;
handles.test_suite = test_suite;
handles.all_configs = all_configs;

% exclude non-existent one.
for tsi = length(test_suite):-1:1
    t = test_suite(tsi);
    ok=0;
    for cci=1:length(all_configs)
        c = all_configs(cci);
        % TODO: this portion is version sensitive.
        if strcmp(t.id, c.id) %strcmp(t.name,c.name) && strcmp(t.file,c.file) && strcmp(t.id, c.id)
            ok=1;
            test_suite(tsi) = c;
            break;
        end
    end
    if ~ok
        test_suite(tsi)=[];
    end
end
handles.test_suite = test_suite;



% Save the handles structure.
guidata(hObject,handles);
set(handles.SelectConfig, 'Value', 2);
SelectConfig_Callback(handles.SelectConfig, eventdata, handles);
TestSuite_Callback(handles.TestSuite, eventdata, handles);

set(handles.figure1, 'Name', 'Select run configurations you want to run.');






% --- Outputs from this function are returned to the command line.
function varargout = pm_ut_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
if isnumeric(handles.all_configs)
    disp('There is no valid run configurations in your MATLAB.');
    delete(handles.figure1)
end


% --- Executes on selection change in RunConfigs.
function RunConfigs_Callback(hObject, eventdata, handles)
% hObject    handle to RunConfigs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RunConfigs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RunConfigs
cc=handles.current_configs;
str={};
for i=1:length(cc)
    str{i} = cc(i).name;
end
set(hObject,'String',str);


% --- Executes during object creation, after setting all properties.
function RunConfigs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RunConfigs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in TestSuite.
function TestSuite_Callback(hObject, eventdata, handles)
% hObject    handle to TestSuite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns TestSuite contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TestSuite
ts = handles.test_suite;
str={};
for i=1:length(ts)
    str{end+1} = ts(i).name;
end
set(hObject, 'String',str);



% --- Executes during object creation, after setting all properties.
function TestSuite_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TestSuite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Add.
function Add_Callback(hObject, eventdata, handles)
% hObject    handle to Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cc = handles.current_configs;
ts = handles.test_suite;
selected=get(handles.RunConfigs,'Value');
if ~isempty(ts)
    ts(end+1:end+length(selected)) = cc(selected);
else
    ts = cc(selected);
end
cc(selected)=[];
handles.current_configs = cc;
handles.test_suite = ts;
guidata(hObject,handles);
set(handles.RunConfigs,'Value',[]);
RunConfigs_Callback(handles.RunConfigs, eventdata, handles);
TestSuite_Callback(handles.TestSuite, eventdata, handles);



% --- Executes on button press in Remove.
function Remove_Callback(hObject, eventdata, handles)
% hObject    handle to Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selected=get(handles.TestSuite,'Value');
handles.test_suite(selected)=[];
% Save the handles structure.
guidata(hObject,handles);
set(handles.TestSuite,'Value',[]);
SelectConfig_Callback(handles.SelectConfig, eventdata, handles);
TestSuite_Callback(handles.TestSuite, eventdata, handles);

% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pm_info = handles.pm_info;
pm_info.test_suite = handles.test_suite;
for i=1:length(pm_info.test_suite)
    pm_info.test_suite(i).codes = '';
end
pm_filename = pm_info.filename;
rmfield(pm_info,'filename');
save(pm_filename,'pm_info');


% --- Executes on button press in SaveAndRun.
function SaveAndRun_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAndRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Save_Callback(handles.Save, eventdata, handles);
pm('unit_test_project');

% --- Executes on button press in CancelOrClose.
function CancelOrClose_Callback(hObject, eventdata, handles)
% hObject    handle to CancelOrClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

% --- Executes on selection change in SelectConfig.
function SelectConfig_Callback(hObject, eventdata, handles)
% hObject    handle to SelectConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectConfig contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectConfig
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
all_configs = handles.all_configs;
pm_path = handles.pm_path;
current_configs=[];
switch str{val};
case 'Current m-file' % User selects peaks.
        pm_name = handles.pm_name;
        e=com.mathworks.mlservices.MLEditorServices;
        cf=char(e.builtinGetActiveDocument);
        for i=1:length(all_configs)
            c = all_configs(i);
            if ~isempty(strfind(c.file,cf))
                if isempty(current_configs)
                    current_configs = c;
                else
                    current_configs(end+1) = c;
                end
            end
        end
case 'Current project' % User selects membrane.
        for i=1:length(all_configs)
            c = all_configs(i);
            if ~isempty(strfind(c.file,pm_path))
                if isempty(current_configs)
                    current_configs = c;
                else
                    current_configs(end+1) = c;
                end
            end
        end
case 'All run configurations' % User selects sinc.
        current_configs = handles.all_configs;
end

% exclude selected ones.
test_suite = handles.test_suite;
for cci=length(current_configs):-1:1
    c = current_configs(cci);
    for tsi=1:length(test_suite)
        t=test_suite(tsi);
        % TODO: this portion is version sensitive.
        if strcmp(t.id, c.id) %strcmp(t.name,c.name) && strcmp(t.file,c.file) && strcmp(t.id, c.id)
            current_configs(cci)=[];
        end
    end
end
handles.current_configs = current_configs;
% Save the handles structure.
guidata(hObject,handles);
RunConfigs_Callback(handles.RunConfigs, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function SelectConfig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Up.
function Up_Callback(hObject, eventdata, handles)
% hObject    handle to Up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = sort(get(handles.TestSuite,'Value'));
if selected(1)>1
    for i=1:length(selected)
        handles.test_suite([selected(i)-1,selected(i)]) = handles.test_suite([selected(i),selected(i)-1]);
    end
    set(handles.TestSuite, 'value', selected-1);
end
guidata(hObject,handles);
TestSuite_Callback(handles.TestSuite, eventdata, handles);


% --- Executes on button press in Down.
function Down_Callback(hObject, eventdata, handles)
% hObject    handle to Down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = sort(get(handles.TestSuite,'Value'));
if selected(end)<length(handles.test_suite)
    for i=length(selected):-1:1
        handles.test_suite([selected(i),selected(i)+1]) = handles.test_suite([selected(i)+1,selected(i)]);
    end
    set(handles.TestSuite, 'value', selected+1);
end
guidata(hObject,handles);
TestSuite_Callback(handles.TestSuite, eventdata, handles);


