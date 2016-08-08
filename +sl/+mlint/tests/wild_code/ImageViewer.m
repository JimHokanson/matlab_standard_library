classdef ImageViewer < handle
    %IMAGEVIEWER  Interactively pan and zoom images on the computer.
    %   IMAGEVIEWER starts a GUI for opening image files and interactive
    %   panning and zooming.
    %
    %   IMAGEVIEWER(DIRNAME) starts the GUI with DIRNAME as the initial
    %   directory.
    %
    %   The GUI allows you to navigate through your computer and quickly view
    %   image files. It also allows you to interactively explore your images by
    %   panning (clicking and drag), zooming (right-click and drag), and
    %   centering view (double-clicking).
    %
    
    % Copyright 2006-2012 The MathWorks, Inc.
    
    % VERSIONS:
    %   v1.0 - first version. (was pictureviewer.m)
    %   v1.1 - convert to nested functions. (Nov 13, 2006)
    %   v1.2 - bug fix to deal with different image types (Nov 15, 2006)
    %   v1.3 - bug fix for centering, sorting of image files.
    %          add resize window feature.
    %          change FINDOBJ to FINDALL (Nov 16, 2006)
    %   v1.4 - cosmetic changes to the GUI.
    %          a better timer management. (Dec 2, 2006)
    %   v1.5 - added scroll wheel zoom functionality. This only works with
    %          R2007a or later. (Jan 10, 2007)
    %   v1.51 - add white background under red zoom line (June 2007)
    %   v2.0 - Implemented in MATLAB Classes. (Aug 2012)
    %
    % Jiro Doke
    % April 2006
    
    properties (Hidden, Access=protected)
        handles
    end
    
    properties (Constant, Hidden, Access=protected)
        closedHandPointer = [
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,NaN,2  ,2  ,NaN,2  ,2  ,NaN,2  ,2  ,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,2  ,1  ,1  ,2  ,1  ,1  ,2  ,1  ,1  ,2  ,2  ,NaN,NaN
            NaN,NaN,2  ,1  ,2  ,2  ,1  ,2  ,2  ,1  ,2  ,2  ,1  ,1  ,2  ,NaN
            NaN,NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2  ,1  ,2
            NaN,NaN,NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2
            NaN,NaN,2  ,1  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2
            NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2
            NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2
            NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2  ,NaN
            NaN,NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2  ,NaN
            NaN,NaN,NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2  ,NaN,NaN
            NaN,NaN,NaN,NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2  ,NaN,NaN
            NaN,NaN,NaN,NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2  ,NaN,NaN
            ];
        
        zoomInOutPointer = [
            NaN,NaN,NaN,2  ,2  ,NaN,NaN,NaN,NaN,NaN,NaN,2  ,2  ,NaN,NaN,NaN
            NaN,NaN,2  ,1  ,1  ,2  ,NaN,NaN,NaN,NaN,2  ,1  ,1  ,2  ,NaN,NaN
            NaN,2  ,1  ,1  ,1  ,1  ,2  ,NaN,NaN,2  ,2  ,1  ,1  ,2  ,2  ,NaN
            2  ,1  ,1  ,1  ,1  ,1  ,1  ,2  ,2  ,1  ,1  ,1  ,1  ,1  ,1  ,2
            2  ,1  ,2  ,1  ,1  ,2  ,1  ,2  ,2  ,1  ,1  ,1  ,1  ,1  ,1  ,2
            NaN,2  ,2  ,1  ,1  ,2  ,2  ,NaN,NaN,2  ,2  ,1  ,1  ,2  ,2  ,NaN
            NaN,NaN,2  ,1  ,1  ,2  ,NaN,NaN,NaN,NaN,2  ,1  ,1  ,2  ,NaN,NaN
            NaN,NaN,NaN,2  ,2  ,NaN,NaN,NaN,NaN,NaN,NaN,2  ,2  ,NaN,NaN,NaN
            NaN,NaN,NaN,2  ,2  ,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,NaN,2  ,1  ,1  ,2  ,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,2  ,2  ,1  ,1  ,2  ,2  ,NaN,NaN,2  ,2  ,2  ,2  ,2  ,2  ,NaN
            2  ,1  ,2  ,1  ,1  ,2  ,1  ,2  ,2  ,1  ,1  ,1  ,1  ,1  ,1  ,2
            2  ,1  ,1  ,1  ,1  ,1  ,1  ,2  ,2  ,1  ,1  ,1  ,1  ,1  ,1  ,2
            NaN,2  ,1  ,1  ,1  ,1  ,2  ,NaN,NaN,2  ,2  ,2  ,2  ,2  ,2  ,NaN
            NaN,NaN,2  ,1  ,1  ,2  ,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,2  ,2  ,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            ];
        
    end
    
    methods
        function obj = ImageViewer(dirname)
            
            verNumber = '2.0';
            
            if nargin == 0
                dirname = pwd;
            else
                if ~ischar(dirname) || ~isdir(dirname)
                    error('Invalid input argument.\n  Syntax: %s(DIRNAME)', upper(mfilename));
                end
            end
            
            delete(findall(0, 'type', 'figure', 'tag', 'ImageViewer'));
            
            bgcolor1 = [.8 .8 .8];
            txtcolor = [.3 .3 .3];
            
            figH = figure(...
                'units'                         , 'normalized', ...
                'busyaction'                    , 'queue', ...
                'color'                         , bgcolor1, ...
                'deletefcn'                     , @obj.stopTimerFcn, ...
                'doublebuffer'                  , 'on', ...
                'handlevisibility'              , 'callback', ...
                'interruptible'                 , 'on', ...
                'menubar'                       , 'none', ...
                'name'                          , upper(mfilename), ...
                'numbertitle'                   , 'off', ...
                'outerposition'                 , [.1 .1 .8 .8], ...
                'resize'                        , 'on', ...
                'resizefcn'                     , @obj.resizeFcn, ...
                'tag'                           , 'ImageViewer', ...
                'toolbar'                       , 'none', ...
                'visible'                       , 'off', ...
                'defaultaxesunits'              , 'pixels', ...
                'defaulttextfontunits'          , 'pixels', ...
                'defaulttextfontname'           , 'Verdana', ...
                'defaulttextfontsize'           , 12, ...
                'defaultuicontrolunits'         , 'pixels', ...
                'defaultuicontrolfontunits'     , 'pixels', ...
                'defaultuicontrolfontsize'      , 10, ...
                'defaultuicontrolfontname'      , 'Verdana', ...
                'defaultuicontrolinterruptible' , 'off');
            
            try
                if ~verLessThan('matlab', '7.4')
                    set(figH, 'windowscrollwheelfcn', @obj.scrollWheelFcn);
                end
            catch %#ok<CTCH>
                % verLessThan was introduced in v7.4
                % if there is an error, that means it is less than 7.4
            end
            
            uph(1) = uipanel(...
                'units'                     , 'pixels', ...
                'backgroundcolor'           , bgcolor1, ...
                'parent'                    , figH, ...
                'bordertype'                , 'beveledin', ...
                'tag'                       , 'versionPanel');
            uicontrol(...
                'style'                     , 'text', ...
                'foregroundcolor'           , txtcolor, ...
                'backgroundcolor'           , bgcolor1, ...
                'horizontalalignment'       , 'center', ...
                'fontweight'                , 'bold', ...
                'string'                    , sprintf('Ver %s', verNumber), ...
                'parent'                    , uph(1), ...
                'tag'                       , 'versionText');
            uph(2) = uipanel(...
                'units'                     , 'pixels', ...
                'backgroundcolor'           , bgcolor1, ...
                'parent'                    , figH, ...
                'bordertype'                , 'beveledin', ...
                'tag'                       , 'statusPanel');
            uicontrol(...
                'style'                     , 'text', ...
                'foregroundcolor'           , txtcolor, ...
                'backgroundcolor'           , bgcolor1, ...
                'horizontalalignment'       , 'right', ...
                'fontweight'                , 'bold', ...
                'string'                    , '', ...
                'parent'                    , uph(2), ...
                'tag'                       , 'statusText');
            uph(3) = uipanel(...
                'units'                     , 'pixels', ...
                'bordertype'                , 'etchedout', ...
                'fontname'                  , 'Verdana', ...
                'fontweight'                , 'bold', ...
                'title'                     , 'View', ...
                'titleposition'             , 'centertop', ...
                'backgroundcolor'           , bgcolor1, ...
                'parent'                    , figH, ...
                'tag'                       , 'frame1');
            uicontrol(...
                'style'                     , 'text', ...
                'string'                    , '', ...
                'horizontalalignment'       , 'center', ...
                'fontweight'                , 'bold', ...
                'fontsize'                  , 12, ...
                'backgroundcolor'           , bgcolor1, ...
                'foregroundcolor'           , [.2, .2, .2], ...
                'parent'                    , uph(3), ...
                'tag'                       , 'ZoomCaptionText');
            uicontrol(...
                'style'                     , 'pushbutton', ...
                'string'                    , 'Full', ...
                'fontweight'                , 'bold', ...
                'callback'                  , @obj.resetView, ...
                'enable'                    , 'off', ...
                'tooltipstring'             , 'View full image', ...
                'parent'                    , uph(3), ...
                'tag'                       , 'ResetViewBtn1');
            uicontrol(...
                'style'                     , 'pushbutton', ...
                'string'                    , '100%', ...
                'fontweight'                , 'bold', ...
                'callback'                  , @obj.resetView, ...
                'enable'                    , 'off', ...
                'tooltipstring'             , 'View true size', ...
                'parent'                    , uph(3), ...
                'tag'                       , 'ResetViewBtn2');
            uicontrol(...
                'style'                     , 'pushbutton', ...
                'string'                    , 'Help', ...
                'fontweight'                , 'bold', ...
                'callback'                  , @helpBtnCallback, ...
                'enable'                    , 'on', ...
                'parent'                    , figH, ...
                'tag'                       , 'HelpBtn');
            uicontrol(...
                'style'                     , 'togglebutton', ...
                'string'                    , 'File Info', ...
                'fontweight'                , 'bold', ...
                'callback'                  , @obj.fileInfoBtnCallback, ...
                'enable'                    , 'off', ...
                'parent'                    , figH, ...
                'tag'                       , 'FileInfoBtn');
            uph(4) = uipanel(...
                'units'                     , 'pixels', ...
                'backgroundcolor'           , bgcolor1, ...
                'parent'                    , figH, ...
                'bordertype'                , 'beveledin', ...
                'tag'                       , 'CurrentDirectoryPanel');
            uicontrol(...
                'style'                     , 'text', ...
                'backgroundcolor'           , bgcolor1, ...
                'horizontalalignment'       , 'left', ...
                'parent'                    , uph(4), ...
                'tag'                       , 'CurrentDirectoryEdit');
            uicontrol(...
                'style'                     , 'pushbutton', ...
                'string'                    , '...', ...
                'backgroundcolor'           , bgcolor1, ...
                'callback'                  , @obj.chooseDirectoryCallback, ...
                'parent'                    , figH, ...
                'tag'                       , 'ChooseDirectoryBtn');
            
            % Up Directory Icon
            map = [0 0 0;bgcolor1;1 1 0;1 1 1];
            upDirIcon = uint8([
                1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
                1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
                1 1 1 0 0 0 0 0 1 1 1 1 1 1 1 1
                1 1 0 3 2 3 2 3 0 1 1 1 1 1 1 1
                1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
                1 0 2 3 2 3 2 3 2 3 2 3 2 3 2 0
                1 0 3 2 3 2 0 2 3 2 3 2 3 2 3 0
                1 0 2 3 2 0 0 0 2 3 2 3 2 3 2 0
                1 0 3 2 0 0 0 0 0 2 3 2 3 2 3 0
                1 0 2 3 2 3 0 3 2 3 2 3 2 3 2 0
                1 0 3 2 3 2 0 2 3 2 3 2 3 2 3 0
                1 0 2 3 2 3 0 0 0 0 0 3 2 3 2 0
                1 0 3 2 3 2 3 2 3 2 3 2 3 2 3 0
                1 0 2 3 2 3 2 3 2 3 2 3 2 3 2 0
                1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
                ]);
            rgbIcon = ind2rgb(upDirIcon, map);
            
            uicontrol(...
                'style'                     , 'pushbutton', ...
                'cdata'                     , rgbIcon, ...
                'backgroundcolor'           , bgcolor1, ...
                'callback'                  , @obj.upDirectoryCallback, ...
                'parent'                    , figH, ...
                'tag'                       , 'UpDirectoryBtn');
            uicontrol(...
                'style'                     , 'listbox', ...
                'backgroundcolor'           , 'white', ...
                'callback'                  , @obj.fileListBoxCallback, ...
                'fontname'                  , 'FixedWidth', ...
                'parent'                    , figH, ...
                'tag'                       , 'FileListBox');
            
            uph(5) = uipanel(...
                'units'                     , 'pixels', ...
                'bordertype'                , 'etchedout', ...
                'backgroundcolor'           , bgcolor1, ...
                'fontname'                  , 'Verdana', ...
                'fontsize'                  , 10, ...
                'fontweight'                , 'bold', ...
                'title'                     , 'Preview', ...
                'titleposition'             , 'centertop', ...
                'parent'                    , figH, ...
                'tag'                       , 'PreviewImagePanel');
            
            axes(...
                'handlevisibility'          , 'callback', ...
                'parent'                    , uph(5), ...
                'visible'                   , 'off', ...
                'tag'                       , 'PreviewImageAxes');
            
            axes(...
                'box'                       , 'on', ...
                'xtick'                     , [], ...
                'ytick'                     , [], ...
                'handlevisibility'          , 'callback', ...
                'parent'                    , figH, ...
                'tag'                       , 'ImageAxes');
            
            % for drawing the zoom line
            axH = axes(...
                'units'                     , 'normalized', ...
                'position'                  , [0 0 1 1], ...
                'box'                       , 'on', ...
                'hittest'                   , 'off', ...
                'xlim'                      , [0 1], ...
                'xtick'                     , [], ...
                'ylim'                      , [0 1], ...
                'ytick'                     , [], ...
                'handlevisibility'          , 'callback', ...
                'visible'                   , 'off', ...
                'parent'                    , figH, ...
                'tag'                       , 'InvisibleAxes');
            
            line(NaN, NaN, ...
                'linestyle'                 , '-', ...
                'linewidth'                 , 3, ...
                'color'                     , 'w', ...
                'parent'                    , axH, ...
                'tag'                       , 'ZoomLine');
            line(NaN, NaN, ...
                'linestyle'                 , '--', ...
                'linewidth'                 , 2, ...
                'color'                     , 'r', ...
                'parent'                    , axH, ...
                'tag'                       , 'ZoomLine');
            
            uicontrol(...
                'style'                     , 'listbox', ...
                'backgroundcolor'           , [.75, .75, 1], ...
                'fontname'                  , 'FixedWidth', ...
                'fontsize'                  , 14, ...
                'visible'                   , 'off', ...
                'enable'                    , 'inactive', ...
                'interruptible'             , 'off', ...
                'busyaction'                , 'queue', ...
                'horizontalalignment'       , 'left', ...
                'parent'                    , figH, ...
                'tag'                       , 'MessageTextBox');
            
            obj.handles             = guihandles(figH);
            obj.handles.figPos      = [];
            obj.handles.axPos       = [];
            obj.handles.lastDir     = dirname;
            obj.handles.ImX         = [];
            obj.handles.tm          = timer(...
                'name'            , 'image preview timer', ...
                'executionmode'   , 'fixedspacing', ...
                'objectvisibility', 'off', ...
                'taskstoexecute'  , inf, ...
                'period'          , 0.001, ...
                'startdelay'      , 3, ...
                'timerfcn'        , @obj.getPreviewImages);
            
            resizeFcn(obj);
            
            % Show initial directory
            showDirectory(obj);
            
            set(figH, 'visible', 'on');
            
        end
        %--------------------------------------------------------------------------
        % resizeFcn
        %   This resizes the figure window appropriately
        %--------------------------------------------------------------------------
        function resizeFcn(obj, varargin)
            
            set(obj.handles.ImageViewer, 'units', 'pixels');
            figPos = get(obj.handles.ImageViewer, 'position');
            
            % figure can't be too small or off the screen
            if figPos(3) < 750 || figPos(4) < 500
                figPos(3) = max([750 figPos(3)]);
                figPos(4) = max([500 figPos(4)]);
                screenSize = get(0, 'screensize');
                if figPos(1)+figPos(3) > screenSize(3)
                    figPos(1) = screenSize(3) - figPos(3) - 50;
                end
                if figPos(2)+figPos(4) > screenSize(4)
                    figPos(2) = screenSize(4) - figPos(4) - 50;
                end
                
                set(obj.handles.ImageViewer, 'position', figPos);
                
            end
            
            set(obj.handles.versionPanel         , 'position', [1, 1, 100, 25]);
            set(obj.handles.versionText          , 'position', [2, 2, 96, 20]);
            set(obj.handles.statusPanel          , 'position', [102, 1, figPos(3)-102, 25]);
            set(obj.handles.statusText           , 'position', [2, 2, figPos(3)-107, 20]);
            set(obj.handles.frame1               , 'position', [figPos(3)-115, figPos(4)-55, 110, 53]);
            set(obj.handles.ZoomCaptionText      , 'position', [5, 22, 100, 17]);
            set(obj.handles.ResetViewBtn1        , 'position', [5, 2, 47, 20]);
            set(obj.handles.ResetViewBtn2        , 'position', [55, 2, 47, 20]);
            set(obj.handles.HelpBtn              , 'position', [figPos(3)-220, figPos(4)-28, 100, 20]);
            set(obj.handles.FileInfoBtn          , 'position', [figPos(3)-220, figPos(4)-50, 100, 20]);
            set(obj.handles.CurrentDirectoryPanel, 'position', [20, figPos(4)-30, 215, 20]);
            set(obj.handles.CurrentDirectoryEdit , 'position', [1, 1, 213, 18]);
            set(obj.handles.ChooseDirectoryBtn   , 'position', [237, figPos(4)-30, 20, 20]);
            set(obj.handles.UpDirectoryBtn       , 'position', [259, figPos(4)-30, 20, 20]);
            set(obj.handles.FileListBox          , 'position', [20, 270, 260, figPos(4)-310]);
            set(obj.handles.PreviewImagePanel    , 'position', [20, 40, 260, 220]);
            set(obj.handles.PreviewImageAxes     , 'position', [5, 5, 245, 190]);
            set(obj.handles.ImageAxes            , 'position', [300, 40, figPos(3)-310, figPos(4)-120]);
            axPos = get(obj.handles.ImageAxes    , 'position');
            
            textBoxDim  = [400, 200];
            rightMargin = figPos(3)-(axPos(1)+axPos(3));
            topMargin   = figPos(4)-(axPos(2)+axPos(4));
            set(obj.handles.MessageTextBox      , 'position', [figPos(3)-rightMargin-textBoxDim(1), ...
                figPos(4)-topMargin-textBoxDim(2), ...
                textBoxDim]);
            obj.handles.figPos = figPos;
            obj.handles.axPos  = axPos;
            
            titleStr = get(get(obj.handles.ImageAxes, 'title'), 'string');
            if ~isempty(titleStr)
                % resize image as well
                loadImage(obj, titleStr);
            end
            
        end
        
        
        %--------------------------------------------------------------------------
        % fileInfoBtnCallback
        %   This displays the file info of the image that's displayed
        %--------------------------------------------------------------------------
        function fileInfoBtnCallback(obj, varargin)
            
            hObj = varargin{1};
            
            if get(hObj, 'value')
                
                % First 9 fields of IMFINFO are always the same
                fnames      = fieldnames(obj.handles.iminfo); fnames = fnames(1:9);
                vals        = struct2cell(obj.handles.iminfo); vals = vals(1:9);
                
                % Only show file name (not full path)
                [p, n, e]   = fileparts(vals{1}); %#ok<ASGLU>
                vals{1}     = [n e];
                sID         = cellfun('isclass', vals, 'char');
                dID         = cellfun('isclass', vals, 'double');
                fmt         = cell(2, 9);
                fmt(1, :)   = repmat({'%15s: '}, 1, 9);
                fmt(2, sID) = repmat({'%s|'}, 1, length(find(sID)));
                fmt(2, dID) = repmat({'%d|'}, 1, length(find(dID)));
                tmp         = [fnames(:),vals(:)]';
                str         = sprintf([fmt{:}], tmp{:});
                set(obj.handles.MessageTextBox, 'string', str, 'visible', 'on');
                
            else
                set(obj.handles.MessageTextBox, 'visible', 'off');
                
            end
            
        end
        
        %--------------------------------------------------------------------------
        % showDirectory
        %   This function shows a list of image files in the directory
        %--------------------------------------------------------------------------
        function showDirectory(obj, dirname)
            
            % Reset settings and images
            stopTimer(obj);
            cla(obj.handles.PreviewImageAxes);
            axis(obj.handles.PreviewImageAxes, 'normal');
            clearImageAxes(obj);
            %----------------------------------------------------------------------
            
            if nargin == 2
                obj.handles.lastDir = dirname;
            else
                if isempty(obj.handles.lastDir)
                    obj.handles.lastDir = pwd;
                end
            end
            
            set(obj.handles.CurrentDirectoryEdit, 'string', ...
                fixLongDirName(obj.handles.lastDir), ...
                'tooltipstring', obj.handles.lastDir);
            
            % Get image formats
            imf  = imformats;
            exts = lower([imf.ext]);
            exts_str = sprintf('%s|', exts{:}); exts_str(end) = '';
            d = dir(obj.handles.lastDir);

            filenames = sort({d(~[d.isdir]).name});
            filenames_L = lower(filenames);
            
            % Find all the image files
            imagefiles_idx = regexp(filenames_L, sprintf('[^ \f\n\r\t\v.]+\\.(%s)',exts_str));
            imagefiles = filenames(~cellfun(@isempty, imagefiles_idx));

            dirnames = sort({d([d.isdir]).name});
            dirnames(ismember(dirnames, {'.', '..'})) = '';            
            
            if isempty(imagefiles)
                obj.handles.imageID = [];
                obj.handles.imageNames = {};
                obj.handles.imagePreviews = {};
                runTimer = false;
            else
                obj.handles.imageID = 1:length(imagefiles);
                obj.handles.imageNames = imagefiles;
                obj.handles.imagePreviews = cell(1,length(imagefiles));
                runTimer = true;
            end
            
            if isempty(dirnames)
                n = imagefiles;
            else
                dirnames = strcat(repmat({'['}, 1, length(dirnames)), dirnames, repmat({']'}, 1, length(dirnames)));
                n = [dirnames, imagefiles];
                
                obj.handles.imageID = obj.handles.imageID + length(dirnames);
            end
            set(obj.handles.FileListBox, 'string', n, 'value', 1);
            
            if runTimer
                startTimer(obj);
            end
            
            if ~isempty(obj.handles.imageID)
                set(obj.handles.ImageViewer, 'selectiontype', 'normal');
                set(obj.handles.FileListBox, 'value', obj.handles.imageID(1));
                fileListBoxCallback(obj);
            end
            
        end
        
        %--------------------------------------------------------------------------
        % getPreviewImages
        %   This is the TimerFcn for the preview timer object
        %--------------------------------------------------------------------------
        function getPreviewImages(obj, varargin)
            
            try
                
                id = find(cellfun('isempty', obj.handles.imagePreviews));
                
                if ~isempty(id)
                    set(obj.handles.statusText, 'string', ...
                        sprintf('Generating Thumbnails ... %d of %d', ...
                        length(obj.handles.imagePreviews)-length(id)+1, ...
                        length(obj.handles.imagePreviews)));
                    drawnow;
                    obj.handles.imagePreviews{id(1)} = ...
                        getPreviewImageData(obj, ...
                        fullfile(get(obj.handles.CurrentDirectoryEdit, 'tooltipstring'), ...
                        obj.handles.imageNames{id(1)}));
                    
                else % All previews are generated. Stop timer
                    set(obj.handles.statusText, 'string', '');
                    stopTimer(obj);
                    
                end
                
            catch %#ok<CTCH>
                
            end
            
        end
        
        %--------------------------------------------------------------------------
        % getPreviewImageData
        %   This reads in image file for thumbnails
        %--------------------------------------------------------------------------
        function x = getPreviewImageData(obj, filename)
            
            x = readImageFileFcn(obj, filename);
            if ~isnan(x)
                sz = size(x);
                r = [200, 260] ./ sz(1:2);
                
                % Crude IMRESIZE (non-toolbox)
                xd = round(linspace(1,sz(1), round(sz(1) * min(r))));
                yd = round(linspace(1,sz(2), round(sz(2) * min(r))));
                x = x(xd, yd, :);
            end
            
        end
        
        %--------------------------------------------------------------------------
        % fileListBoxCallback
        %   This gets called when an entry is selected in the file list box
        %--------------------------------------------------------------------------
        function fileListBoxCallback(obj, hObj, varargin)
            
            if nargin == 1
                hObj = obj.handles.FileListBox;
            end
            stopTimer(obj);
            val = get(hObj, 'value');
            str = cellstr(get(hObj, 'string'));
            
            if ~isempty(str)
                
                switch get(obj.handles.ImageViewer, 'selectiontype')
                    case 'normal'   % single click - show preview
                        
                        if str{val}(1) == '[' && str{val}(end) == ']'
                            cla(obj.handles.PreviewImageAxes);
                            axis(obj.handles.PreviewImageAxes, 'normal');
                            
                        else
                            id = find(obj.handles.imageID == val);
                            if isempty(obj.handles.imagePreviews{id});
                                obj.handles.imagePreviews{id} = ...
                                    getPreviewImageData(obj, ...
                                    fullfile(...
                                    get(obj.handles.CurrentDirectoryEdit, 'tooltipstring'), ...
                                    str{val}));
                            end
                            
                            if ~isnan(obj.handles.imagePreviews{id})
                                image(obj.handles.imagePreviews{id}, ...
                                    'parent', obj.handles.PreviewImageAxes, ...
                                    'hittest', 'off');
                                set(obj.handles.PreviewImagePanel, 'buttondownfcn', @previewImageClickFcn);
                                
                            else % unable to load image
                                cla(obj.handles.PreviewImageAxes);
                                set(obj.handles.PreviewImagePanel, 'buttondownfcn', '');
                                text(0.5, 0.5, 'Can''t Load Image', ...
                                    'parent', obj.handles.PreviewImageAxes, ...
                                    'horizontalalignment', 'center', ...
                                    'verticalalignment', 'middle');
                                set(obj.handles.PreviewImageAxes, 'xlim', [0 1], 'ylim', [0 1]);
                                
                            end
                            
                            axis(obj.handles.PreviewImageAxes, 'equal');
                            set(obj.handles.PreviewImageAxes, 'visible', 'off');
                            
                        end
                        startTimer(obj);
                        
                    case 'open'   % double click - open image and display
                        
                        if str{val}(1) == '[' && str{val}(end) == ']'
                            dirname = get(obj.handles.CurrentDirectoryEdit, 'tooltipstring');
                            newdirname = fullfile(dirname, str{val}(2:end-1));
                            showDirectory(obj, newdirname)
                            
                        else
                            obj.handles.ImX = [];
                            loadImage(obj, fullfile(get(obj.handles.CurrentDirectoryEdit, 'tooltipstring'), str{val}));
                            
                            startTimer(obj);
                        end
                end
                
            end
            
            %----------------------------------------------------------------------
            % previewImageClickFcn
            %   This loads the image when the thumbnail is double-clicked
            %----------------------------------------------------------------------
            function previewImageClickFcn(varargin)
                
                switch get(obj.handles.ImageViewer, 'selectiontype')
                    
                    case 'open'   % double-click
                        
                        stopTimer(obj);
                        
                        obj.handles.ImX = [];
                        loadImage(obj, fullfile(get(obj.handles.CurrentDirectoryEdit, 'tooltipstring'), str{val}));
                        
                        startTimer(obj);
                        
                end
            end
            
        end
        
        %--------------------------------------------------------------------------
        % chooseDirectoryCallback
        %   This opens a directory selector
        %--------------------------------------------------------------------------
        function chooseDirectoryCallback(obj, varargin)
            
            stopTimer(obj);
            dirname = uigetdir(get(obj.handles.CurrentDirectoryEdit, 'tooltipstring'), ...
                'Choose Directory');
            if ischar(dirname)
                showDirectory(obj, dirname)
            end
            
        end
        
        %--------------------------------------------------------------------------
        % upDirectoryCallback
        %   This moves up the current directory
        %--------------------------------------------------------------------------
        function upDirectoryCallback(obj, varargin)
            
            stopTimer(obj);
            dirname = get(obj.handles.CurrentDirectoryEdit, 'tooltipstring');
            dirname2 = fileparts(dirname);
            if ~isequal(dirname, dirname2)
                showDirectory(obj, dirname2)
            end
            
        end
        
        %--------------------------------------------------------------------------
        % resetView
        %   This resets the view to "Full" or "100%" magnification
        %--------------------------------------------------------------------------
        function resetView(obj, varargin)
            
            hObj = varargin{1};
            stopTimer(obj);
            set(obj.handles.MessageTextBox, 'visible', 'off');
            set(obj.handles.FileInfoBtn, 'value', false);
            
            switch get(hObj, 'string')
                case 'Full'
                    xlimit = obj.handles.xlimFull;
                    ylimit = obj.handles.ylimFull;
                    
                case '100%'
                    xlimit = obj.handles.xlim100;
                    ylimit = obj.handles.ylim100;
            end
            
            xl = xlim(obj.handles.ImageAxes); xd = (xlimit - xl)/10;
            yl = ylim(obj.handles.ImageAxes); yd = (ylimit - yl)/10;
            
            % Restore only if needed
            if ~(isequal(xd, [0 0]) && isequal(yd, [0 0]))
                
                set(obj.handles.statusText, 'string', 'Restoring View...');
                
                % Animate with "good" speed
                for id = [1, 4, 6.5, 7.8, 8.5, 9, 9.3, 9.6, 9.8, 10]
                    
                    set(obj.handles.ImageAxes, ...
                        'xlim'                , xl + xd * id, ...
                        'ylim'                , yl + yd * id, ...
                        'cameraviewanglemode' , 'auto', ...
                        'dataaspectratiomode' , 'auto', ...
                        'plotboxaspectratio'  , obj.handles.pbar);
                    set(obj.handles.ZoomCaptionText, 'string', sprintf('%d %%', ...
                        round(diff(obj.handles.xlim100)/diff(xl + xd * id)*100)));
                    
                    pause(0.01);
                end
                
                set(obj.handles.statusText, 'string', '');
                
            end
            
            startTimer(obj);
            
        end
        
        %--------------------------------------------------------------------------
        % loadImage
        %   This loads the selected image and displays it
        %--------------------------------------------------------------------------
        function loadImage(obj, filename)
            
            try
                if isempty(obj.handles.ImX)
                    clearImageAxes(obj);
                    set(obj.handles.statusText, 'string', 'Loading Image...');
                    drawnow;
                    [obj.handles.ImX, obj.handles.iminfo] = readImageFileFcn(obj, filename);
                end
                
                if ~isnan(obj.handles.ImX)
                    iH = image(obj.handles.ImX, 'parent', obj.handles.ImageAxes);
                    set(iH, 'hittest', 'off');
                    axis(obj.handles.ImageAxes, 'equal');
                    set(obj.handles.ImageAxes, ...
                        'box'             , 'on', ...
                        'xtick'           , [], ...
                        'ytick'           , [], ...
                        'buttondownfcn'   , @obj.winBtnDownFcn, ...
                        'interruptible'   , 'off', ...
                        'busyaction'      , 'queue', ...
                        'handlevisibility', 'callback');
                    set(obj.handles.ResetViewBtn1, 'enable', 'on');
                    set(obj.handles.ResetViewBtn2, 'enable', 'on');
                    set(obj.handles.FileInfoBtn  , 'enable', 'on');
                    set(get(obj.handles.ImageAxes, 'title'), ...
                        'string'      , sprintf('%s', filename), ...
                        'interpreter' , 'none');
                    obj.handles.pbar     = get(obj.handles.ImageAxes, 'plotboxaspectratio');
                    obj.handles.xlimFull = get(obj.handles.ImageAxes, 'xlim');
                    obj.handles.ylimFull = get(obj.handles.ImageAxes, 'ylim');
                    
                    % If image is small, show at 100% size
                    sz              = size(obj.handles.ImX);
                    obj.handles.xlim100 = sz(2)/2 + [-1, 1] * obj.handles.axPos(3)/2;
                    obj.handles.ylim100 = sz(1)/2 + [-1, 1] * obj.handles.axPos(4)/2;
                    if all(obj.handles.axPos(3:4) > sz([2 1]))
                        set(obj.handles.ImageAxes, ...
                            'xlim'                , obj.handles.xlim100, ...
                            'ylim'                , obj.handles.ylim100, ...
                            'cameraviewanglemode' , 'auto', ...
                            'dataaspectratiomode' , 'auto', ...
                            'plotboxaspectratio'  , obj.handles.pbar);
                        set(obj.handles.ZoomCaptionText, 'string', '100 %');
                        
                    else
                        set(obj.handles.ZoomCaptionText, 'string', sprintf('%d %%', ...
                            round(diff(obj.handles.xlim100)/diff(obj.handles.xlimFull)*100)));
                    end
                end
                
            catch ME
                errordlg({'Could not open image file', ME.message}, 'Error');
                clearImageAxes(obj);
                
            end
            
            set(obj.handles.statusText, 'string', '');
            
        end
        
        %--------------------------------------------------------------------------
        % clearImageAxes
        %   This clears the image axis
        %--------------------------------------------------------------------------
        function clearImageAxes(obj)
            
            cla(obj.handles.ImageAxes);
            axis(obj.handles.ImageAxes, 'normal');
            set(get(obj.handles.ImageAxes, 'title') , 'string'        , '');
            set(obj.handles.ImageAxes               , 'buttondownfcn' , '');
            set(obj.handles.ResetViewBtn1           , 'enable'        , 'off');
            set(obj.handles.ResetViewBtn2           , 'enable'        , 'off');
            set(obj.handles.FileInfoBtn             , 'enable'        , 'off', ...
                'value'         , false);
            set(obj.handles.ZoomCaptionText         , 'string'        , '');
            set(obj.handles.MessageTextBox          , 'visible'       , 'off');
            obj.handles.ImX = [];
            
        end
        
        %--------------------------------------------------------------------------
        % winBtnDownFcn
        %   This is called when the mouse is clicked in one of the axes
        %   NORMAL clicks will start panning mode.
        %   ALT clicks will start zooming mode.
        %   OPEN clicks will center the view.
        %--------------------------------------------------------------------------
        function winBtnDownFcn(obj, hObj, varargin)
            
            stopTimer(obj);
            set(obj.handles.MessageTextBox, 'visible', 'off');
            set(obj.handles.FileInfoBtn, 'value', false);
            
            switch get(obj.handles.ImageViewer, 'selectiontype')
                case 'normal'
                    % Start panning mode
                    
                    xy = get(hObj, 'currentpoint');
                    set(obj.handles.ImageViewer, ...
                        'pointer'               , 'custom', ...
                        'pointershapecdata'     , ImageViewer.closedHandPointer, ...
                        'windowbuttonmotionfcn' , @winBtnMotionFcn);
                    set(obj.handles.ImageViewer, 'windowbuttonupfcn', @obj.winBtnUpFcn);
                    
                case 'alt'
                    % Start zooming mode
                    
                    xl = get(hObj, 'xlim'); midX = mean(xl); rngXhalf = diff(xl) / 2;
                    yl = get(hObj, 'ylim'); midY = mean(yl); rngYhalf = diff(yl) / 2;
                    curPt  = mean(get(hObj, 'currentpoint'));curPt = curPt(1:2);
                    curPt2 = (curPt-[midX, midY]) ./ [rngXhalf, rngYhalf];
                    curPt  = [curPt; curPt];
                    curPt2 = [-(1+curPt2).*[rngXhalf, rngYhalf];...
                        (1-curPt2).*[rngXhalf, rngYhalf]];
                    initPt = get(obj.handles.ImageViewer, 'currentpoint');
                    set(obj.handles.statusText, 'string', 'Zooming...');
                    set(obj.handles.ImageViewer, ...
                        'pointer'               , 'custom', ...
                        'pointershapecdata'     , ImageViewer.zoomInOutPointer, ...
                        'windowbuttonmotionfcn' , @zoomMotionFcn);
                    set(obj.handles.ImageViewer, 'windowbuttonupfcn', @obj.winBtnUpFcn);
                    
                case 'open'
                    % Center the view
                    
                    set(obj.handles.ImageViewer, 'windowbuttonupfcn', @obj.winBtnUpFcn);
                    
                    % Get current units
                    un    = get(0, 'units');
                    set(0, 'units', 'pixels');
                    pt2   = get(0, 'pointerlocation');
                    pt    = get(hObj, 'currentpoint');
                    axPos = get(hObj, 'position');
                    xl = get(hObj, 'xlim'); midX = mean(xl);
                    yl = get(hObj, 'ylim'); midY = mean(yl);
                    
                    % update figure position in case it was moved
                    obj.handles.figPos = get(obj.handles.ImageViewer, 'position');
                    
                    % get distance between cursor and center of axes
                    d = norm(pt2 - (obj.handles.figPos(1:2) + axPos(1:2) + axPos(3:4)/2));
                    
                    if d > 2  % center only if distance is at least 2 pixels away
                        ld = (mean(pt(:, 1:2)) - [midX, midY]) / 10;
                        pd = ((obj.handles.figPos(1:2) + axPos(1:2) + axPos(3:4) / 2) - pt2) / 10;
                        
                        set(obj.handles.statusText, 'string', 'Centering...');
                        
                        % Animate with "good" speed
                        for id = [1, 4, 6.5, 7.8, 8.5, 9, 9.3, 9.6, 9.8, 10]
                            
                            % Set axes limits and automatically set ticks
                            % Set aspect ratios
                            set(hObj, ...
                                'xlim'                , xl + id * ld(1), ...
                                'ylim'                , yl + id * ld(2), ...
                                'cameraviewanglemode' , 'auto', ...
                                'dataaspectratiomode' , 'auto', ...
                                'plotboxaspectratio'  , obj.handles.pbar);
                            
                            % Move pointer with limits
                            set(0, 'pointerlocation', pt2 + id * pd);
                            
                            pause(0.01);
                        end
                        
                    end
                    
                    % Reset UNITS
                    set(0, 'units', un);
                    
            end
            
            %----------------------------------------------------------------------
            % winBtnMotionFcn (nested under winBtnDownFcn)
            %   This function is called when click-n-drag (panning) is happening
            %----------------------------------------------------------------------
            function winBtnMotionFcn(varargin)
                
                pt = get(obj.handles.ImageAxes, 'currentpoint');
                
                % Update axes limits and automatically set ticks
                % Set aspect ratios
                set(obj.handles.ImageAxes, ...
                    'xlim', get(obj.handles.ImageAxes, 'xlim') + (xy(1,1)-(pt(1,1)+pt(2,1))/2), ...
                    'ylim', get(obj.handles.ImageAxes, 'ylim') + (xy(1,2)-(pt(1,2)+pt(2,2))/2), ...
                    'cameraviewanglemode' , 'auto', ...
                    'dataaspectratiomode' , 'auto', ...
                    'plotboxaspectratio'  , obj.handles.pbar);
                set(obj.handles.statusText, 'string', 'Panning...');
                
            end
            
            
            %----------------------------------------------------------------------
            % zoomMotionFcn (nested under winBtnDownFcn)
            %   This performs the click-n-drag zooming function. The pointer
            %   location relative to the initial point determines the amount of
            %   zoom (in or out).
            %----------------------------------------------------------------------
            function zoomMotionFcn(hObj, varargin)
                
                % Power law allows for the inverse to work:
                %      C^(x) * C^(-x) = 1
                % Choose C to get "appropriate" zoom factor
                C                   = 50;
                pt                  = get(hObj, 'currentpoint');
                r                   = C ^ ((initPt(2) - pt(2)) / obj.handles.figPos(4));
                newLimSpan          = r * curPt2; dTemp = diff(newLimSpan);
                pt(1)               = initPt(1);
                
                % Determine new limits based on r
                lims                = curPt + newLimSpan;
                
                % Update axes limits and automatically set ticks
                % Set aspect ratios
                set(obj.handles.ImageAxes, ...
                    'xlim'                , lims(:,1), ...
                    'ylim'                , lims(:,2), ...
                    'cameraviewanglemode' , 'auto', ...
                    'dataaspectratiomode' , 'auto', ...
                    'plotboxaspectratio'  , obj.handles.pbar);
                
                % Update zoom indicator line
                set(obj.handles.ZoomLine, ...
                    'xdata', [initPt(1), pt(1)]/obj.handles.figPos(3), ...
                    'ydata', [initPt(2), pt(2)]/obj.handles.figPos(4));
                set(obj.handles.ZoomCaptionText, 'string', sprintf('%d %%', ...
                    round(diff(obj.handles.xlim100)/dTemp(1)*100)));
                
            end
            
        end
        
        
        function scrollWheelFcn(obj, varargin)
            
            stopTimer(obj);
            
            if ~isempty(obj.handles.ImX)
                
                % Power law allows for the inverse to work:
                %      C^(x) * C^(-x) = 1
                % Choose C to get "appropriate" zoom factor
                C                   = 1.02;
                
                xl = get(obj.handles.ImageAxes, 'xlim'); midX = mean(xl); rngXhalf = diff(xl) / 2;
                yl = get(obj.handles.ImageAxes, 'ylim'); midY = mean(yl); rngYhalf = diff(yl) / 2;
                curPt  = mean(get(obj.handles.ImageAxes, 'currentpoint'));curPt = curPt(1:2);
                curPt2 = (curPt-[midX, midY]) ./ [rngXhalf, rngYhalf];
                curPt  = [curPt; curPt];
                curPt2 = [-(1+curPt2).*[rngXhalf, rngYhalf];...
                    (1-curPt2).*[rngXhalf, rngYhalf]];
                
                edata = varargin{2};
                r = C^(edata.VerticalScrollCount*edata.VerticalScrollAmount);
                newLimSpan          = r * curPt2;dTemp = diff(newLimSpan);
                
                % Determine new limits based on r
                lims                = curPt + newLimSpan;
                
                % Update axes limits and automatically set ticks
                % Set aspect ratios
                set(obj.handles.ImageAxes, ...
                    'xlim'                , lims(:,1), ...
                    'ylim'                , lims(:,2), ...
                    'cameraviewanglemode' , 'auto', ...
                    'dataaspectratiomode' , 'auto', ...
                    'plotboxaspectratio'  , obj.handles.pbar);
                
                % Update zoom value
                set(obj.handles.ZoomCaptionText, 'string', sprintf('%d %%', ...
                    round(diff(obj.handles.xlim100)/dTemp(1)*100)));
                
            end
            
            startTimer(obj);
            
        end
        
        %--------------------------------------------------------------------------
        % winBtnUpFcn
        %   This is called when the mouse is released
        %--------------------------------------------------------------------------
        function winBtnUpFcn(obj, hObj, varargin)
            
            set(hObj, ...
                'pointer'               , 'arrow', ...
                'windowbuttonmotionfcn' , '');
            set(obj.handles.statusText, 'string', '');
            set(obj.handles.ZoomLine, 'xdata', NaN, 'ydata', NaN);
            set(obj.handles.ImageViewer, 'windowbuttonupfcn', '');
            
            startTimer(obj);
            
        end
        
        
        %--------------------------------------------------------------------------
        % startTimer
        %   This starts the timer. If the timer object is invalid, it creates a new
        %   one.
        %--------------------------------------------------------------------------
        function startTimer(obj)
            
            try
                
                if ~strcmpi(obj.handles.tm.Running, 'on');
                    start(obj.handles.tm);
                end
                
            catch %#ok<CTCH>
                
                obj.handles.tm          = timer(...
                    'name'            , 'image preview timer', ...
                    'executionmode'   , 'fixedspacing', ...
                    'objectvisibility', 'off', ...
                    'taskstoexecute'  , inf, ...
                    'period'          , 0.001, ...
                    'startdelay'      , 3, ...
                    'timerfcn'        , @obj.getPreviewImages);
                start(obj.handles.tm);
                
            end
            
        end
        
        
        %--------------------------------------------------------------------------
        % stopTimerFcn
        %   This gets called when the figure is closed.
        %--------------------------------------------------------------------------
        function stopTimerFcn(obj, varargin)
            
            stop(obj.handles.tm);
            % wait until timer stops
            while ~strcmpi(obj.handles.tm.Running, 'off')
                drawnow;
            end
            delete(obj.handles.tm);
            
        end
        
        
        %--------------------------------------------------------------------------
        % stopTimer
        %   This stops the timer object used for generating image previews
        %--------------------------------------------------------------------------
        function stopTimer(obj, varargin)
            
            stop(obj.handles.tm);
            
            % wait until timer stops
            while ~strcmpi(obj.handles.tm.Running, 'off')
                drawnow;
            end
            
            set(obj.handles.statusText, 'string', '');
            
        end
        
        
        %--------------------------------------------------------------------------
        % readImageFileFcn
        %   This function reads in the image file and converts to TRUECOLOR
        %--------------------------------------------------------------------------
        function [x, info] = readImageFileFcn(obj, filename)
            
            try
                [x, mp] = imread(filename);
                info = imfinfo(filename);
                info = info(1);
                
                switch info.ColorType
                    case 'grayscale'
                        switch class(x)
                            case 'logical'
                                x = uint8(x);
                                mp = [0 0 0;1 1 1];
                                
                            case 'uint8'
                                mp = gray(256);
                                
                            case 'uint16'
                                mp = gray(2^16);
                                
                            case {'double','single'}
                                cmapsz = size(get(obj.handles.ImageViewer, 'Colormap'), 1);
                                mp = gray(cmapsz);
                                
                            case 'int16'
                                x = double(x)+2^15;
                                x = uint16((x-min(x(:)))/(max(x(:))-min(x(:)))*(2^16));
                                mp = gray(2^16);
                                
                            otherwise
                                cmapsz = size(get(obj.handles.ImageViewer, 'Colormap'), 1);
                                mp = gray(cmapsz);
                        end
                        x = ind2rgb(x, mp);
                        
                    case 'indexed'
                        if isempty(mp)
                            mp = info.Colormap;
                        end
                        x = ind2rgb(x, mp);
                        
                    otherwise
                end
                
            catch %#ok<CTCH>
                x = NaN;
                info = [];
                
            end
        end
        
    end
