function output_file_path = exportToScript(gui_path,varargin)
% x Generate programmatic GUI M-File from a FIG-File
%
%   output_file_path = sl.h.figure.exportToScript(gui_path,varargin)
%
%   Optional Inputs
%   ----------------
%   cb_gen
%   fig_xy : [left,bottom] default []
%       If empty the default position is used. Otherwise the figure
%       position is set to the specified location.

%   Improvements
%   ------------
%   1) Create alias in gui folder - sl.gui.exportToScript
%   2) Add back support for callbacks
%   3) Add on support for more arbitrary property settings than fig_xy
%       - tag name, prop_name, value
%   4) Change output to varargout


% Based On - https://www.mathworks.com/matlabcentral/fileexchange/14340-convert-fig-to-matlab-code
% ----------------------------------------------
% Version : 1.0
% Created : 10/05/2006
% Modified: 14/04/2010
% Author  : Thomas Montagnon (The MathWorks France)




% INPUT ARGUMENTS

in.cb_gen = false; %NYI
in.fig_xy = [];
in.output_path = ''; %NYI
in.output_name = ''; %NYI
in.output_folder = '';

in.syscolorfig = true;
in = sl.in.processVarargin(in,varargin);


%Features that can later be readded
%-------------------------------------------
% if nargin == 1
%
%   % Check if guiName is a directory or a file
%   if exist(guiName,'dir')
%     [guiName,guiPath] = uigetfile(fullfile(guiName,'*.fig'),'Choose a FIG-File');
%     if isequal(guiName,0)
%       return
%     end
%     guiName = fullfile(guiPath,guiName);
%   end
%
%   % Output directory
%   outputDir = uigetdir(guiPath,'Choose the output directory');
%   if isequal(outputDir,0)
%     return
%   end
%
% end
%
% if nargin == 0
%
%   % Fig-File
%   [guiName,guiPath] = uigetfile('*.fig','Choose a FIG-File');
%   if isequal(guiName,0)
%     return
%   end
%   guiName = fullfile(guiPath,guiName);
%
%   % Output directory
%   outputDir = uigetdir(guiPath,'Choose the output directory');
%   if isequal(outputDir,0)
%     return
%   end
%
% end



if ~exist(gui_path,'file')
    msg = sl.error.getMissingFileErrorMsg(gui_path);
    error(msg);
end

% Get info about the FIG-File
[gui_root,gui_name,gui_ext] = fileparts(gui_path);

% Stop the execution of the function if the FIG-File doesn't exist or is invalid
if ~strcmpi(gui_ext,'.fig')
    error('File extension not .fig as expected')
end

% Name of the output file
output_file_name = [gui_name '_build.m'];
if isempty(in.output_folder)
    output_file_path = fullfile(gui_root,output_file_name);
else
    output_file_path = fullfile(in.output_folder,output_file_name);
end

% Graphic objects categories
categories = {...
    'FIGURE',...
    'CONTEXT MENUS',...
    'MENU ITEMS',...
    'PANELS',...
    'AXES',...
    'LINES',...
    'SURFACES',...
    'STATIC TEXTS',...
    'PUSHBUTTONS',...
    'TOGGLE BUTTONS',...
    'RADIO BUTTONS',...
    'CHECKBOXES',...
    'EDIT TEXTS',...
    'LISTBOXES',...
    'POPUP MENU',...
    'SLIDERS',...
    'UITABLE',...
    'TOOLBAR', ...
    'PUSH TOOLS', ...
    'TOGGLE TOOLS'};

% Default Tags
default_tags = {...
    'figure',...
    'menu',...
    'menuitem',...
    'panel',...
    'axes',...
    'line',...
    'surf',...
    'text',...
    'pushbutton',...
    'togglebutton',...
    'radiobutton',...
    'checkbox',...
    'edit',...
    'listbox',...
    'popupmenu',...
    'slider',...
    'uitable',...
    'uitoolbar', ...
    'uipushtool', ...
    'uitoggletool'};

