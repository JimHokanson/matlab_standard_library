function profile_history(profData, varargin)
% profile_history - display profiling data as a timeline history
%
%   sl.code_analysis.profile_history
%   
%   Calling this function MUST BE PROCEEDED BY:
%
%   e.g. profile on -timestamp
%
%
% profile_history analyzes the latest profiling session and displays the
% function-call timings and durations in a graphical timeline. The function
% labels and timeline bars are clickable, linking to their respective
% detailed profiling report (of the builtin Matlab profiler).
%
% profile_history(profData) displays the timeline of a specific profiling
% session, that was previously stored via a profData=profile('info') command.
%
% Technical description:
%    http://UndocumentedMatlab.com/blog/function-call-timeline-profiling
%
% Note: 
%    profile_history uses a wrapper function for the built-in profile.m
%    that is located in the @char subfolder. If for some reason you see
%    problems when running the profiler, simply delete the @char folder.
%    In order to be able to use profile_history after you delete the @char
%    folder, add the -timestamp parameter whenever you profile: 
%           profile on -timestamp;  myProgram();  profile_history
%    (adding the -timestamp parameter is not needed when the @char exists)
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% See also:
%    profile, profview
%
% Release history:
%    1.0 2014-06-16: First version posted on <a href="http://www.mathworks.com/matlabcentral/fileexchange/authors/27420">MathWorks File Exchange</a>
%    1.1 2014-06-17: Fixes for HG2 (R2014b), fix info-box alignment near figure's right edge
%    1.2 2014-06-17: Fix the previous update...
%    1.3 2014-06-18: External tick marks; fixed wrapper function eddge-case as per user feedback

% License to use and modify this code is granted freely to all interested,
% as long as the original author is referenced and attributed as such. The
% original author maintains the right to be solely associated with this
% work.

% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.2 $  $Date: 2014/06/18 23:53:17 $

    % Check inputs
    if nargin<1 || isempty(profData)
        profData = profile('info');
    end

    % Ensure that there is valid history data to process
    if isempty(profData) || ~isstruct(profData) || ~isfield(profData,'FunctionHistory')
        error('YMA:profile_history:noStruct','Invalid profiling data: call %s following profile. For example:\n   profile on -timestamp; surf(peaks); %s', mfilename, mfilename);
    elseif isempty(profData.FunctionHistory)
        error('YMA:profile_history:noData','No profiling data: call %s following profile. For example:\n   profile on -timestamp; surf(peaks); %s', mfilename, mfilename);
    elseif size(profData.FunctionHistory,1) < 4
        error('YMA:profile_history:noTiming','No timing data: call profile with the -timing parameter. For example:\n   profile on -timestamp; surf(peaks); %s', mfilename);
    end

    % Parse the profile history data table
    histData = profData.FunctionHistory;
    startTime     = histData(3,1) + histData(4,1)/1e6;
    relativeTimes = histData(3,:) + histData(4,:)/1e6 - startTime;

    % Differentiate between close calls
    N = numel(relativeTimes);
    for idx = 2 : N  % TODO - vectorize this loop
        if relativeTimes(idx) <= relativeTimes(idx-1)
            relativeTimes(idx) = relativeTimes(idx-1) + 0.05*profData.ClockPrecision;
        end
    end
    %plot(relativeTimes);

    % Start the report figure in invisible mode (for improved performance)
    hFig = figure('NumberTitle','off', 'Name','Profiling history', 'Visible','off', 'Color','w', 'Toolbar','figure');
    funcNames = getFunctionNames(profData);
    numFuncs = numel(funcNames);
    hAxes = axes('YDir','reverse', 'OuterPosition',[0,0,1,1], 'LooseInset',[0.05,0.10,0.02,0.01], 'FontSize',8, ...
                 'NextPlot','add', 'YTick',1:numFuncs, 'TickDir','out', 'YTickLabel',funcNames, 'YLim',[1,numFuncs+0.2], ...
                 'ButtonDownFcn',{@mouseClickedCallbackFcn,hFig});
    try
        % HG2
        set(hAxes,'TickLabelInterpreter','none');
    catch
        % HG1
    end
    setappdata(hFig,'hAxes',hAxes);
    setappdata(hFig,'numFuncs',numFuncs);
    xlabel(hAxes, 'Secs from start');

    for funcIdx = 1 : numFuncs  % TODO - vectorize this loop
        % Get this function's entry and exit times
        entryIdx = (histData(2,:)==funcIdx) & (histData(1,:)==0);
        exitIdx  = (histData(2,:)==funcIdx) & (histData(1,:)==1);
        profData.FunctionTable(funcIdx).EntryTimes = relativeTimes(entryIdx);
        profData.FunctionTable(funcIdx).ExitTimes  = relativeTimes(exitIdx);
        if sum(entryIdx) > sum(exitIdx)
            % Function entry was provided without a corresponding function exit
            try
                sumDurations = sum(profData.FunctionTable(funcIdx).ExitTimes - profData.FunctionTable(funcIdx).EntryTimes(1:end-1));
                lastDuration = profData.FunctionTable(funcIdx).TotalTime - sumDurations;
                profData.FunctionTable(funcIdx).ExitTimes(end+1) = profData.FunctionTable(funcIdx).EntryTimes(end) + lastDuration;
            catch
                % something is seriously fishy - bail out...
            end
        end
        profData.FunctionTable(funcIdx).SelfTime = zeros(1,sum(entryIdx));  % will be updated below

        % Plot the function's execution durations
        xData = [profData.FunctionTable(funcIdx).EntryTimes; ...
                 profData.FunctionTable(funcIdx).ExitTimes];
        plot(xData, funcIdx(ones(size(xData))), '.-b', 'HitTest','off');
    end

    % Display the execution paths
    execPathX = reshape(relativeTimes(sort([1:N,2:N-1])),2,[]);
    execPathY = [];
    ancestors = [];
    cp = profData.ClockPrecision;
    for execIdx = 1 : N  % TODO - vectorize this loop
        % Update the self-time for the function that just switched
        funcIdx = histData(2,execIdx);
        if execIdx > 1
            duration = relativeTimes(execIdx) - relativeTimes(execIdx-1);
            duration = cp * round(duration/cp);
            if histData(1,execIdx) == 0
                if ~isempty(ancestors)
                    prevFuncIdx = ancestors(end);
                else
                    prevFuncIdx = [];
                end
            else
                %prevFuncIdx = histData(2,execIdx-1);
                prevFuncIdx = funcIdx;
            end
            try
                funcData = profData.FunctionTable(prevFuncIdx);
                entryIdx = max(find(funcData.EntryTimes <= relativeTimes(execIdx)));  %#ok<MXFND> % I think ,1,'last') is not available in old ML releases, so use max()
                if isempty(entryIdx),  entryIdx = 1;  end
                profData.FunctionTable(prevFuncIdx).SelfTime(entryIdx) = funcData.SelfTime(entryIdx) + duration;
            catch
                % ignore - probably prevFuncIdx==[]
            end
        end

        % Update the execPathY values and ancestors
        if histData(1,execIdx) == 0
            % Push the function-call stack downwards
            execPathY(end+1) = funcIdx; %#ok<*AGROW>
            ancestors(end+1) = funcIdx;
        else % histData(1,execIdx) == 1
            try
                % Pop the function-call stack upwards
                execPathY(end+1) = ancestors(end-1);
                ancestors(end) = [];
            catch
                % no parent function, so hide the exec path here
                execPathY(end+1) = NaN;
                ancestors = [];
            end
        end
    end
    execPathY = reshape(execPathY(sort([1:N-1,1:N-1])),2,[]);
    hExecPaths = plot(execPathX, execPathY, '-r', 'LineWidth',2, 'HitTest','off');

    % Display waterfalls
    waterfallX = reshape(execPathX(2:end-1),2,[]);
    waterfallY = reshape(execPathY(2:end-1),2,[]);
    hWaterfalls = plot(waterfallX, waterfallY, ':r', 'HitTest','off');
    direction = sign(diff(waterfallY));
    hUpMarks   = text(waterfallX(1,direction<0), mean(waterfallY(:,direction<0)), '\^', 'Color','r', 'HitTest','off', 'FontSize',10, 'HorizontalAlignment','center', 'VerticalAlignment','middle');
    hDownMarks = text(waterfallX(1,direction>0), mean(waterfallY(:,direction>0)), 'v',  'Color','r', 'HitTest','off', 'FontSize',8,  'HorizontalAlignment','center', 'VerticalAlignment','cap');

    % Add functionality checkboxes
    uicontrol('Style','checkbox', 'String','execution paths', 'value',1, 'Background','w', 'Units','Pixels', 'Position',[ 10,5,100,20], 'Callback',{@execPathCallbackFcn,hExecPaths});
    uicontrol('Style','checkbox', 'String','waterfall lines', 'value',1, 'Background','w', 'Units','Pixels', 'Position',[110,5,100,20], 'Callback',{@waterfallCallbackFcn,[hWaterfalls;hUpMarks;hDownMarks]});
    uicontrol('Style','checkbox', 'String','hover info-box',  'value',1, 'Background','w', 'Units','Pixels', 'Position',[200,5,100,20], 'Callback',{@infoBoxCallbackFcn,hFig,profData});

    % Set the info-box hover callback
    set(hFig, 'WindowButtonMotionFcn',{@mouseMovedCallbackFcn,profData});

    % Display the figure
    set(hFig, 'Visible','on');