end



%--------------------------------------------------------------------------
% fixLongDirName
%   This truncates the directory string if it is too long to display
%--------------------------------------------------------------------------
function newdirname = fixLongDirName(dirname)
% Modify string for long directory names
if length(dirname) > 20
    [tmp1, tmp2] = strtok(dirname, filesep); %#ok<ASGLU>
    if isempty(tmp2)
        newdirname = dirname;
        
    else
        % in case the directory name starts with a file separator.
        id = strfind(dirname, tmp2);
        tmp1 = dirname(1:id(1));
        [p, tmp2] = fileparts(dirname);
        if strcmp(tmp1, p) || isempty(tmp2)
            newdirname = dirname;
            
        else
            newdirname = fullfile(tmp1, '...', tmp2);
            tmp3 = '';
            while length(newdirname) < 20
                tmp3 = fullfile(tmp2, tmp3);
                [p, tmp2] = fileparts(p);
                if strcmp(tmp1, p)  % reach root directory
                    newdirname = dirname;
                    %break; % it will break because dirname is longer than 30 chars
                    
                else
                    newdirname = fullfile(tmp1, '...', tmp2, tmp3);
                    
                end
            end
        end
    end
else
    newdirname = dirname;
end

end


%--------------------------------------------------------------------------
% helpBtnCallback
%   This opens up a help dialog box
%--------------------------------------------------------------------------
function helpBtnCallback(varargin)

helpdlg({...
    'Navigate through directories using the list box on the left.', ...
    'Single-click to see the preview.', ...
    'Double-click (list box OR preview image) to open and display image.', ...
    '', 'Click and drag to pan the image.', ...
    'Right click and drag to zoom. (or scroll wheel if R2007a or later)', ...
    'Double-click to center view.', ...
    '''Full'' displays the whole image.', ...
    '''100%'' displays the image at the true resolution.', ...
    '''File Info'' displays the current image file info.'}, 'Help');

end