% Callbacks names
cb_names = { ...
    'Callback', ...
    'ButtonDownFcn', ...
    'CreateFcn', ...
    'DeleteFcn', ...
    'KeyPressFcn', ...
    'KeyReleaseFcn', ...
    'ResizeFcn', ...
    'WindowButtonDownFcn', ...
    'WindowButtonMotionFcn', ...
    'WindowButtonUpFcn', ...
    'WindowScrollWheelFcn', ...
    'SelectionChangeFcn', ...
    'ClickedCallback', ...
    'OffCallback', ...
    'OnCallback', ...
    'CellEditCallback', ...
    'CellSelectionCallback'};

% Default properties values
default_props = h__defaultPropValues();

% Properties for each style of objects
control_props = h__controlProps();

handle_type_list = fieldnames(control_props);

% Ouput file header
header = sprintf([...
    'function handles = %s\n' ...
    '%% %s\n' ...
    '%%-------------------------------------------------------------------------------\n' ...
    '%% File name   : %-30s\n' ...
    '%% Generated on: %-30s\n' ...
    '%% Description :\n' ...
    '%%-------------------------------------------------------------------------------\n' ...
    '\n\n'], ...
    output_file_name(1:end-2),...
    upper(output_file_name(1:end-2)),...
    output_file_name,...
    datestr(now));

