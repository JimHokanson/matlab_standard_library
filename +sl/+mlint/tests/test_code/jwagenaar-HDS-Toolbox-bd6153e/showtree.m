function showtree(input)
  %SHOWTREE  Shows an interactive schematic of the database.
  %   SHOWTREE(OBJ) shows an interactive schematic of the database
  %   associated with OBJ. Using the GUI, it is possible to see the
  %   relation between the different classes in the current database and
  %   show all methods and properties associated with each of these
  %   classes.
  %
  %   SHOWTREE(CLASSES) shows the relation between classes in the
  %   cell-array of classnames CLASSES.
  %
  %   Future versions will also enable the user to visualize linked
  %   classes in the database and the inherited class definitions for
  %   each of the classes.
    
  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.

  % known issues:
  % edit does not work correctly (bug in gethelp)

  % The variable tree will later be determined by an input to the
  % showtreeui function.
  
  if isa(input, 'HDS')
    input = class(input);
  end
  assert(ischar(input),'SHOWTREE: Incorrect input argument.');
  
  tree = hdstreestruct(input);
  cpHandle = createGUI;
  defbuttons(cpHandle, tree);
  setNoSelection(cpHandle,[]);
end

% Scroll Methods
function bd(h,~,~)

  %disp('down')

  fig = ancestor(h,'figure');

  % get the values and store them in the figure's appdata
  props.WindowButtonUpFcn = get(fig,'WindowButtonUpFcn');

  setappdata(fig,'TestGuiCallbacks',props);

  startM = get(0,'PointerLocation');

  startx = get(h,'XLim');
  starty = get(h,'YLim');

  % Setting timer: This means that we start a timer as soon as we press
  % the mouse button. This timer calls the updateScroll method every 50ms
  % We also set the WindowButtonUp function which stops the timer as soon
  % as the mouse is released.

  ui_timer = timer;
  set(ui_timer, 'ExecutionMode', 'fixedSpacing');
  set(ui_timer, 'Period', 0.05);
  set(ui_timer, 'BusyMode','drop');
  set(ui_timer, 'TimerFcn', {@updateScroll, h, startx, starty, startM});
  start(ui_timer);
  set(fig,'WindowButtonUpFcn',{@wbu, ui_timer})
end

function updateScroll(~,~, axesHandle, startx, starty, startm)
  persistent prevCoord

  if isempty(prevCoord); prevCoord = [0 0];end

  curPoint = get(0,'PointerLocation'); %Pointer location in points

  % Points to centimeters: 72dots/inch --> cm
  dimLim = (curPoint- startm)/28.3;
  if any(abs(prevCoord - curPoint) > 0.01)
    set(axesHandle,'XLim',startx-dimLim(1),'YLim',starty-dimLim(2));
  end
  prevCoord = curPoint;
end

function wbu(h,~, timerHandle)
  % When the mousebutton is released, this function stops the timer and
  % removes this function as a callback for mouseup. This is necessary so
  % that this function is not called when you click anywhere outside the
  % figure...

  %disp('up')
  stop(timerHandle);
  delete(timerHandle);

  fig = ancestor(h,'figure');

  props = getappdata(fig,'TestGuiCallbacks');
  set(fig,props);
  setappdata(fig,'TestGuiCallbacks',[]);
end

% Resize Methods
function figResize(src,~)
  fpos = get(src,'Position');
  children = get(src,'Children');
  botPanel = findobj(children,'Tag','botP');
  rightPanel = findobj(children,'Tag','rigP');
  centerPanel = findobj(children,'Tag','cenP');

  try
    mincenter = 6;
    textBoxPercentage = ((fpos(4)-mincenter)/fpos(4))*0.7;


    set(botPanel,'Position',...
        [0.2 0.2 fpos(3)-.4 fpos(4)*textBoxPercentage])
    bpos = get(botPanel,'position');


    rwidth = max([4  fpos(3)*0.3]);
    rwidth = min([fpos(3)- 0.6-0.2 rwidth]);
    rheigth = max([0.1 fpos(4) - bpos(4)-0.6]);

    set(rightPanel,'Position',...
        [fpos(3)-rwidth-0.2 bpos(2)+bpos(4)+0.2 rwidth rheigth])

    cwidth = max([0.2 fpos(3)-rwidth-0.6]);
    cheigth = max([0.1 fpos(4) - bpos(4)-0.6]);

    set(centerPanel,'Position',...
        [0.2 bpos(2)+bpos(4)+0.3 cwidth cheigth-0.1]);

    cPLim = [get(centerPanel,'XLim') get(centerPanel,'YLim') ];
    set(centerPanel,'Xlim',[cPLim(1) cwidth+cPLim(1)],'Ylim',[cPLim(4)-cheigth cPLim(4)]);

  catch %#ok<CTCH>
    %No error
  end
