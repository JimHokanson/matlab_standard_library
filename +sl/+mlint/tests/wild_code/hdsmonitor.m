function hdsmonitor(varargin)
    %HDSMONITOR  Displays memory information for the HDS Toolbox.
    %   HDSMONITOR Starts the monitor with the default update rate of 2
    %   seconds. The monitor will be stopped by closing the monitor's window.
    %
    %   HDSMONITOR(PERIOD) starts the monitor with a user specified update
    %   rate of PERIOD seconds.
    %
    %   The monitor has two graphs indicating: 1) The number of objects
    %   registered with the HDS Toolbox over time and 2) The total amount
    %   of allocated memory for the HDS Toolbox over time.
    %
    %   The monitor also shows numeric values for: 1) The total amount of
    %   allocated memory for the HDS Toolbox. 2) The total number of
    %   objects that are registered witht the HDS Toolbox. 3) The number of
    %   unsaved objects that are registered with the HDS Toolbox and 4) The
    %   number of independent data trees that are registered with the HDS
    %   Toolbox. 
    %
    %   The two buttons in the monitor can be used to: 1) Invoke the
    %   HDScleanup method and 2) invoke the HDSinfo('all') method.
    %
    %   Note:
    %   There can be a slight difference in the number of objects that are
    %   created and that are displayed. This results from the fact that the
    %   HDS Toolbox only counts objects once they are linked to another
    %   object in memory or on disk. Therefore, a newly generated object is
    %   not included but will be included once it is linked to another
    %   object or saved.
    %
    %   Furthermore, the allocated memory is an estimate of memory
    %   allocation as the method for determining the size is an approximate
    %   and there are certain overheads that are not included in the
    %   measure. Also, the memory allocated for an object is only updated
    %   when one of the 'data-properties' is changed (for speed). Changes
    %   to any other property will not be reflected in the statistic.
    
    % Copyright (c) 2012, J.B.Wagenaar
    % This source file is subject to version 3 of the GPL license, 
    % that is bundled with this package in the file LICENSE, and is 
    % available online at http://www.gnu.org/licenses/gpl.txt
    %
    % This source file can be linked to GPL-incompatible facilities, 
    % produced or made available by MathWorks, Inc.
    
    %   Technical specs:
    %   The HDSmonitor is locked using MLOCK during the init case. This is
    %   necessary to keep the persistent variables when the user calls
    %   CLEAR ALL. To unlock, use: MUNLOCK('HDSmonitor').
    
    persistent uihandle index v1 v2 hmem a1 a2 hobjs huobjs hstructs b1 b2 ht1 ht2 t1 t2
    global HDSManagedData
    
    % If uihandle is 
    if isempty(uihandle) || ~ishandle(uihandle)
        mlock();
        
        if nargin
            period = varargin{1};
            if ~isnumeric(period) || length(period)>1 || period<=0
                throwAsCaller(MException('hdsmonitor:input','''Timeout'' parameter has to be a scalar numeric larger than 0.'));
            end
        else
            period = 2;
        end        
        
        % Init figure
        scrSize = get(0,'ScreenSize');
        uihandle = figure('Resize','off','position',[scrSize(3)/1.25 scrSize(4)/4 200 360],'MenuBar',...
            'none','Name','HDS Monitor','NumberTitle','off');
        set(uihandle,'deleteFcn',@hdsstopmonitor)
        a1 = axes('Units','pixels','Position',[10 245 180 90],'Box','on','YTick',[],...
            'Xtick',[],'YLim', [0 100],'Tag','a1','DrawMode','fast','Layer','top',...
            'YTick',0:10:1000,'YTickLabel',{});
        
        t1 = 10;
        
        ht1 = text(2,0,'|| 10 objs','FontSize',8,'HorizontalAlignment','left','VerticalAlignment','bottom');
        
        uicontrol(uihandle,'Style', 'text', 'String', 'Number of objects',...
                 'Position', [5 335 190 20],'BackgroundColor',get(uihandle,'Color'));          
        
             hold on
        a2 = axes('Units','pixels','Position',[10 125 180 90],'Box','on','YTickMode','manual','YTick',[], ...
            'Xtick',[],'YLim', [0 1],'Tag','a2','DrawMode','fast','Layer','top',...
            'YTick',0:0.1:10,'YTickLabel',{});
        
        t2 = 0.1;
        
        
        uicontrol(uihandle,'Style', 'text', 'String', 'Allocated memory',...
         'Position', [5 215 190 20],'BackgroundColor',get(uihandle,'Color')); 
        
        hold on

        v1 = zeros(100,1);
        v2 = zeros(100,1);
        index = 1;
        
        stairs(a1, v1,'Color','green','LineWidth',2,'Tag','b1');
        stairs(a2, v2,'Color','green','LineWidth',2,'Tag','b2');
        
        
        ht2 = text(2,0,'|| 0.1 kB','FontSize',8,'HorizontalAlignment','left','VerticalAlignment','bottom');
        
        uicontrol(uihandle,'Style', 'pushbutton', 'String', 'Cleanup',...
                 'Position', [5 5 90 30], 'Callback','hdscleanup');
        uicontrol(uihandle,'Style', 'pushbutton', 'String', 'More Info',...
                 'Position', [105 5 90 30], 'Callback','hdsinfo'); 
        uicontrol(uihandle,'Style', 'text', 'String', 'Memory :',...
                 'Position', [5 95 105 20] ,'BackgroundColor',get(uihandle,'Color'));         
        uicontrol(uihandle,'Style', 'text', 'String', 'Objects :',...
                 'Position', [5 75 105 20],'BackgroundColor',get(uihandle,'Color'));     
        uicontrol(uihandle,'Style', 'text', 'String', 'Unsaved :',...
                 'Position', [5 55 105 20],'BackgroundColor',get(uihandle,'Color'));         
        uicontrol(uihandle,'Style', 'text', 'String', 'Data trees :',...
                 'Position', [5 35 105 20],'BackgroundColor',get(uihandle,'Color'));         
             
        uicontrol(uihandle,'Style', 'text', 'String', '','Tag','mem',...
                 'Position', [100 95 65 20],'BackgroundColor',get(uihandle,'Color'));     
        uicontrol(uihandle,'Style', 'text', 'String', '','Tag','objs',...
                 'Position', [100 75 65 20],'BackgroundColor',get(uihandle,'Color'));     
        uicontrol(uihandle,'Style', 'text', 'String', '','Tag','uobjs',...
                 'Position', [100 55 65 20],'BackgroundColor',get(uihandle,'Color'));     
        uicontrol(uihandle,'Style', 'text', 'String', '','Tag','structs',...
                 'Position', [100 35 65 20],'BackgroundColor',get(uihandle,'Color')); 
             
        uicontrol(uihandle,'Style', 'text', 'String', 'kB',...
            'Position', [160 95 20 20],'BackgroundColor',get(uihandle,'Color'));     
        
        myhandles = guihandles(uihandle);
        hmem = myhandles.mem;
        hobjs = myhandles.objs;
        huobjs = myhandles.uobjs;
        hstructs = myhandles.structs;
        b1 = myhandles.b1;
        b2 = myhandles.b2;
        a1 = myhandles.a1;
        a2 = myhandles.a2;
        
        %guidata(uihandle, myhandles);
        
        % Init Timer
        ui_timer = timer;
        set(ui_timer, 'ExecutionMode', 'FixedRate');
        set(ui_timer, 'BusyMode','queue');
        set(ui_timer, 'Period', period);
        set(ui_timer, 'StartDelay',1);
        set(ui_timer, 'TimerFcn', 'hdsmonitor()');
        set(ui_timer, 'stopFcn', @hdsstopmonitor);
        set(ui_timer, 'UserData', uihandle);
        start(ui_timer);
        
        set(uihandle,'UserData', ui_timer); 

        set(uihandle,'HandleVisibility','callback');
        set(a1,'HandleVisibility','callback');
        set(a2,'HandleVisibility','callback');
        
    elseif nargin > 0
        
        timerHandle = get(uihandle,'UserData');
        set(timerHandle,'stopFcn',[]);
        stop(timerHandle);
        set(timerHandle,'Period',varargin{1});
        set(timerHandle, 'stopFcn', @hdsstopmonitor);
        start(timerHandle);
        
    end
    
    % Update figure
    ll      = length(HDSManagedData);
    mem     = zeros(ll,1);
    nobj    = zeros(ll,1);
    nuobj   = zeros(ll,1);
    
    for i = 1: length(HDSManagedData)
        activeIds   = HDSManagedData(i).objIds(1,:) > 0;
        mem(i)      = sum(HDSManagedData(i).objIds(6,activeIds))/1000;
        nobj(i)     = sum(activeIds);
        nuobj(i)    = sum(HDSManagedData(i).objBools(1,activeIds) | HDSManagedData(i).objBools(2,activeIds));
    end
    
    time        = [(index + 1) : 100 1:index ];
    
    % -- -- 
    v1(index)   = sum(nobj);
    set(b1,'YData',v1(time));     
    max1 = max(v1);        
    YLim = get(a1,'YLim');
    lim  = ceil(YLim(2)/10);

    if max1 > (YLim(2) - lim)
        newYLim = [0 (YLim(2) + (max1 - YLim(2) + 2*lim))];
        set(a1,'YLim', newYLim);
        while 1
            if (newYLim(2)/t1) > 20
                % Update ticks
                t1 = t1*10;
                set(a1,'YTick',0:t1:t1*100);
                set(ht1,'String',sprintf('|| %d objs',t1));
            else
                break
            end
        end

    elseif max([max1 100]) < (YLim(2) - 6*lim)
        newYLim = [0 max([(YLim(2) - 5*lim) 100])];
        set(a1,'YLim', newYLim);
        while 1
            if (newYLim(2)/t1) < 3
                % Update ticks
                t1 = t1/10;
                set(a1,'YTick',0:t1:t1*100);
                set(ht1,'String',sprintf('|| %d objs',t1));
            else
                break
            end
        end
    end  

    % -- --
    v2(index) = sum(mem);
    set(b2, 'YData', v2(time));
    max2 = max(v2);
    YLim = get(a2,'YLim');
    lim  = ceil(YLim(2)/10);

    if max2 > (YLim(2) - lim)
        newYLim = [0 (YLim(2) + (max2-YLim(2) + 2*lim))];
        set(a2,'YLim', newYLim);
        while 1
            if (newYLim(2)/t2) > 20
                % Update ticks
                t2 = t2*10;
                set(a2,'YTick',0:t2:t2*100);
                if t2 >= 1000
                    tt2 = t2/1000;
                    s = 'MB';
                else
                    tt2 = t2;
                    s = 'kB';
                end
                set(ht2,'String',sprintf('|| %d %s',tt2,s)); 
            else
                break
            end
        end

    elseif max([max2 1]) < (YLim(2) - 6*lim)
        newYLim = [0 max([(YLim(2) - 5*lim) 1])];
        set(a2,'YLim', newYLim);
        while 1
            if (newYLim(2)/t2) < 3
                % Update ticks
                t2 = t2/10;
                set(a2,'YTick',0:t2:t2*100);
                if t2 >= 1000
                    tt2 = t2/1000;
                    s = 'MB';
                else
                    tt2 = t2;
                    s = 'kB';
                end
                set(ht2,'String',sprintf('|| %1.0d %s',tt2,s));
            else
                break
            end
        end
    end
        
    % -- --
    index = index+1;
    if index > 100
        index = 1;
    end
    
    % -- --
    set(hmem    , 'String', num2str(sum(mem),'%7.1f'));
    set(hstructs, 'String', num2str(ll));
    set(hobjs   , 'String', num2str(sum(nobj)));
    set(huobjs  , 'String', num2str(sum(nuobj)));
    
    drawnow expose
    
end