% try
    
    %This is incorrect for functions that can't run locally
    %-------------------------------------------------------
    %- We could expose this as an option
    %
    % Open the GUI
    %   cdir = pwd;
    %   cd(guiPath);
    %   figFcn = str2func(guiName);
    %   figHdl = figFcn();
    %   cd(cdir);
    
    %Why aren't we using this by default???
    h_fig = openfig(fullfile(gui_root,[gui_name,'.fig']));
    
    pause(0.1);
    
    % Set Window style & CloseRequestFcn for GUI in order to hide the figure
    set(h_fig,'WindowStyle','normal','CloseRequestFcn','closereq','visible','off');
    
    pause(0.1);
    
    % List all the graphic objects by category
    handles_list = struct;
    handles_list.Fg = h_fig;
    handles_list.Cm = sort(findobj(h_fig,'Type', 'uicontextmenu'));
    handles_list.Mb = sort(findobj(h_fig,'Type', 'uimenu'));
    handles_list.Pa = sort(findobj(h_fig,'Type', 'uipanel'));
    handles_list.Ax = sort(findobj(h_fig,'Type', 'axes'));
    handles_list.Li = sort(findobj(h_fig,'Type', 'line'));
    handles_list.Sf = sort(findobj(h_fig,'Type', 'surface'));
    handles_list.Ta = sort(findobj(h_fig,'Type', 'uitable'));
    handles_list.To = sort(findobj(h_fig,'Type' ,'uitoolbar'));
    handles_list.Pt = sort(findobj(h_fig,'Type' ,'uipushtool'));
    handles_list.Tt = sort(findobj(h_fig,'Type' ,'uitoggletool'));
    handles_list.St = sort(findobj(h_fig,'Style','text'));
    handles_list.Pb = sort(findobj(h_fig,'Style','pushbutton'));
    handles_list.Tb = sort(findobj(h_fig,'Style','togglebutton'));
    handles_list.Rb = sort(findobj(h_fig,'Style','radiobutton'));
    handles_list.Cb = sort(findobj(h_fig,'Style','checkbox'));
    handles_list.Ed = sort(findobj(h_fig,'Style','edit'));
    handles_list.Lb = sort(findobj(h_fig,'Style','listbox'));
    handles_list.Pu = sort(findobj(h_fig,'Style','popupmenu'));
    handles_list.Sl = sort(findobj(h_fig,'Style','slider'));
    
    % Init callback list
    if in.cb_gen
        cb_list = {};
    end
    
    % Start writing the output file
    %----------------------------------------------------------------------
    str = sprintf('%s',header);
    str = sprintf('%s%% Initialize handles structure\nhandles = struct();\n\n',str);
    
    % Write the generation code for all the objects, grouped by category
    for iType=1:length(handle_type_list)
        
        cur_handle_type = handle_type_list{iType};
        % Handles vector and properties list for the current category
        cur_handles_of_type = handles_list.(cur_handle_type);
        temp_props = control_props.(cur_handle_type);
        
        % Object creation function depending on the category
        switch handle_type_list{iType}
            case 'Fg'
                fcn_name = 'figure';
                
                %Should only be 1 ...
                h_temp = cur_handles_of_type;
                if ~isempty(in.fig_xy)
                    p = get(h_temp,'Position');
                    p(1:2) = in.fig_xy;
                    set(h_temp,'Position',p);
                end
                
            case 'Pa'
                fcn_name = 'uipanel';
            case 'Ta'
                fcn_name = 'uitable';
            case 'Mb'
                fcn_name = 'uimenu';
            case 'Cm'
                fcn_name = 'uicontextmenu';
            case 'Ax'
                fcn_name = 'axes';
            case 'Li'
                fcn_name = 'line';
            case 'Sf'
                fcn_name = 'surf';
            case 'To'
                fcn_name = 'uitoolbar';
            case 'Pt'
                fcn_name = 'uipushtool';
            case 'Tt'
                fcn_name = 'uitoggletool';
            otherwise
                fcn_name = 'uicontrol';
        end
        
        % If there are objects from the current category then write code
        if ~isempty(cur_handles_of_type)
            
            % Category name
            str = sprintf('%s\t\t%% --- %s -------------------------------------\n',str,categories{iType});
            
            % Init index for empty tags
            idxTag = 1;
            
            % Browse all the objects belonging to the current category
            %-----------------------------------------------------------
            for iHandle=1:length(cur_handles_of_type)
                
                % Get property values for the current object
                h_struct = get(cur_handles_of_type(iHandle));
                
                % If tag is empty then create one
                if isempty(h_struct.Tag)
                    h_struct.Tag = sprintf('%s%u',default_tags{iType},idxTag);
                    set(cur_handles_of_type(iHandle),'Tag',h_struct.Tag);
                    idxTag = idxTag + 1;
                end
                
                % Special treatment for UIButtongroup (UIButtongroup are UIPanel with
                % the SelectedObject property): Change creation function name
                if strcmp(handle_type_list{iType},'Pa')
                    if isfield(h_struct,'SelectedObject')
                        fcn_name = 'uibuttongroup';
                    end
                end
                
                % Start object creation code
                % (store all the objects handles in a handles structure)
                str = sprintf('%s\t\thandles.%s = %s( ...\n',str,h_struct.Tag,fcn_name);
                
                % Browse the object properties
                %----------------------------------------------------------
                for iProp = 1:length(temp_props)
                    
                    prop_name = temp_props{iProp};
                    prop_value = h_struct.(prop_name);
                    
                    
                    % For Parent & UIContextMenu properties, value is an object handle
                    %_------------------------------------------------------
                    if strcmp(prop_name,'Parent') || strcmp(prop_name,'UIContextMenu')
                        %TODO: Fix this ...
                        % % %               %https://www.mathworks.com/matlabcentral/fileexchange/14340-convert-fig-to-matlab-code
                        % % %               str = sprintf('%s\t\t\t''%s'', %s, ...\n',str,propTemp{indProp},propVal);
                        % % %                 continue;
                        if isempty(prop_value)
                            continue;
                        else
                            prop_value = sprintf('handles.%s',get(prop_value,'Tag'));
                            str = sprintf('%s\t\t\t''%s'', %s, ...\n',str,prop_name,prop_value);
                            continue;
                        end
                    end
                    
                    if isfield(default_props,prop_name) && ...
                            isequal(prop_value,default_props.(prop_name))
                        %do nothing - don't need to write defaults
                    else
                        % Create Property/Value string according to the
                        % class of the property value
                        switch class(prop_value)
                            case 'char'
                                s = format_char(prop_value);
                            case {'double','single','uint8'}
                                s = format_numeric(prop_value,prop_name,cur_handle_type,in);
                            case 'cell'
                                s = format_cell(prop_value,prop_name);
                            case 'logical'
                                s = format_logical(prop_value);
                        end
                        
                        % Write the code line 'Property','Value',...
                        str = sprintf('%s\t\t\t''%s'', %s, ...\n',str,temp_props{iProp},s);
                        
                    end % end isequal
                end % end property
                