end

% Get valid function names
function funcNames = getFunctionNames(profData)
    % First get all profiled function names
    funcNames = {profData.FunctionTable.FunctionName};

    % Strip away profiling artifacts
    while ~isempty(strfind(funcNames{end},'profile'))
        funcNames(end) = [];
    end
    if strcmpi(funcNames{end},'ispc'),       funcNames(end) = [];  end
    if strcmpi(funcNames{end},'fileparts'),  funcNames(end) = [];  end
end

% Execution path checkbox callback
function execPathCallbackFcn(cbExecPath, eventData, handles) %#ok<INUSL>
    if get(cbExecPath,'Value')
        set(handles,'visible','on');
    else
        set(handles,'visible','off');
    end
end

% Waterfall lines checkbox callback
function waterfallCallbackFcn(cbWaterfall, eventData, handles) %#ok<INUSL>
    if get(cbWaterfall,'Value')
        set(handles,'visible','on');
    else
        set(handles,'visible','off');
    end
end

% Hover info-box checkbox callback
function infoBoxCallbackFcn(cbInfoBox, eventData, hFig, profData) %#ok<INUSL>
    if get(cbInfoBox,'Value')
        set(hFig, 'WindowButtonMotionFcn',{@mouseMovedCallbackFcn,profData});
    else
        set(hFig, 'WindowButtonMotionFcn',[]);
    end
end

% Convert clicked position into a function index
function [funcIdx,currentPoint,axesPos,yLim] = getFuncIdx(hFig, hAxes)
    % Get the clicked position
    currentPoint = get(hFig,'CurrentPoint');
    x = currentPoint(1);
    y = currentPoint(2);

    % Convert clicked position into a function index
    if nargin<2,  hAxes = getappdata(hFig,'hAxes');  end
    axesPos = getpixelposition(hAxes);
    axesHeight = axesPos(4);
    deltaYFromBottom = y - axesPos(2);
    deltaYFromTop = axesHeight - deltaYFromBottom;
    relYFromTop = min(max(deltaYFromTop/axesHeight,0),1);
    yLim = get(hAxes,'YLim');
    numFuncs = getappdata(hFig,'numFuncs');
    funcIdx = min(max(round(yLim(1) + relYFromTop*diff(yLim)), 1), numFuncs);

    % The following is currently unused:
    if x < axesPos(1)
        % Clicked outside the axes (on a function label)
    else
        % Clicked within the axes
    end
end

% Axes mouse-click callback
function mouseClickedCallbackFcn(hAxes, eventData, hFig) %#ok<INUSL>
    % First get the clicked function index in the profiling table
    funcIdx = getFuncIdx(hFig, hAxes);

    % Open the detailed profiling report for the clicked function
    profview(funcIdx);
end

