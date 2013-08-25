function hdsstopmonitor(obj, ~)
    %HDSSTOPMONITOR  Stops the HDSMonitor
    %
    % This is the callback function for either:
    % 1) deleting the timer object
    % 2) closing the monitor window
    %
    % The userdata of each object contains the pointer to the other object.
    % This method will close the other object to make sure that at no point
    % the timer object exists without a window or the window exists without
    % the timer.
    
    % Copyright (c) 2012, J.B.Wagenaar
    % This source file is subject to version 3 of the GPL license, 
    % that is bundled with this package in the file LICENSE, and is 
    % available online at http://www.gnu.org/licenses/gpl.txt
    %
    % This source file can be linked to GPL-incompatible facilities, 
    % produced or made available by MathWorks, Inc.
    
    persistent p q
    
    if isempty(p)
        p = false;
        q = false;
    end

    if ishandle(obj)
        if ~q
            % Function caller by Figure
            handle = get(obj, 'UserData');
            p = 1;
            stop(handle);
            delete(handle);
        else
            q = false;
        end
    else
        if ~p 
            % Function called by Timer
            handle = get(obj, 'UserData');
            q = true;
            if ishandle(handle)
                close(handle);
            end
        else
            p = false;
        end
    end
    
end