% % % %                 % Callbacks
% % % %                 if cb_gen
% % % %                     
% % % %                     % Extract all property names
% % % %                     l = fieldnames(h_struct);
% % % %                     
% % % %                     % Find defined callback properties
% % % %                     [iprop,icb] = find(strcmp(repmat(l,1,length(cb_names)),repmat(cb_names,length(l),1))); %#ok<ASGLU>
% % % %                     
% % % %                     for indCb=1:length(icb)
% % % %                         if ~isempty(h_struct.(cb_names{icb(indCb)}))
% % % %                             cb_list{end+1} = [h_struct.Tag '_' cb_names{icb(indCb)}]; %#ok<AGROW>
% % % %                             str = sprintf('%s\t\t\t''%s'', %s, ...\n',str,cb_names{icb(indCb)},['@' cb_list{end}]);
% % % %                         end
% % % %                     end
% % % %                     
% % % %                 end
                
                % Suppress the 5 last characters (, ...) and finish the creation command
                str(end-5:end) = '';
                str = sprintf('%s);\n\n',str);
                
            end % Next object
            
        end % End if ~isempty(hdlsTemp)
        
    end % Next object category
    
    % Close the build_gui nested function
%     str = sprintf('%s\n\tend\n\n',str);
    
    % Add callback functions
    if in.cb_gen
        for indCb=1:length(cb_list)
            str = sprintf('%s%%%% ---------------------------------------------------------------------------\n',str);
            str = sprintf('%s\tfunction %s(hObject,evendata) %%#ok<INUSD>\n\n',str,cb_list{indCb});
            str = sprintf('%s\tend\n\n',str);
        end
    end
    
    % Close main function
    str = sprintf('%send\n',str);
    
    % Close the figure
    close(h_fig);
    
    % Write the output file
    fid = fopen(output_file_path,'w');
    fprintf(fid,'%s',str);
    fclose(fid);
    
    % Open the generated M-File in the editor
    edit(output_file_path);
    
    % Return the name of the output file
    varargout{1} = output_file_path;
    
% catch ME
%     varargout{1} = output_file_path;
%     try %#ok<TRYNC>
%         close(h_fig);
%     end
%     disp(h_struct.Tag);
%     disp(ME.message);
% end




end

function s = format_cell(prop_value,prop_name)

% Cell arrays (Create a single string with each cell separated by
% a | character)