end

function botPanelResize(src, ~)
  bpos = get(src,'Position');

  t1 = 3;
  t2 = 1;
  try
    tHandle1 = findobj(get(src,'Children'),'Tag','Textbox1');
    tHandle2 = findobj(get(src,'Children'),'Tag','Textbox2');
    tHandle3 = findobj(get(src,'Children'),'Tag','Textbox3');

    set(tHandle1,'Position',[0 bpos(4)-t1 bpos(3) t1]);
    set(tHandle2,'Position',[0 bpos(4)-(t1+t2) bpos(3) t2]);
    set(tHandle3,'Position',[0 0 bpos(3) bpos(4)-(t1+t2)]);

  catch %#ok<CTCH>
    %No error
  end
end

function rightPanelResize(src,~)
  rpos = get(src,'Position');

  %resize listbox with properties
  listHandle = findobj(get(src,'Children'),'Tag','Listbox2');
  set(listHandle,'Units','pixels');
  width = get(listHandle,'Position');
  set(listHandle,'Units','centimeters');

  button1Handle = findobj(get(src,'Children'),'Tag','button1');
  button2Handle = findobj(get(src,'Children'),'Tag','button2');
  button3Handle = findobj(get(src,'Children'),'Tag','button3');

  try
    set(button1Handle,'Position', [0.1 rpos(4)-1 2.4 1]);

    set(button3Handle,'Position', [2.6 rpos(4)-1 2.4 1]);
    set(button2Handle,'Position', [5.1 rpos(4)-1 2.4 1]);

    set(listHandle,'Position', [0 0 rpos(3) rpos(4)/2-0.6 ],'ColumnWidth',{width(3)-20});

    %resize listbox with methods
    listHandle = findobj(get(src,'Children'),'Tag','Listbox1');
    set(listHandle,'Position', [0 rpos(4)/2-0.5 rpos(3) (rpos(4)/2-0.6)],'ColumnWidth',{width(3)-20});

  catch  %#ok<CTCH>
  %No error
  end
end

% Functions that define the tree layout
function cpHandle = createGUI

  %Gui layout
  panelColor=get(0,'DefaultUicontrolBackgroundColor');

  %Set Root Units to points
  set(0,'Units','points');

  %Set up the figure and defaults
  f=figure('Units','centimeters',...
      'Position',[5 5 25 20],...
      'Color',panelColor,...
      'Renderer','painters',...
      'HandleVisibility','callback',...
      'IntegerHandle','off',...
      'Toolbar','figure',...
      'NumberTitle','off',...
      'Name','HDS Toolbox Tree Visualization',...
      'MenuBar','none',...
      'Toolbar','none',...
      'ResizeFcn',@figResize);

  %Create the bottom uipanel
  botPanel = uipanel('BorderType','none',...
      'BackgroundColor','white',...
      'HighlightColor',[0.6 0.6 0.6],...
      'ShadowColor','black',...
      'Units','centimeters',...
      'Position',[1 1 11 2],...
      'Parent',f,...
      'Clipping','on',...
      'Tag','botP',...
      'ResizeFcn',@botPanelResize);

  %Create the right side panel
  rightPanel = uipanel('bordertype','none',...
      'BackgroundColor',panelColor,...
      'Units','centimeters',...
      'Position',[88 8 32 27],...
      'Parent',f,...
      'Tag','rigP',...
      'ResizeFcn',@rightPanelResize);

  %Create the center panel
  cpHandle = axes(...
      'Units','centimeters',...
      'Position', [1/20 8 88 27],...
      'Tag','cenP',...
      'ButtonDownFcn',{@bd,1},...
      'YLim',[-2 10],...
      'YTick',[],'XTick',[],...
      'XColor','white', 'YColor','white',...
      'Parent',f);

  uitable('Tag','Listbox1',...
      'Units','centimeters',...
      'Parent',rightPanel,...
      'FontSize',12,...
      'ColumnName',{'Properties'},...
      'RowName',[],...
      'Data',{});

  uitable('Tag','Listbox2',...
      'Units','centimeters',...
      'Parent',rightPanel,...
      'FontSize',12,...
      'ColumnName',{'Methods'},...
      'RowName',[],...
      'Data',{});

  t1 = uicontrol('Style','text','Tag','Textbox1',...
      'Units','centimeters',...
      'BackgroundColor','white',...
      'FontSize',12,...
      'HorizontalAlignment','left',...
      'Parent',botPanel,...
      'String',sprintf('Click on any of the classes to show the properties and methods available for that class.\n   Click and drag anywhere on the white space to navigate through larger trees.'),...
      'Position',[0 1.75 11 0.25]);


  t2 = uicontrol('Style','edit','Tag','Textbox2',...
      'Units','centimeters',...
      'BackgroundColor','white',...
      'FontSize',12,...
      'HorizontalAlignment','left',...
      'Parent',botPanel,...
      'Enable','inactive',...
      'Max',1,...
      'String', '',...
      'Position',[0 1.5 11 0.25]);


  t3 = uicontrol('Style','edit','Tag','Textbox3',...
      'Units','centimeters',...
      'BackgroundColor','white',...
      'FontSize',12,...
      'HorizontalAlignment','left',...
      'Parent',botPanel,...
      'Enable','inactive',...
      'Max',4,...
      'Position',[0 0 11 1.5]);


  uicontrol('Style', 'pushbutton', 'Units','centimeters', 'String', '@Global','Tag','button1',...
      'Position', [0.1 0.1 2.4 1], 'Callback',@switchGlobal, 'Parent', rightPanel,'userData',false);
  uicontrol('Style', 'pushbutton', 'Units','centimeters', 'String', 'Edit','Tag','button3',...
      'Position', [2.6 0.1 2.4 1], 'Callback',@enableEdit, 'Parent', rightPanel,'userData',false);
  uicontrol('Style', 'pushbutton', 'Units','centimeters', 'String', 'Show Links','Tag','button2',...
  'Position', [5.1 0.1 2.4 1], 'Callback',@switchLinks, 'Parent', rightPanel,'userData',false,'Visible','off');

  removeBorder(t1);
  removeBorder(t2);
  removeBorder(t3);

  guidata(f,struct('alwaysUpdate',false,'curSelected',[]));