% Figure mouse-click callback
function mouseMovedCallbackFcn(hFig, eventData, profData) %#ok<INUSL>
    % First get the hovered function index in the profiling table
    [funcIdx,currentPoint,axesPos,yLim] = getFuncIdx(hFig);

    % Get the info text-box handle
    hInfoBox = getappdata(hFig,'hInfoBox');
    if isempty(hInfoBox)
        % Prepare the info-box
        hInfoBox = text(0,0,'', 'EdgeColor',.8*[1,1,1], 'FontSize',7, 'Tag','hInfoBox', 'VerticalAlignment','bottom', 'interpreter','none', 'HitTest','off');
        setappdata(hFig,'hInfoBox',hInfoBox);
    end
    if currentPoint(2)<axesPos(2) || currentPoint(2)>axesPos(2)+axesPos(4) || currentPoint(1)>axesPos(1)+axesPos(3)
        % Mouse pointer is outside the axes boundaries - hide the info box
        set(hInfoBox, 'Visible','off');
    else
        % Get the hovered position in data units
        % Note: we could also use the builtin hgconvertunits function
        axesWidth = axesPos(3);
        deltaXFromLeft = currentPoint(1) - axesPos(1);
        relXFromLeft = min(max(deltaXFromLeft/axesWidth,0),1);
        hAxes = getappdata(hFig,'hAxes');
        xLim = get(hAxes,'XLim');
        dataX = xLim(1) + relXFromLeft*diff(xLim);
        %disp([x axesWidth deltaXFromLeft relXFromLeft xLim dataX])

        % Get the function's timing data
        functionData = profData.FunctionTable(funcIdx);

        % Find the nearest function entry point
        entryIdx = max(find(functionData.EntryTimes <= dataX));  %#ok<MXFND> % I think ,1,'last') is not available in old ML releases, so use max()
        if isempty(entryIdx),  entryIdx = 1;  end
        entryTime = functionData.EntryTimes(entryIdx);
        exitTime  = functionData.ExitTimes(entryIdx);
        totalTime = exitTime - entryTime;
        selfTime = functionData.SelfTime(entryIdx);
        childTime = totalTime - selfTime;
        selfTotalTime  = sum(functionData.SelfTime);
        totalTotalTime = sum(functionData.TotalTime);
        childTotalTime = totalTotalTime - selfTotalTime;

        % Assemble all the info into the info-box string
        %cp = profData.ClockPrecision;
        str = functionData.FunctionName;
        numEntries = numel(functionData.EntryTimes);
        if numEntries > 1
            str = sprintf('%s\n  => call #%d of %d', str, entryIdx, numEntries);
        end
        %str = sprintf('%s\n  Start: %+.3f\n  Self:  %+.3f\n  Child: %+.3f\n  Total: %+.3f\n  End:  %+.3f', ...
        %              str, entryTime, selfTime, childTime, totalTime, exitTime);
        str = sprintf('%s\n  Start: %+.3f\n  Self:  %+.3f', str, entryTime, selfTime);
        if numEntries > 1, str = sprintf('%s (of %.3f)', str, selfTotalTime); end
        str = sprintf('%s\n  Child: %+.3f', str, childTime);
        if numEntries > 1, str = sprintf('%s (of %.3f)', str, childTotalTime); end
        str = sprintf('%s\n  Total: %+.3f', str, totalTime);
        if numEntries > 1, str = sprintf('%s (of %.3f)', str, totalTotalTime); end
        str = sprintf('%s\n  End:  %+.3f', str, exitTime);
        set(hInfoBox, 'Visible','on', 'Position',[dataX,funcIdx], 'String',str, ...
            'VerticalAlignment','top', 'HorizontalAlignment','left');

        % Update the info-box location based on cursor position
        extent = get(hInfoBox,'Extent');
        %disp(num2str([extent,yLim,xLim],'%.2f '))
        if extent(2) - 2*extent(4) < yLim(1)
            set(hInfoBox, 'VerticalAlignment','top');
        else
            set(hInfoBox, 'VerticalAlignment','bottom');
        end
        if extent(1) + extent(3) > xLim(2)
            %set(hInfoBox, 'HorizontalAlignment','right');
            set(hInfoBox, 'Position',[dataX-extent(3),funcIdx]);
        else
            %set(hInfoBox, 'HorizontalAlignment','left');
        end
    end
end
