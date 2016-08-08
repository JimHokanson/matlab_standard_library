function varargout = close(obj, varargin)
  % CLOSE  Removes object from memory.
  %   CLOSE(OBJ) Removes object(s) OBJ and all its children
  %   objects from memory as long as there are no unsaved changes
  %   to the objects. If some objects contain changes, only the
  %   unchanged objects are removed from memory. 
  %
  %   CLOSE(OBJ,'s') removes objects(s) OBJ but does not
  %   remove any children of the object(s). 
  %
  %   OUT = CLOSE(OBJ,...) returns a boolean indicating whether
  %   all requested objects were removed from memory. If false,
  %   some objects could not be removed because they contain
  %   changes with respect to the object on disk.

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  % Init
  global HDSManagedData

  % Check input arguments  
  switch nargin
    case 1
      shouldRemChild = true;
    case 2
      assert(strcmp('s', varargin{1}), 'Incorrect input argument.');
      shouldRemChild = false;
    otherwise
      error('HDS:close','Incorrect number of input arguments.');
  end

  % Check tree Ids
  treeId = obj(1).treeNr;
  assert(treeId > 0, ...
    'Save object(s) before closing them or use the CLEAR method to destroy the object.');
  assert(all([obj.treeNr] == treeId), ...
    'All inputs of the CLOSE method should belong to the same data tree.');

  % Determine the flipped array when we want to remove the children.
  if shouldRemChild
    % Change the fileLocations in the locArray of HDSManagedData
    lastLocCol = find(HDSManagedData(treeId).locArray(1,:) > uint32(0), 1, 'last');
    flipArray = zeros(size(HDSManagedData(treeId).locArray,1), lastLocCol, 'uint32');
    [irow,icol] = find(HDSManagedData(treeId).locArray ~= 0);
    for jj = 1 : lastLocCol
      aux = irow(icol == jj);
      flipArray(1:length(aux),jj) = HDSManagedData(treeId).locArray(aux(end:-1:1),jj);
    end
  end

  % Remove the objects and/or children objects
  out = true;
  iD  = [obj.objIds];
  for ii = 1: size(iD,2)
    % Iterate over the objects that should be closed and close
    % objects and children if necessary.

    [fileIds, locId, bools, Mindex] = getobjlocation(obj(ii));

    % If children should be removed, remove children. This is
    % done by finding all objects with same Location array as
    % main object
    mainLoc = double([locId(end:-1:1); fileIds(1)]);
    if shouldRemChild
      truncFlipArray  = double(flipArray(1:length(mainLoc),:));
      mirroredArray   = mainLoc(:,ones(size(flipArray,2),1));
      childLocs       =  find(~any(truncFlipArray - mirroredArray));

      childIdx    = find(ismembc(HDSManagedData(treeId).objIds(4,:), uint32(childLocs)));
      childIds    = HDSManagedData(treeId).objIds(:,childIdx);
      childBools  = HDSManagedData(treeId).objBools(:,childIdx);

      % Now, check if there have been changes in these objects.
      changedObjs = childBools(1,:) | childBools(2,:);

      out = out && ~any(changedObjs);

      % Only select objects that are not changed.
      childIds = childIds(:, ~changedObjs);
      childIdx = childIdx(~changedObjs);

      if ~isempty(childIds)
        % Get and delete object handles
        for jj = 1:length(childLocs)
          objIdx = childIds(:, childIds(4,:) == childLocs(jj));

          %It is possible that objIdx is empty because of
          %unused childlocs or changed childlocs.
          if ~isempty(objIdx)
            clsStr = HDSManagedData(treeId).classes{objIdx(2,1)};
            objs   = HDSManagedData(treeId).(clsStr)(objIdx(3,:));
            delete(objs);
          end
        end

        % Remove object references from OBJIDS and OBJBOOLS
        HDSManagedData(treeId).objIds(:,childIdx)   = zeros(6, length(childIdx),'uint32');
        HDSManagedData(treeId).objBools(:,childIdx) = false(4, length(childIdx));
      end
    end

    % Now remove the main object.
    if ~(bools(1) || bools(2))
      delete(obj(ii));
      HDSManagedData(treeId).objIds(:, Mindex) = zeros(6,1,'uint32');
      HDSManagedData(treeId).objBools(:, Mindex) = false(4,1);
    else
      HDS.displaymessage(['Warning: Some objects were not closed because they contain '...
        'unsaved changes.'],2,'\n','\n');
      out = false;
    end

  end

  % Sort ids without ids which are being closed.
  activeIds = logical(HDSManagedData(treeId).objIds(1,:));
  aux = HDSManagedData(treeId).objIds(:, activeIds);
  [~ , I] = sort(aux(1,:));

  lastIndex = find(activeIds,1,'last');

  newlength = sum(activeIds);
  HDSManagedData(treeId).objIds(:, 1:newlength ) = aux(:,I);   
  padding = zeros(6, lastIndex - newlength,'uint32' );
  HDSManagedData(treeId).objIds(:, newlength+1: lastIndex) = padding;

  aux2 = HDSManagedData(treeId).objBools(:, activeIds );
  HDSManagedData(treeId).objBools(:, 1:newlength ) = aux2(:,I);  
  padding = zeros(4, lastIndex - newlength);
  HDSManagedData(treeId).objBools(:, newlength+1: lastIndex) = padding;

  if nargout 
    varargout{1} = out;
  else
    varargout = {};
  end

end