end

function [arr, par] = findtree(arr, par, row, col, matrix)
  % FINDTREE is a recursive method to find the structure of the tree.

  if row == 0 
    % Find host class.
    hostClass = find(~sum(matrix,2));
    assert(~isempty(hostClass), 'Unable to find host class in FindTree');

    classID  =  hostClass;
    arr(1,1) =  hostClass;
    row = 1;
    if size(arr,1)==1
        return
    end
  else 
    classID=arr(row,col);
  end

  children = find(matrix(:, classID));

  if ~isempty(children)
    FAvIndex = max([1 find(arr(row + 1,:),1, 'last') + 1]);

    arr(row + 1, FAvIndex:(FAvIndex + length(children)-1)) = children;
    par(row + 1, FAvIndex:(FAvIndex + length(children)-1)) = classID;

    for i = 1:length(children)
        [arr, par] = findtree(arr, par, row+1, FAvIndex-1+i, matrix);
    end
  end

end

function spacing = findspacing(spacing, row, col, arr, par, buttonSize, minSpace)
  % Recursive method to define the horizontal spacing of the buttons.

  sameDist = 0.5;
  difDist = 1;

  if arr(row,col)
    if row < size(arr,1)

      % ChildIdx are indeces in next row with current class as parent
      childIdx = find(par(row+1,:) == arr(row,col));
      if ~isempty(childIdx)
        % Current class has children.
        childLoc = zeros(length(childIdx),1);
        for i = 1: length(childLoc)
          if col>1
            minSpace = spacing(row, col-1) + buttonSize(arr(row,col-1),3)/2 + buttonSize(arr(row,col),3)/2 + difDist;
          else
            minSpace = + buttonSize(arr(row,col),3)/2 + difDist;
          end
          spacing = findspacing(spacing, row+1, childIdx(i), arr, par, buttonSize, minSpace);
        end

        childCenters = spacing(row+1, childIdx);
        spacing(row,col) = mean(childCenters);
      else
        % no kids Find max one row lower with parent id to the left
        if col > 1
          leftParent = arr(row, col-1);
          leftChildIdx = find(par(row+1,:)==leftParent, 1,'last');
          if ~isempty(leftChildIdx)
            leftChildSpace = spacing(row+1, leftChildIdx) + buttonSize(arr(row + 1,leftChildIdx),3)./2;
            
            aux1 = leftChildSpace + sameDist + buttonSize(arr(row,col),3)/2;
            aux2 = spacing(row,col-1) + buttonSize(arr(row,col-1),3)./2 + sameDist + buttonSize(arr(row,col),3)/2;
            
            spacing(row,col) = max([aux1 aux2]);
            
          else
            spacing(row,col) = spacing(row,col-1) + buttonSize(arr(row,col-1),3)./2 + difDist + buttonSize(arr(row,col),3)/2;
          end   
        else
          % First column, no children.
          spacing(row,col) = 1;
        end
      end
    else
      % Last row
      if col > 1
        if par(row,col) == par(row,col-1)
          curS = spacing(row, col-1) + buttonSize(arr(row,col-1),3)/2 + buttonSize(arr(row,col),3)/2;
          spacing(row, col) = curS + sameDist ;
        else
          minS = minSpace;
          curS = spacing(row, col-1) + buttonSize(arr(row,col-1),3)/2 + buttonSize(arr(row,col),3)/2 + difDist;
          spacing(row, col) = max([minS curS]);
        end
      else
        minS = minSpace;
        curS = buttonSize(arr(row,col),3)/2;
        spacing(row,col) = max([minS curS]);
      end
    end
  end
