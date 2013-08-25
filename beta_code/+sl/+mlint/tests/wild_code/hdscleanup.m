function varargout = hdscleanup(varargin)
  % HDSCLEANUP  Frees memory occupied by HDS ojects and data.
  %   HDSCLEANUP closes objects that have not been used for longer than
  %   10 minutes with the exception of the 200 objects that have most
  %   recently been used. Objects that fall in the latter category and
  %   have not been used for more than 10 minutes, will only have the
  %   data properties removed from memory. 
  %
  %   HDSCLEANUP(TIME) closes objects that have been unused for TIME
  %   minutes.
  %
  %   HDSCLEANUP(TIME, NOBJS) closes object that have been unused for
  %   TIME minutes and retains a minimum of NOBJS objects in memory.  
  %
  %   HDSCLEANUP(TIME, NOBJS, SKIPOBJ1, SKIPOBJ2, ...) SKIPOBJects can be
  %   added to the end of the method call to excempt these objects from
  %   being closed. As the method cannot poll any of the variables in the
  %   caller function, it is possible that pointers to objects will be
  %   deleted if the objects are not included as SKIPOBJs. Variables in
  %   the 'base'- workspace are checked for pointers to objects (see
  %   below).
  %
  %   OUT = HDSCLEANUP(...) returns a numeric value indicating an
  %   estimate of the memory that has been cleaned in kB. 
  %
  %   There are two scenarios in which an object will not be closed even
  %   though it matches the requirements:
  %
  %   1) Objects that have changed from the version on the disk will not
  %   be closed. 
  %   
  %   2) Objects that are assigned in the 'base'- workspace will not be
  %   closed as this would result in invalid pointers in the 'base'-
  %   workspace. However, objects that are embedded in cell-arrays, 
  %   structs or other objects can still be closed as the HDS Toolbox
  %   does not search for HDS objects inside 'base'- variables.
  %
  %   In certain scenarios, it is possible that HDSCleanup seems to
  %   increase the amount of memory used by the objects. This is not a
  %   bug but can be attributed to an update of the estimate of the size
  %   of the objects.
	%
  %   see also: HDS HDS.CLOSE

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
    global HDSManagedData
    
  % -- Init --
  keepObjIds = [];
  switch nargin  
    case 0 
      % tLim is the number of minutes that is used as the threshold for removing
      % objects.
      tLim = 10;
      % Curlim are the minimum number of objects that should stay in memory.
      curLim = 200;
    case 1
      assert(isnumeric(varargin{1}) && length(varargin{1})==1, ...
        'Incorrect input arguments in HDSCLEANUP.');
      tLim = varargin{1};
      curLim = 200;
    case 2
      assert(isnumeric(varargin{1}) && length(varargin{1})==1  && ...
        isnumeric(varargin{2}) && length(varargin{2})==1, ...
        'Incorrect input arguments in HDSCLEANUP.');
      tLim = varargin{1};
      curLim =  varargin{2};
    otherwise
      assert(isnumeric(varargin{1}) && length(varargin{1})==1 && ...
        isnumeric(varargin{2}) && length(varargin{2})==1, ...
        'Incorrect input arguments in HDSCLEANUP.');
      for i = 3:length(varargin)
        assert(isa(varargin{i},'HDS'), 'Incorrect input arguments in HDSCLEANUP.');
        aux = [varargin{i}.objIds];
        keepObjIds = [keepObjIds aux(1,:)]; %#ok<AGROW>
      end
      tLim = varargin{1} * 60;  %TLim should be is seconds.
      curLim =  varargin{2};
  end        
    
  % -- Main --

  % Find list of objIds that are defined in base workspace, they should not be removed.
  baseVars = evalin('base', 'who');
  for i = 1:length(baseVars)
    isHDS = evalin('base',sprintf('isa(%s,''HDS'')',baseVars{i}));
    if isHDS
      if evalin('base',sprintf('isvalid(%s)', baseVars{i}))
        aux = evalin('base', sprintf('[%s.objIds]', baseVars{i}));
        keepObjIds = [keepObjIds aux(1,:)]; %#ok<AGROW>
      end
    end
  end
    
  % Iterate over all the data trees.
  freedMem = zeros(1, length(HDSManagedData));
  totalMem = zeros(1, length(HDSManagedData));
  for iTree = 1: length(HDSManagedData)

    % DATENUMMX is the mex function used by DATENUM and is a lot faster as
    % we do not have to do a lot of checks because we know the format is
    % correct.
    curTime = (60*1440)*(datenummx(clock) - HDSManagedData(iTree).treeInitTime);

    % -- Look at which objects to close --
    activeObjs  = HDSManagedData(iTree).objIds(1,:) > 0;
    curIds      = HDSManagedData(iTree).objIds(:, activeObjs);
    curBools    = HDSManagedData(iTree).objBools(:, activeObjs);

    totalMem(iTree) = sum(curIds(6,:));

    % Datenum increases 1 for every day = 1440 minutes.
    timDiff = (curTime - curIds(5,:));

    % Close objects that have been unused for longer than tLim.
    if size(curIds,2) > curLim

      % Keep indeces of keepObjIds in HDSManagedData
      keepIdx = ismembc(curIds(1,:), sort(keepObjIds));

      % Keep items that have been changed.
      keepIdx = keepIdx | curBools(1,:) | curBools(2,:);

      % Keep items that have been used more recently than 'tLim' minutes.
      keepIdx = keepIdx | timDiff <= tLim;

      % Keep the 'curLim' number of last used items.
      timDiff(keepIdx) = 0; % to make sure they are included.
      [~, lastUsedIx] = sort(timDiff);
      keepIdx(lastUsedIx(1:curLim)) = true;

      closeIds = HDSManagedData(iTree).objIds(:, ~keepIdx);
      uniqueCloseClasses = unique(closeIds(2,:));
      for iClass = 1 : length(uniqueCloseClasses)
        cls     = HDSManagedData(iTree).classes{uniqueCloseClasses(iClass)};
        indeces = closeIds(3, closeIds(2,:) == uniqueCloseClasses(iClass));
        clObjs  = HDSManagedData(iTree).(cls)(indeces);
        close(clObjs,'s');
      end 
    end

    % -- Now look at the remaining objects and remove the dataProps if
    % unused for more than tLim time.
    activeObjs = HDSManagedData(iTree).objIds(1,:) > 0;
    curIds = HDSManagedData(iTree).objIds(:, activeObjs);
    curBools = HDSManagedData(iTree).objBools(:, activeObjs);

    % Datenum increases 1 for every day = 1440 minutes.
    timeDiff = (curTime - curIds(5,:)) * 1440;

    timeLimIdx = find(timeDiff > tLim);
    curIds = curIds(:, timeLimIdx);
    curBools = curBools(:, timeLimIdx);

    for iObj = 1: size(curIds,2)
      if curBools(4, iObj) && ~curBools(2,iObj)
        curClass = HDSManagedData(iTree).classes{curIds(2,iObj)};
        obj = HDSManagedData(iTree).(curClass)(curIds(3,iObj));
        cleardataprops(obj, timeLimIdx(iObj));
      end
    end

    newSize = HDSManagedData(iTree).objIds(6, activeObjs);
    freedMem(iTree) = totalMem(iTree) - sum(newSize);

  end

  display(sprintf('-- Memory cleanup: %6.1f kB - %6.1f kB = %6.1f kB --', ...
      sum(totalMem)/1000, sum(freedMem)/1000, sum(totalMem-freedMem)/1000));

  if nargout
    varargout{1} = sum(freedMem);
  end
 
end