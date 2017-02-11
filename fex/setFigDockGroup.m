function hGroupContainer = setFigDockGroup(varargin)
% setFigDockGroup Sets a figure's docking group container
%
% Syntax:
%    hGroupContainer = setFigDockGroup(hFig, group)
%    hButton         = setFigDockGroup(hFig, hButton)
%
% Description:
%    setFigDockGroup sets a figure's (or list of figures') docking group
%    container, enabling to dock figures to containers other than the
%    default 'Figures' container (for example, to the 'Editor' group, or
%    to any new user-defined group or even to another figure's button).
%
%    Changing docked figure(s)'s group will automatically transfer the
%    specified figure(s) to the new group container. Changing undocked
%    figure(s)'s group has no immediate visible effect (until the next
%    docking, when the figure(s) will dock into the new group).
%
%    Note: Matlab automatically updates the group's toolbar and menu based
%    on the component currently in focus. So even if you dock a figure onto
%    the Editor, when you focus on the figure you'll see the familiar figure
%    menu & toolbar - not the text editor's.
%
%    setFigDockGroup(hFig,hButton) will dock the figure hFig to another
%    figure's button hButton. The button needs to be a uicontrol pushbutton,
%    which would typically be labeled "undock" or have an undocking icon.
%    This button will only be enabled when the target figure is docked.
%    Only a single figure may be docked to any hButton. When hButton is
%    deleted, the target figure hFig will also be destroyed.
%
% Inputs:
%    hFig is an optional handle or list of handles. These are normally
%    figure handles, but not necessarily: the handles' containing figures
%    are automatically inferred and used. If hFig is not supplied, then
%    the current figure handle (gcf) is assumed.
%
%    GROUP is a string - the case-ensitive name of the requested group
%    container. If GROUP does not yet exist, then a new group by this name is
%    created (some pre-existing groups: 'Editor', 'Figures', 'Web Browser').
%    Note that docking figures in some pre-existing groups (e.g.,
%    'Web Browser') works well but looks weird...
%
%    GROUP may also be a group handle - the hGroupContainer output of a
%    previous setFigDockGroup function call.
%
%    hButton is the handle of a uicontrol pushbutton. Either hButton or GROUP
%    must be specified.
%
% Outputs:
%    The returned hGroupContainer object allows access to many useful
%    properties and callbacks. Type "get(hGroupContainer)" to see the full
%    list.
%
% Examples:
%    % Docking into a container group:
%    setFigDockGroup(gcf,'Editor');  % dock current figure to Editor group
%    setFigDockGroup(gcf,'my new group');  % dock fig to a new user group
%    setFigDockGroup('my new group');  % same as above (gcf is inferred)
%    hGroup = setFigDockGroup(gcf,'Editor');  % get handle to group container
%    setFigDockGroup(gcf,hGroup);  % use previously-specified group container
%
%    % Docking into a figure:
%    hButton = uicontrol('string','undock');
%    hFig=figure; setFigDockGroup(hfig,hButton);
%
% Side Effects:
%    When docking into a container, the requested container becomes visible,
%    unless it is undocked AND does not contain any docked components.
%
% Limitations:
%    1. It is not possible to dock into a figure panel - only to to a figure
%       button (minimized). Maybe some future version will handle this.
%    2. When the group container is not visible, hGroupContainer returns empty
%
% Warning:
%    This code heavily relies on undocumented and unsupported Matlab
%    functionality. It works on Matlab 7.4+, but use at your own risk!
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% Change log:
%    2007-09-30: First version posted on <a href="http://www.mathworks.com/matlabcentral/fileexchange/16650-setfigdockgroup">MathWorks File Exchange</a>
%    2010-05-23: Enabled docking to a figure button (minimized), and undocking back from that figure button
%    2011-10-14: Fix for R2011b
%    2012-11-18: Fix for Macs
%    2016-05-22: Removed annoying warnings about possible future features removal (yes, we know...)
%
% See also:
%    gcf, <a href="http://tinyurl.com/32alwt">getJFrame</a>, 
%    <a href="http://tinyurl.com/2fleuf">setDesktopVisibility</a> (last two on the File Exchange)
%    <a href="http://tinyurl.com/32q6hb">how to modify group container size/docking etc.</a> (comments #9,11)

% Programmed by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.4 $  $Date: 2016/05/22 16:35:05 $

  try
      % Sanity checks before starting...
      oldWarn = warning('off','MATLAB:nargchk:deprecated');
      error(nargchk(1,inf,nargin,'struct')); %#ok<NCHKN>
      warning(oldWarn);

      % Require Java engine to run
      if ~usejava('jvm')
          error([mfilename ' requires Java to run.']);
      end

      % Default figure = current (gcf)
      hFig = varargin{1};
      if isjava(hFig) || ischar(hFig)
          hFig = gcf;
      elseif isempty(hFig) || ~all(ishghandle(hFig))
          error('hFig must be a valid GUI handle or array of handles');
      else
          % Valid HG handles
          varargin(1) = [];  % remove hFig entry
      end

      % Get the group (create new group if necessary)
      if isempty(varargin)
          error('Must supply a valid group name or handle');
      end
      group = varargin{1};
      desktop = getDesktop;  % = com.mathworks.mde.desk.MLDesktop.getInstance;
      dockIntoButtonFlag = false;
      % Only add a new group if group name (not handle) was supplied
      if ischar(group)
          currentGroupNames = cell(desktop.getGroupTitles);
          if ~any(strcmp(group,currentGroupNames))
              desktop.addGroup(group);
          end
      elseif isscalar(group) && isnumeric(group) && ishandle(group) && ...
             isa(handle(group),'uicontrol') && strcmpi(get(group,'Style'),'pushbutton')
          % Dock into a pushbutton control
          dockIntoButtonFlag = true;
          if length(hFig) > 1
              warning('YMA:setFigDockGroup:multiFigDock','Docking can only be done into a single figure - ignoring extra handles');
          end
          hFig = hFig(1);
      else
          % Extract group name from the container's userdata
          % Note: using group.getName is more elegant, but might mess us default groups
          group = get(group,'userdata');
      end

      hFig1 = getHFig(hFig(1));

      % If figure docking was requested
      if dockIntoButtonFlag

          % Ensure source button is not reused
          if ~isempty(get(group,'Callback'))
              error('YMA:setFigDockGroup:duplicateDocks','Callback already set on source button: perhaps docking was already set for this button?');
          elseif isequal(hFig1,getHFig(group))
              error('YMA:setFigDockGroup:selfDock','Cannot dock a figure to itself!');
          end

          % Instrument source docking button
          % Akh! - the 'ActionEvent' is not triggered for some unknown reason!
          %hListener = handle.listener(handle(group),'ActionEvent',{@figUndockCallback,hFig1,group,hDockIcon});
          %setappdata(group,'dockListener__',hListener);
          set(group,'Callback',{@figUndockCallback,hFig1,group});

          % Disable the docking button while main figure is undocked
          set(group,'Enable','off');

          % Destroy jFrame/hFig1 upon source button destruction
          %hListener = handle.listener(handle(group),'ObjectBeingDestroyed',{@dockDeleteCallback,hFig1});
          set(handle(group),'DeleteFcn',{@dockDeleteCallback,hFig1});

          % Re-instrument the figure's docking button
          reinstrumentDockIcon(hFig1,group);

          % Trivial return value
          hContainer = hFig1;
      else
          % Temporarily dock first figure into the group, to ensure container creation
          % Note side effect: group container becomes visible
          jFrame = getJFrame(hFig1);
          set(jFrame,'GroupName',group);
          oldStyle = get(hFig1,'WindowStyle');
          set(hFig1,'WindowStyle','docked');  drawnow
          
          %set(hFig1,'WindowStyle',oldStyle);  drawnow
          
          % Loop over all other requested figures (if any)
          for figIdx = 2 : length(hFig)
              % Get the root Java frame
              jff = getJFrame(hFig(figIdx));
              % Set the frame's docking group to the selected group name
              set(jff,'GroupName',group);
          end
          
          % Get the group container
          hContainer = desktop.getGroupContainer(group);
          
          % Preserve the group name in the container's userdata, for future use by user
          %set(hContainer,'userdata',group);
          
          % Hide the group container if it's undocked AND empty (no docked figures)
          if strcmp(get(desktop.getGroupLocation(group),'Docked'),'off') && ...
                  hContainer.getComponent(1).getComponentCount == 0
              % Hide the group container
              hContainer.getTopLevelAncestor.hide;
          end
      end

      % Initialize output var, if requested
      if nargout
          hGroupContainer = hContainer;
      end

  % Error handling
  catch ME
      v = version;
      if v(1)<='6'
          err.message = lasterr;  %#ok<LERR> % no lasterror function...
      else
          err = lasterror; %#ok<LERR>
      end
      try
          err.message = regexprep(err.message,'Error using ==> [^\n]+\n','');
      catch
          try
              % Another approach, used in Matlab 6 (where regexprep is unavailable)
              startIdx = strfind(err.message,'Error using ==> ');
              stopIdx = strfind(err.message,char(10));
              for idx = length(startIdx) : -1 : 1
                  idx2 = min(find(stopIdx > startIdx(idx)));  %#ok ML6
                  err.message(startIdx(idx):stopIdx(idx2)) = [];
              end
          catch
              % never mind...
          end
      end
      if isempty(strfind(err.message,mfilename))
          % Indicate error origin, if not already stated within the error message
          err.message = [mfilename ': ' err.message];
      end
      if v(1)<='6'
          while err.message(end)==char(10)
              err.message(end) = [];  % strip excessive Matlab 6 newlines
          end
          error(err.message);
      else
          rethrow(err);
      end
  end

%% Get the Java desktop reference
function desktop = getDesktop
  try
      desktop = com.mathworks.mde.desk.MLDesktop.getInstance;      % Matlab 7+
  catch
      desktop = com.mathworks.ide.desktop.MLDesktop.getMLDesktop;  % Matlab 6
  end

%% Get the Matlab HG figure handle for a given handle
function hFig = getHFig(handle)
  hFig = ancestor(handle,'figure');
  if isempty(hFig)
      error(['Cannot retrieve the figure handle for handle ' num2str(handle)]);
  end

%% Get the root Java frame (up to 10 tries, to wait for figure to become responsive)
function jframe = getJFrame(hFigHandle)

  % Ensure that hFig is a figure handle...
  hFig = getHFig(hFigHandle);
  hhFig = handle(hFig);

  jframe = [];
  maxTries = 10;
  oldWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
  while maxTries > 0
      try
          % Get the figure's underlying Java frame
          jframe = get(handle(hhFig),'JavaFrame');
          if ~isempty(jframe)
              break;
          else
              maxTries = maxTries - 1;
              drawnow; pause(0.1);
          end
      catch
          maxTries = maxTries - 1;
          drawnow; pause(0.1);
      end
  end
  warning(oldWarn);
  if isempty(jframe)
      error(['Cannot retrieve the java frame for handle ' num2str(hFigHandle)]);
  end

%% Figure docking callack function
function figDockCallback(hObj,hEventData,hFig1,hSource,hDockIcon)  %#ok unused
  set(hDockIcon,'AncestorRemovedCallback',[]);
  set(hSource,'Enable','on');
  set(hFig1,'Visible','off');
  animate(hFig1,hSource,true);

%% Figure undocking callack function
function figUndockCallback(hObj,hEventData,hFig1,hSource)  %#ok unused
  animate(hFig1,hSource,false);
  set(hFig1,'Visible','on');
  set(hSource,'Enable','off');
  reinstrumentDockIcon(hFig1,hSource);

%% Figure deletion callback function
function figDeleteCallback(hObj,hEventData,hSource)  %#ok unused
  try set(hSource,'Enable','off'); catch,  end

%% Docking deletion callback function
function dockDeleteCallback(hObj,hEventData,hFig1)  %#ok unused
  try delete(hFig1); catch,  end

% Re-instrument the figure's docking button
function reinstrumentDockIcon(hFig1,hSource)
  drawnow; pause(0.1);  % Ensure everything's visible...
  jFrame = getJFrame(hFig1);
  try
      jClient = jFrame.fFigureClient;
  catch
      jClient = jFrame.fHG1Client;
  end
  jClient.setClientDockable(true);
  try
      jPanel = jClient.getMenuBar.getParent.getComponent(0);
      jDockIcon = jPanel.getComponent(1);
  catch
      % Probably mac
      jDockIcon = jPanel.getComponent(0).getComponent(0).getComponent(0).getComponent(0).getComponent(1).getComponent(0).getComponent(1);
  end
  jDockIcon.removeActionListener(jDockIcon.getActionListener);
  jDockIcon.getActionMap.clear;
  hDockIcon = handle(jDockIcon,'CallbackProperties');
  set(hDockIcon,'MouseClickedCallback',{@figDockCallback,hFig1,hSource,hDockIcon});
  set(hDockIcon,'AncestorRemovedCallback',{@figDeleteCallback,hSource});

% Animate docking/undocking
function animate(hFig1,hSource,dockFlag)
  numSteps = 10;
  startPos = getpixelposition(hFig1);
  hSourceFigPos = getpixelposition(getHFig(hSource));
  endPos = getpixelposition(hSource,true) + [hSourceFigPos(1:2),0,0];
  deltaPos = endPos - startPos;
  newFigPos = endPos - dockFlag*deltaPos;
  drawnow;
  hFig = figure('Name',get(hFig1,'Name'), 'Menu',get(hFig1,'Menu'), 'Toolbar',get(hFig1,'Toolbar'), ...
                'Number',get(hFig1,'Number'), 'Units','pixel', 'Pos',newFigPos);
  drawnow;
  for step = 1 : numSteps
      drawnow; %pause(0.02);
      if dockFlag
          newPos = startPos + deltaPos*step/numSteps;
      else  % undock
          newPos = startPos + deltaPos*(numSteps-step)/numSteps;
      end
      set(hFig,'pos',newPos);
  end
  delete(hFig);