end

function plotLines(row, col, spacing, arr, par, buttonSize, cpHandle)  
  if row < size(arr,1)
    childIdx = find(par(row+1,:) == arr(row,col));
    if ~isempty(childIdx)
      arrowStart = [spacing(row,col) 2*(size(arr,1)-row)];
      for i = 1: length(childIdx)
        arrowEnd = [(spacing(row+1, childIdx(i))) 2*(size(arr,1)-(row+1))];
        h = line([arrowStart(1) arrowEnd(1)],[arrowStart(2) arrowEnd(2)],'Parent', cpHandle,'color','k');
        uistack(h,'bottom');
        plotLines(row+1, childIdx(i), spacing, arr, par, buttonSize,cpHandle);
      end
    end
  end  
end

function defbuttons(cpHandle, tree)

    %create a function to create buttons and then send all back to the pclick    
    arr = zeros(length(tree.classes));
    [arr, par] = findtree(arr, arr, 0, 0, tree.links);
    if size(arr,1)>1
        arr = arr( 1:find(arr(:,1),1,'last'),:);
        arr = arr( :, 1:find(sum(arr,1),1,'last'));
        par = par( 1:find(par(:,1),1,'last'),:);
        par = par( :, 1:find(sum(par,1),1,'last'));
    end

    A = {tree.classes.name};
    
    [rows, cols] = size(arr);

    % Create the button objects but make not visible, extract size
    % information.
    buttonSize = zeros(length(tree.classes),4);
    ht = zeros(length(tree.classes),1);
    for i = 1:rows
        
        for j = 1:cols
            
            value = arr(i,j);
            
            if value >= 1 
                
                %Create button in center panel
                ht(value) = text(0, 2*(rows-i), A(value),...
                    'Units','data',...
                    'BackgroundColor',[.7 .9 .7],...
                    'LineStyle','-',...
                    'FontSize',14,...
                    'LineWidth',1,...
                    'EdgeColor',[0 0 0],...
                    'Margin',4,...
                    'Clipping','on',...
                    'ButtonDownFcn',{@ppClick, A{value}},...
                    'Visible','off',...
                    'HorizontalAlignment','center',...
                    'Parent', cpHandle);
                buttonSize(value,:) = get(ht(value), 'Extent');
            else
                % Stop looping over the columns and go directly to next row.
                break
            end
        end
    end
    drawnow;
    for i = 1:rows
        for j = 1:cols
            if arr(i,j) > 0
                value = arr(i,j);
                buttonSize(value,:) = get(ht(value), 'Extent');
            end
        end
    end
    
    % Find horizontal spacing of buttons.
    spacing = zeros(size(par));
    spacing = findspacing(spacing, 1,1, arr, par, buttonSize);
    
    % Plot Lines between the buttons
    plotLines(1, 1, spacing, arr, par, buttonSize,cpHandle)
    
    % Update button objects and make them visible.
    rows = size(arr,1);
    cols = size(arr,2);
    
    for i = 1:rows
        for j = 1:cols
            if arr(i,j) > 0
                pos = get(ht(arr(i,j)),'Position');
                set(ht(arr(i,j)),'Position', [spacing(i,j), pos(2)],'Visible','on');
            end
        end
    end
    
    % Set the axes-workspace origin
    aux = get(cpHandle,'YLim');
    dff = aux(2) - 2*(size(arr,1))+1;
    set(cpHandle,'YLim',[aux(1)-dff aux(2)-dff]);
    
    aux = get(cpHandle,'XLim');
    dff = (aux(2) - spacing(1,1) - buttonSize(1,3))/2;
    set(cpHandle,'XLim',[aux(1)-dff aux(2)-dff]);
    
end