if strcmpi(prop_name,'ColumnFormat') && all(cellfun(@isempty,prop_value))
    s = ['{' repmat('''char'' ',size(prop_value)) '}'];
    
elseif strcmpi(prop_name,'ColumnFormat')
    s = sprintf('''%s'',',prop_value{:});
    s = ['{' strrep(s(1:end-1),'''''','[]') '}']; % Handles the case of automatic column format
    
elseif strcmpi(prop_name,'ColumnWidth')
    s = prop_value;
    s(cellfun(@isstr,s))     = cellfun(@(string) ['''' string ''''],s(cellfun(@isstr,s)),'UniformOutput',false);
    s(cellfun(@isnumeric,s)) = cellfun(@num2str,s(cellfun(@isnumeric,s)),'UniformOutput',false);
    s = sprintf('%s,',s{:});
    s = ['{' s(1:end-1) '}'];
    
elseif strcmpi(prop_name,'Data')
    ft = struct('char','''%s'',','logical','logical(%d),','double','%f,');
    classes = cellfun(@class,prop_value(1,:),'UniformOutput',false);
    s = cellfun(@(s) ft.(s),classes,'UniformOutput',false);
    fmt = [s{:}];
    fmt = [fmt(1:end-1) ';'];
    prop_value = prop_value';
    s = sprintf(fmt,prop_value{:});
    s = strrep(s,'logical(0)','false');
    s = strrep(s,'logical(1)','true');
    s = ['{' s(1:end-1) '}'];
    
else
    s = sprintf('''%s'',',prop_value{:});
    s = ['{' s(1:end-1) '}'];
end

end

function s = format_numeric(prop_value,prop_name,handle_type,opts)
% Numeric (Convert numerical value into string)


if opts.syscolorfig && strcmpi(handle_type,'Fg') && strcmpi(prop_name,'Color')
    % When using the system default background colors then override the
    % property value
    s = 'get(0,''DefaultUicontrolBackgroundColor'')';
    
elseif any(strcmpi(prop_name,{'BackgroundColor','ForegroundColor','Color'}))
    % Limit to 3 digits for all colors vectors/matrices
    s = mat2str(prop_value,3);
    
elseif any(strcmpi(prop_name,{'Parent','UIContextMenu'}))
    % Simply output the handles.<tag> characters string when the property is
    % either Parent or UIContextMenu
    s = sprintf('%s',prop_value);
    
else
    if length(size(prop_value)) > 2
        matLin = prop_value(:);
        s = sprintf(',%u',size(prop_value));
        s = sprintf('reshape(%s%s)',mat2str(matLin),s);
    else
        s = mat2str(prop_value);
    end
    
end

end

function s = format_char(prop_value)
% Characters
%
%   From what I can tell this creates a code string from a string
%
%   e.g. test TO 'test'

if size(prop_value,1) > 1
    % For character arrays that have more than 1 line
    s = 'sprintf(''';
    for j=1:size(prop_value,1)
        s = sprintf('%s\t\t%s\\n',s,strrep(prop_value(j,:),'''',''''''));
    end
    s = [s ''')'];
    
elseif any(prop_value == char(13))
    % For character arrays that contain new line character
    s1 = strrep(propVal,char(13),'\n');
    s2 = strrep(s1,newline,'');
    s3 = strrep(s2,'''',''''''); 
    s = sprintf('sprintf(''%s'')',s3);
    
else
    % For character arrays that have a single line and no new line
    s = sprintf('''%s''',strrep(prop_value,'''',''''''));
    %   prop_value = 'This '' is a test';
    %   => This ' is a test
    %   This code generates: ''This '' is a test''
end

end

function s = format_logical(prop_value)
% Format logical property values

trueFalse = {'false,','true,'};
s = trueFalse(prop_value+1);
s = [s{:}];
s = ['[' s(1:end-1) ']'];

end


%-------------------------------------------------------------------------------
function cprop = h__controlProps()

% Common objects properties
prop.Def   = {'Parent','Tag','UserData','Visible'};
prop.Font  = {'FontAngle','FontName','FontSize','FontUnits','FontWeight'};
prop.Color = {'ForegroundColor','BackgroundColor'};
prop.Pos   = {'Units','Position'};
prop.Str   = {'String','TooltipString'};

% Properties for each style of objects
%-------------------------------------------------------
cprop.Fg = [{'Tag'}, prop.Pos, {'Name','MenuBar','NumberTitle','Color','Resize','UIContextMenu'}];
cprop.Cm = [prop.Def];
cprop.Mb = [prop.Def, {'Label','Checked','Enable','ForegroundColor'}];
cprop.Pa = [prop.Def, prop.Pos, prop.Font, prop.Color, {'Title','TitlePosition','BorderType','BorderWidth','HighlightColor','ShadowColor','UIContextMenu'}];
cprop.Ax = [prop.Def, prop.Pos, {'UIContextMenu'}];
cprop.Li = {'BeingDeleted','BusyAction','ButtonDownFcn','Color','CreateFcn','DeleteFcn','DisplayName','EraseMode','HandleVisibility','HitTest','Interruptible','LineStyle','LineWidth','Marker','MarkerEdgeColor','MarkerFaceColor','MarkerSize','Parent','Selected','SelectionHighlight','Tag','UIContextMenu','UserData','Visible','XData','YData','ZData'};
cprop.Sf = {'AlphaData','AlphaDataMapping','CData','CDataMapping','DisplayName','EdgeAlpha','EdgeColor','EraseMode','FaceAlpha','FaceColor','LineStyle','LineWidth','Marker','MarkerEdgeColor','MarkerFaceColor','MarkerSize','MeshStyle','XData','YData','ZData','FaceLighting','EdgeLighting','BackFaceLighting','AmbientStrength','DiffuseStrength','SpecularStrength','SpecularExponent','SpecularColorReflectance','VertexNormals','NormalMode','ButtonDownFcn','Selected','SelectionHighlight','Tag','UIContextMenu','UserData','Visible','Parent','XDataMode','XDataSource','YDataMode','YDataSource','CDataMode','CDataSource','ZDataSource'};
cprop.St = [prop.Def, {'Style'}, prop.Pos, prop.Font, prop.Color, prop.Str, {'Enable','HorizontalAlignment'}];
cprop.Pb = [prop.Def, {'Style'}, prop.Pos, prop.Font, prop.Color, prop.Str, {'Enable','UIContextMenu','CData'}];
cprop.Tb = [prop.Def, {'Style'}, prop.Pos, prop.Font, prop.Color, prop.Str, {'Enable','UIContextMenu','CData'}];
cprop.Rb = [prop.Def, {'Style'}, prop.Pos, prop.Font, prop.Color, prop.Str, {'Enable','UIContextMenu'}];
cprop.Cb = [prop.Def, {'Style'}, prop.Pos, prop.Font, prop.Color, prop.Str, {'Enable','UIContextMenu'}];
cprop.Ed = [prop.Def, {'Style'}, prop.Pos, prop.Font, prop.Color, prop.Str, {'Enable','UIContextMenu','HorizontalAlignment','Min','Max'}];
cprop.Lb = [prop.Def, {'Style'}, prop.Pos, prop.Font, prop.Color, prop.Str, {'Enable','UIContextMenu','Min','Max'}];
cprop.Pu = [prop.Def, {'Style'}, prop.Pos, prop.Font, prop.Color, prop.Str, {'Enable','UIContextMenu'}];
cprop.Sl = [prop.Def, {'Style'}, prop.Pos, prop.Font, prop.Color, prop.Str, {'Enable','UIContextMenu','Min','Max','SliderStep'}];
cprop.Ta = [prop.Def, prop.Pos, prop.Font, prop.Color, {'ColumnEditable','ColumnFormat','ColumnName','ColumnWidth','Data','Enable','RearrangeableColumns','RowName','RowStriping','TooltipString','UIContextMenu'}];
cprop.To = [prop.Def];
cprop.Pt = [prop.Def, {'TooltipString','CData','Enable','Separator'}];
cprop.Tt = [prop.Def, {'TooltipString','CData','Enable','Separator','State'}];
end


%-------------------------------------------------------------------------------
function dprop = h__defaultPropValues()

dprop = struct( ...
    'MenuBar'             , 'figure', ...
    'NumberTitle'         , 'on', ...
    'Resize'              , 'off', ...
    'UIContextMenu'       , [], ...
    'FontAngle'           , 'normal', ...
    'FontName'            , 'MS Sans Serif', ...
    'FontSize'            , 8, ...
    'FontUnits'           , 'points', ...
    'FontWeight'          , 'normal', ...
    'ForegroundColor'     , [0 0 0], ...
    'BackgroundColor'     , get(0,'DefaultUicontrolBackgroundColor'), ...
    'TitlePosition'       , 'lefttop', ...
    'BorderType'          , 'etchedin', ...
    'BorderWidth'         , 1, ...
    'HighlightColor'      , [1 1 1], ...
    'ShadowColor'         , [0.5 0.5 0.5], ...
    'HorizontalAlignment' , 'center', ...
    'TooltipString'       , '', ...
    'CData'               , [], ...
    'Enable'              , 'on', ...
    'SliderStep'          , [.01 .1], ...
    'Min'                 , 0, ...
    'Max'                 , 1, ...
    'UserData'            , [], ...
    'BeingDeleted'        , 'off', ...
    'BusyAction'          , 'queue', ...
    'ColumnEditable'      , [], ...
    'ColumnFormat'        , [], ...
    'ColumnName'          , 'numbered', ...
    'ColumnWidth'         , 'auto', ...
    'Data'                , {cell(4,2)}, ...
    'RearrangeableColumns', 'off', ...
    'RowName'             , 'numbered', ...
    'RowStriping'         , 'on', ...
    'Visible'             , 'on', ...
    'String'              , '', ...
    'Separator'           , 'off', ...
    'State'               , 'off');
end