function removeBorder(src)
  % from unDocumentedMatlab.
  pause(0.01) % Wait to make sure javaobj exists.
  jEdit = findjobj(src);
  lineColor = java.awt.Color(1,1,1);
  thickness = 1;
  roundedCorners = true;
  newBorder = javax.swing.border.LineBorder(lineColor,thickness,roundedCorners);
  jEdit.Border = newBorder;
  jEdit.repaint;
end

% Click methods
function ppClick(src, ~, classStr)
  % pClick method is called each time somebody clicks on any of the
  % buttons in the showtree user interface. It updates the information
  % for the class associated with the clicked button in the other panels.

  data = guidata(src);
  curSelected = data.curSelected;

  % Check for changes.
  fig = ancestor(src,'Figure');
  children = get(fig ,'Children');
  rightPanel = findobj(children,'Tag','rigP');
  EditButton = findobj(rightPanel,'Tag','button3');

  if get(EditButton,'userData')
      updateFileDescription(src);
  end

  % Get guidata again for updated AlwaysUpdate.
  data = guidata(src);

  if isempty(classStr)
    if ~isempty(curSelected)
      classStr = get(curSelected,'String');
      classStr = classStr{1};
      src = curSelected;
      curSelected = [];
    else
      return
    end

  else
    if ~isempty(curSelected)
      try set(curSelected,'LineWidth',1); catch; end %#ok<CTCH>
    end
  end

  fig = ancestor(src,'Figure');
  children = get(fig ,'Children');
  rightPanel = findobj(children,'Tag','rigP');
  propertyListbox = findobj(rightPanel,'Tag','Listbox1');
  propertyListbox2 = findobj(rightPanel,'Tag','Listbox2');

  botPanel = findobj(children,'Tag','botP');
  textBox1 = findobj(botPanel,'Tag','Textbox1');
  textBox2 = findobj(botPanel,'Tag','Textbox2');
  textBox3 = findobj(botPanel,'Tag','Textbox3');
  rightPanel = findobj(children,'Tag','rigP');


  showGlobal = get(findobj(rightPanel,'Tag','button1'),'userData');

  if src == curSelected
    set(propertyListbox, 'Data', []);
    set(propertyListbox2, 'Data', []);
    curSelected = [];
    setNoSelection(src,[]);
  else
    curSelected = src;
    set(src,'LineWidth',2);

    % Create temp object
    hdspreventreg(true);
    aux = eval(classStr);
    hdspreventreg(false);

    % Find the properties of the temporary object and place them in the 1st
    % listbox of the right panel. Set value of the listbox to one to make
    % the top property selected.
    if showGlobal
      props = properties(aux,'-all');
    else
      props = properties(aux);    
    end
    set(propertyListbox, 'Data', props);

    % Change the callback for the property list to include the class
    % string. The propClick method is defined further in this file.
    set(propertyListbox,'CellSelectionCallback',{@proppClick, classStr});

    % Find the methods of the temporary object and place them in the second
    % listbox of the right panel. Set value also to one:

    if showGlobal
      meth = methods(aux,'-all');
    else
      meth = methods(aux);
    end
    set(propertyListbox2, 'Data',meth)
    set(propertyListbox2,'CellSelectionCallback',{@methodClick, classStr});

    % Find the help description for the class and place this in a textbox
    % in the bottom Frame.

    if ~isempty(aux.metaProps)
      allMetaNamesTxt = sprintf('%s, ',aux.metaProps{:});
      allMetaNamesTxt = allMetaNamesTxt(1:end-2);
    else
      allMetaNamesTxt = '';
    end
    if ~isempty(aux.dataProps)
      allDataNamesTxt = sprintf('%s, ',aux.dataProps{:});
      allDataNamesTxt = allDataNamesTxt(1:end-2);
    else
      allDataNamesTxt = '';
    end

    [classHelp, firstLine] = gethelp(classStr);
    classText = sprintf('\n  Default property name  : %s\n  All Meta Properties        : %s\n  All Data Properties        : %s\n  -- -- -- --',aux.listAs,allMetaNamesTxt,allDataNamesTxt);

    helpText = sprintf('%s  %s',upper(classStr), firstLine);
    set(textBox1, 'String', classText);
    set(textBox2, 'String', helpText);
    set(textBox3, 'String', classHelp);

    set(textBox3, 'userData',struct('type','Class','class',classStr,'methods','','prop','','FirstLine',firstLine,'text', get(textBox3, 'String')));
  end
  data.curSelected = curSelected;
  guidata(src,data);
    
end

function proppClick(src, evt, classStr)
  % This function is called every time somebody clicks on one of the
  % properties in the right panel first listbox.

  if ~isempty(evt.Indices)

    % Check for changes.
    fig = ancestor(src,'Figure');
    children = get(fig ,'Children');
    rightPanel = findobj(children,'Tag','rigP');
    EditButton = findobj(rightPanel,'Tag','button3');

    if get(EditButton,'userData')
      updateFileDescription(src);
    end

    hdspreventreg(true);
    aux = eval(classStr);
    hdspreventreg(false);

    allStrings = get(src,'Data');
    selectedString = allStrings{evt.Indices(1)};

    pClass = propclass(aux, selectedString);

    hdsProps = {'parent' 'createDate' 'listAs' 'childClasses' 'parentClasses' 'dataProps' ...
      'metaProps' 'maskDisp' 'propsWithUnits' 'propUnits' 'propDims' 'strIndexProp'...
      'saveStatus' 'objVersion' 'classVersion' 'HDSClassVersion'  }; 
    hdsProps2 = {...
      'Returns the parent object.'...
      'Date of object initialization.' ...
      'String with default property name used to add objects of this class.' ...
      'StrCellarray indicating classes that can be used with ADDOBJ.'...
      'StrCellarray indicating classes that allow adding the current class with ADDOBJ.'...
      'StrCellarray indicating properties used for (non-meta) data .'...
      'StrCellarray indicating properties used for meta-data .'...
      'StrCellarray indicating properties that should not be evaluated during display'...
      'Cell array of strings with property names that contain values with units.'...
      'Cell array with strings indicating the units of the properties with units.'...
      'Cell array of cells with the names for the dimensions of the properties with units.'...
      'String indicating the property that is used for string-indexing'...
      'Indicates saving status (0:unchanged,1:obj changed,2:data changed, 3:obj updated).'...
      '[1x2] vector with the version of the current object.'...
      'Version number of the current class definition of the object.'...
      'Version number of the HDS Toolbox.'...
      };

    hdsPropIdx = find(strcmp(selectedString, hdsProps) , 1 );
    if ~isempty(hdsPropIdx)
      propertyHelp = hdsProps2{hdsPropIdx};
    else

      propertyHelp = strtrim(gethelp(classStr,'',selectedString));
      if ~isempty(propertyHelp)
        propertyHelp = regexp(propertyHelp,' - ','split');
        if length(propertyHelp)>1
          propertyHelp = propertyHelp{2};
        else
          propertyHelp = propertyHelp{1};
        end
      else
        propertyHelp = '';
      end


      while 1
        if ~isempty(propertyHelp) && length(propertyHelp)>1
          if strcmp(propertyHelp(end-1:end),'\n')
            propertyHelp = propertyHelp(1:end-2);
          else
            break;
          end
        else
          break;
        end
      end
    end

    helpText = sprintf('\n  Class:               %s\n  Property:          %s\n  Data class:       (%s)',upper(classStr),upper(selectedString),pClass);

    fig = ancestor(src,'Figure');
    children = get(fig ,'Children');
    botPanel = findobj(children,'Tag','botP');
    textBox1 = findobj(botPanel,'Tag','Textbox1');
    textBox2 = findobj(botPanel,'Tag','Textbox2');
    textBox3 = findobj(botPanel,'Tag','Textbox3');

    set(textBox2, 'String', sprintf('Description:    %s',  propertyHelp));
    set(textBox1, 'String', helpText);
    set(textBox3, 'String', '');
    set(textBox3, 'userData',struct('type','Prop','class',classStr,'method','','prop',selectedString,'FirstLine', propertyHelp, 'text', get(textBox3, 'String')));

  end
end

function methodClick(src, evt, classStr)
    % This function is called every time somebody clicks on one of the
    % properties in the right panel first listbox.

    if ~isempty(evt.Indices)

        % Check for changes.
        fig = ancestor(src,'Figure');
        children = get(fig ,'Children');
        rightPanel = findobj(children,'Tag','rigP');
        EditButton = findobj(rightPanel,'Tag','button3');
        
        if get(EditButton,'userData')
            updateFileDescription(src);
        end
        
        
        botPanel = findobj(children,'Tag','botP');
        textBox1 = findobj(botPanel, 'Tag', 'Textbox1');
        textBox2 = findobj(botPanel, 'Tag', 'Textbox2');
        textBox3 = findobj(botPanel, 'Tag', 'Textbox3');

        allStrings = get(src,'Data');
        selectedString = allStrings{evt.Indices(1)};
        
        [methodHelp, firstLine] = gethelp(classStr, selectedString);
        
        helpText = sprintf('\nClass:               %s\nMethod:            %s\n-- -- -- --',upper(classStr), upper(selectedString));
        
        set(textBox1, 'String', helpText);
        set(textBox2, 'String', sprintf('%s  %s',upper(selectedString),firstLine));
        set(textBox3, 'String', methodHelp);
        set(textBox3, 'userData',struct('type','Method','class',classStr,'method',selectedString,'prop','','FirstLine',firstLine,'text',get(textBox3, 'String')));
        
    end
    
    
    
end

% Update Methods
function updateFileDescription(src)

  data = guidata(src);

  fig = ancestor(src,'Figure');
  children = get(fig ,'Children');
  botPanel = findobj(children,'Tag','botP');
  textBox2 = findobj(botPanel, 'Tag', 'Textbox2');
  textBox3 = findobj(botPanel, 'Tag', 'Textbox3');
  % Check if texbox changed and ask if the user wants to update the
  % file.

  userData = get(textBox3,'userData');
  if ~isempty(userData)

    textBoxText2 = get(textBox2,'String');
    textBoxText3 = get(textBox3,'String');

    % Only check for changes after the CLASS/METHOD name, so trim firstLine.
    trimmedText2 = textBoxText2(regexp(textBoxText2,'(?<= )\S','once'):end);
    if isempty(trimmedText2);trimmedText2='';end;

    firtLineChanged = ~strcmp(trimmedText2, userData.FirstLine);
    textboxChanged  = ~strcmp(textBoxText3, userData.text);

    if (firtLineChanged || textboxChanged) 

      if ~data.alwaysUpdate
          button = questdlg('Do you want to update the description in the file?',...
              'Change to object description.','Yes','No','Always','No');
      else
          button = 'Always';
      end

      switch button
        case {'Yes' 'Always'}
          if strcmp(button,'Always')
              data.alwaysUpdate = true;
          end

            % try to get pointer to m-file
          switch userData.type
            case 'Class' 
              fileStr = [userData.class '.m'];
              if exist(fileStr,'file');
                  filePath = which(fileStr);
                  copyfile(filePath, [filePath(1:end-2) '.backup'],'f');

                  HDS.displaymessage('Updating description in file.',1,'','\n');

                  [classHelp, firstLineFile, commentTokens, ~, mFileText ] = gethelp(userData.class);

                  % Check if userData.txt == classHelp
                  nnn = '';
                  for i=1:size(userData.text,1);
                      nnn = sprintf('%s\n%s',nnn, strtrim(userData.text(i,:)));
                  end;
                  nnn = strtrim(nnn);

                  if ~strcmp(strtrim(classHelp), nnn) || ~strcmp(firstLineFile, userData.FirstLine)
                      msgbox('File changed outside of SHOWTREE; Unable to change M-file.','File Warning','warn');
                      return
                  end

                  nnn2 = '';
                  for i=1:size(textBoxText3,1)
                      nnn2 = sprintf('%s\n   %%   %s',nnn2, textBoxText3(i,:));
                  end;
                  nnn2 = sprintf('%s',nnn2(2:end));

                  firstLine = strtrim(get(textBox2,'String'));
                  firstLine = sprintf('\n   %%%s\n',firstLine);

                  newMFileText = sprintf('%s%s%s%s',mFileText(1: commentTokens(1)), firstLine, nnn2, mFileText(commentTokens(2):end));  

                  fid = fopen(filePath, 'w');
                  fwrite(fid, newMFileText, 'char');
                  fclose(fid);                                    

              else
                msgbox('Unable to change M-file.','File Warning','warn');
                return
              end
            case 'Method'

              [methodHelp, firstLineFile, commentTokens, ~, mFileText, filePath ] = gethelp(userData.class,userData.method);

              if isempty(filePath)
                  msgbox('Unable to change M-file.','File Warning','warn');
                  return
              end

              % Compare old values with text from file.
              nnn = '';
              for i=1:size(userData.text,1);
                  nnn = sprintf('%s\n%s',nnn, strtrim(userData.text(i,:)));
              end;
              nnn = strtrim(nnn);

              if ~strcmp(methodHelp, nnn) || ~strcmp(firstLineFile, userData.FirstLine)
                  msgbox('File changed outside of SHOWTREE; Unable to change M-file.','File Warning','warn');
                  return
              end

              nnn2 = '';
              space = ' ';
              methodTab = space(ones(commentTokens(3),1));
              for i=1:size(textBoxText3,1)
                  nnn2 = sprintf('%s\n%s%%   %s',nnn2, methodTab , strtrim(textBoxText3(i,:)));
              end;
              nnn2 = sprintf('%s',nnn2(2:end));

              firstLine = strtrim(get(textBox2,'String'));
              firstLine = sprintf('\n%s%%%s\n',methodTab, firstLine);

              newMFileText = sprintf('%s%s%s%s',mFileText(1:commentTokens(1)), firstLine, nnn2, mFileText(commentTokens(2):end));                                    
              fid = fopen(filePath, 'w');
              fwrite(fid, newMFileText, 'char');
              fclose(fid);  
            case 'Prop'
                [propHelp, ~, commentTokens, ~, mFileText,filePath ] = gethelp(userData.class,'',userData.prop);

                if ~strcmp(propHelp, userData.FirstLine)
                    msgbox('File changed outside of SHOWTREE; Unable to change M-file.','File Warning','warn');
                    return
                end

                aux     = get(textBox2,'String');
                boxSt   = regexp(aux,'(?<=Description:\s*)\w');
                boxtext = aux(boxSt:end);

                space = ' ';
                space = space(ones(commentTokens(3),1));

                newMFileText = sprintf('%s%s%% %s%s',mFileText(1:commentTokens(1)-1),space, boxtext ,mFileText(commentTokens(2):end));
                fid = fopen(filePath, 'w');
                fwrite(fid, newMFileText, 'char');
                fclose(fid);        
          end
        case 'No'
        case 'Cancel'
      end
    end
  end

  guidata(src, data);

end

% Button Methods
function switchGlobal(src, ~)

  fig = ancestor(src,'Figure');
  children = get(fig ,'Children');
  rightPanel = findobj(children,'Tag','rigP');
  editButton = findobj(rightPanel,'Tag','button3');

  if get(editButton,'userData')
      enableEdit(editButton);
  end

  curState = get(src,'userData');
  set(src,'userData',~curState,'ForegroundColor', [0 0.5*~curState 0]);
  ppClick(src,[],[]);
end

function switchLinks(~, ~)
    display('Show Links is currently not supported.');
%     curState = get(src,'userData');
%     set(src,'userData',~curState,'ForegroundColor', [0 0.5*~curState 0]);
end

function enableEdit(src,~)
    
  data = guidata(ancestor(src,'Figure'));
  curString = get(data.curSelected,'String');

  curState = get(src,'userData');

  fig = ancestor(src,'Figure');
  children = get(fig ,'Children');
  botPanel = findobj(children,'Tag','botP');
  textBox2 = findobj(botPanel,'Tag','Textbox2');
  textBox3 = findobj(botPanel,'Tag','Textbox3');

  rightPanel = findobj(children,'Tag','rigP');
  GlobalButton = findobj(rightPanel,'Tag','button1');

  if ~curState
    set(textBox2,'Enable','on');
    set(textBox3,'Enable','on');
    if get(GlobalButton,'userData');
        switchGlobal(GlobalButton, [])
    end
  else
    set(textBox2,'Enable','inactive');
    set(textBox3,'Enable','inactive');
    aux = get(textBox3,'userData');
    set(textBox3,'String',aux.text);
    if ~isempty(curString)
        set(textBox2,'String',[upper(curString{1}) '  ' aux.FirstLine]);
    end
  end

  set(src,'userData',~curState,'ForegroundColor', [0 0.5*~curState 0]);  
end

%Random extras
function setNoSelection(src,~)

  HDSMethods    = {'showtree' 'hdsload' 'hdscast' 'hdsmonitor' 'hdsrebuild' 'hdsinfo' 'hdscleanup'};

  fig = ancestor(src,'Figure');
  children = get(fig ,'Children');
  botPanel = findobj(children,'Tag','botP');
  textBox = findobj(botPanel,'Tag','Textbox1');
  textBox2 = findobj(botPanel,'Tag','Textbox2');
  textBox3 = findobj(botPanel,'Tag','Textbox3');

  boxText = sprintf(['- Click on any of the classes to show the properties and methods available for that class.\n' ...
      '- Click and drag anywhere on the white space to navigate through large tree structures.\n'...
      '- When no class is selected, general methods associated with the HDS Toolbox are shown in the Methods list.\n'...
      '- The ''@Global'' and ''Show Links'' buttons add additional information in the user interface.']);

  set(textBox, 'String', boxText);

  rightPanel = findobj(children,'Tag','rigP');
  methodsList = findobj(rightPanel,'Tag','Listbox2');

  set(methodsList, 'Data', HDSMethods')
  set(methodsList, 'CellSelectionCallback',{@methodClick, ''});
  set(textBox2, 'String','');
  set(textBox3, 'String','','userData',struct('type','class','class','','method','','FirstLine','','text',''));

end