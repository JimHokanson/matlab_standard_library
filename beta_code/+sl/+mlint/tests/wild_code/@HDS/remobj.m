function obj = remobj(obj, className, varargin)                                 
  %REMOBJ  Removes a linked object from the object.
  %   OBJ = REMOBJ(OBJ, 'classname') removes the last entry of the property
  %   with objects of type 'classname' in the current object.  
  %
  %   OBJ = REMOBJ(OBJ, 'className', INDEX) removes the object at the INDEX
  %   from the property with objects of type 'className' in the current
  %   object. 
  %
  %   Example
  %       A = Animal; 
  %       addobj(A,'Experiment','name'); 
  %       remobj(A,'exp');        

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
    
  global HDSManagedData

  % Check input arguments.
  assert(length(obj)==1, 'Cannot remove an object from an array of objects.');

  % RemIdx is vector with indeces that should be removed.
  remIdx = -1; % -1 indicates last added object.
  
  % Check input arguments
  assert(nargin >= 2, 'Not enough input arguments.');    
  if nargin == 3 
    assert(isnumeric(varargin{1}), 'INDEX argument must be numeric.');
    remIdx = sort(varargin{1});
  else
    assert(nargin == 2, 'Too many input arguments.');
  end
 
  % Register obj if not previously registered.
  treeId = obj.treeNr;
  if ~treeId; [obj, treeId] = registerObjs(obj); end

  % find property in object that contains the objects that should be removed.
  classId     = uint32(find(strcmp(className, HDSManagedData(treeId).classes), 1));
  assert(~isempty(classId), ...
    'The object contains no properties with objects of type %s.', upper(className));

  childPropClassIds = obj.linkPropIds(1,:);
  childPropClassIds(obj.linkPropIds(2,:) == uint32(0)) = 0;    % Only check child PropIds
  childPropId  = uint32(find(classId == childPropClassIds, 1));        % Find childPropId for class.

  assert(~isempty(childPropId), ...
    'The object contains no properties with objects of class %s.', upper(className));
  
  propName    = obj.linkProps{childPropId};

  % Load all objects of that property in memory. Might be missing objects
  % if database corrupted. 
  allObjs = subsref(obj, substruct('.', propName));

  % -- Identify indeces etc for removal --
  IdxForClass = obj.linkIds(2,:) == childPropId;
  
  % Check that all objects that are supposed to be in property are loaded.
  assert(length(allObjs) == sum(IdxForClass), ...
    'Unable to load all the objects in property: %s of class: %s.', ...
    upper(propName), upper(className));
  
  % If remIdx is set to -1, this means remove last index.
  if remIdx == -1; remIdx = sum(IdxForClass); end; 

  % Check if indeces exist
  nrOfUniqueRemIDx = length( unique(remIdx) );
  assert(nrOfUniqueRemIDx == length(remIdx) && ...
    all(remIdx > 0) && max(remIdx)<=length(IdxForClass), ...
    'Trying to remove unexisting indeces from object.');

  allObjIds = obj.linkIds(1, IdxForClass);
  remObjIds = allObjIds(remIdx);

  % Find which idx in allObjs correspond with remObjIds
  remIdx2 = ismembc(childPropId, sort(remObjIds));

  [~, locId, ~, ~] = getobjlocation(obj);
  remLoc = [classId; obj.objIds(1); locId];
  
  %Check if location exists in locArray. This method is used instead of
  %finding the locArray in ObjIds because it is possible it does not exist.
  lastLocCol  = find(HDSManagedData(treeId).locArray(1,:) > uint32(0), 1, 'last');
  flipArray   = zeros(size(HDSManagedData(treeId).locArray,1), lastLocCol, 'uint32');
  [irow,icol] = find(HDSManagedData(treeId).locArray ~= 0);
  for jj = 1 : lastLocCol
    aux = irow(icol == jj);
    flipArray(1:length(aux), jj) = HDSManagedData(treeId).locArray(aux(end:-1:1), jj);
  end
  
  % Check for size issues
  if size(flipArray,1) >= length(remLoc)
    mirroredRemLocArray = double(remLoc(end:-1:1,ones(size(flipArray,2),1)));
    truncFlipArray      = double(flipArray(1:length(remLoc),:));
    fileLocIdx          = find(~any(truncFlipArray - mirroredRemLocArray));
  else
    fileLocIdx          = [];
  end
  
  % Add location if location does not exist.
  if isempty(fileLocIdx)
    HDSManagedData(treeId).locArray(1:length(remLoc), lastLocCol+1) = remLoc;
    fileLocIdx = lastLocCol + 1;
  end

  % Set removed Objects. Don't add indeces to remIds if the fileLoc is 0
  % because we don't know which file to change anyways.
  if fileLocIdx ~=0
    if ~isempty(HDSManagedData(treeId).remIds) 
      addedRemIds = uint32( [fileLocIdx(ones(1, length(remObjIds))) ; remObjIds] );
      HDSManagedData(treeId).remIds = [HDSManagedData(treeId).remIds addedRemIds] ;
    else
      HDSManagedData(treeId).remIds = [fileLocIdx(ones(1,length(remObjIds))) ; remObjIds];
    end
  end

  % Mark allObjs as changed to prevent closing the objects as it  will result in an error 
  % if you try to reload the objects.
  HDS.objchanged('obj', allObjs);
  HDS.objchanged('obj', obj);

  % -- Remove object ID from object --
  remChildIdx = ismembc(obj.linkIds(1,:), sort(remObjIds));
  obj.linkIds(:, remChildIdx) = [];

  % Remove property from childProps if no more objects of that class exist.
  if ~any(obj.linkIds(2,:) == uint32(childPropId))
    obj.linkPropIds(:,childPropId) = [];
    obj.linkProps(childPropId) = [];
    linkIdsShouldShift = obj.linkIds(2,:) > uint32(childPropId);
    obj.linkIds(2, linkIdsShouldShift) = obj.linkIds(2, linkIdsShouldShift) - 1 ;
  end

  % Delete pointers to removed objects
  delete(allObjs(remIdx2));

  % -- Remove object from HDSManagedData -- 
  activeIds  = HDSManagedData(treeId).objIds(1,:) > uint32(0);
  ManRemIds  = ismembc2(remObjIds, HDSManagedData(treeId).objIds(1, activeIds));
  
  assert(all(ManRemIds >0), 'Cannot find objects to be removed in memory.');
  HDSManagedData(treeId).objIds(:, ManRemIds)   = zeros(6, length(ManRemIds),'uint32');
  HDSManagedData(treeId).objBools(:, ManRemIds) = false(4, length(ManRemIds));

  % -- -- Remove all children of the removed objects -- --
  if fileLocIdx
    % Get a flipped version of the locArray
    lastLocCol = find(HDSManagedData(treeId).locArray(1,:) > 0, 1, 'last');
    flipArray = zeros(size(HDSManagedData(treeId).locArray,1), lastLocCol);
    [irow,icol] = find(HDSManagedData(treeId).locArray ~= uint32(0));
    for jj = 1 : lastLocCol
      aux = irow(icol == jj);
      flipArray(1:length(aux),jj) = double(HDSManagedData(treeId).locArray(aux(end:-1:1),jj));
    end

    % Find all the file Ids which should be deleted. 
    remFileIdx = zeros(100,1,'uint32');

    ix  = 1;                
    for ii = 1: length(remIdx)
      remLoc = flipArray(:, fileLocIdx);
      remLoc = double([remLoc(remLoc > 0) ; remObjIds(ii)]);

      if length(remLoc)< size(flipArray,1)
        aux = find(~any(double(flipArray(1:length(remLoc),:)) - remLoc(:,ones(1,lastLocCol)),1)); 

        ix2 = ix + length(aux);
        if length(remFileIdx) <= ix2;
          remFileIdx = [remFileIdx ; zeros(max([2*length(aux) 100]),1,'uint32')]; %#ok<AGROW>
        end

        remFileIdx(ix:ix2-1) = uint32(aux);
        ix = ix2;
      end
    end

    remFileIdx = remFileIdx(remFileIdx>0);

    % Iterate over fileIds and remove associated objects.
    for ii = 1: length(remFileIdx)
      remIds = HDSManagedData(treeId).objIds(4,:) == remFileIdx(ii);
      ll = sum(remIds);
      remClIdx = HDSManagedData(treeId).objIds(3, remIds);
      classStr = HDSManagedData(treeId).classes{HDSManagedData(treeId).objIds(2, find(remIds,1))};
      delete(HDSManagedData(treeId).(classStr)(remClIdx));
      HDSManagedData(treeId).objIds(:, remIds)   = zeros(6, ll,'uint32');
      HDSManagedData(treeId).objBools(:, remIds) = false(4, ll);
    end
    paddingLocArray = zeros(size(HDSManagedData(treeId).locArray,1), length(remFileIdx), 'uint32');
    HDSManagedData(treeId).locArray(:, remFileIdx) = paddingLocArray;
  end

  % Rearrange locArray property in HDSManagedData and reassign fileID in objIds.
  activeLocIdx = find(HDSManagedData(treeId).locArray(1,:));
  oldend = max(activeLocIdx);
  newend = length(activeLocIdx);

  HDSManagedData(treeId).locArray(:, 1: newend) = HDSManagedData(treeId).locArray(:, activeLocIdx);
  HDSManagedData(treeId).locArray(:, (newend+1) : oldend) = ...
    zeros(size(HDSManagedData(treeId).locArray,1),oldend-newend, 'uint32');

  for ii = 1: length(activeLocIdx)
    if ii ~= activeLocIdx(ii)
      FileLocIsActiveLocObjIds = HDSManagedData(treeId).objIds(4,:) == activeLocIdx(ii);
      HDSManagedData(treeId).objIds(4, FileLocIsActiveLocObjIds) = uint32(ii); 
      FileLocIsActiveLocRemIds = HDSManagedData(treeId).remIds(1,:) == activeLocIdx(ii);
      HDSManagedData(treeId).remIds(1, FileLocIsActiveLocRemIds) = uint32(ii);
    end
  end

  % Sort ids without ids which are being removed.
  activeIds = HDSManagedData(treeId).objIds(1,:) > uint32(0);
  aux = HDSManagedData(treeId).objIds(:, activeIds);
  [~ , I] = sort(aux(1,:));

  newlength = sum(activeIds);
  oldlength = find(activeIds,1,'last');
  HDSManagedData(treeId).objIds(:, 1:newlength ) = aux(:,I);
  HDSManagedData(treeId).objIds(:, newlength+1: oldlength) = zeros(6, oldlength-newlength,'uint32');

  aux2 = HDSManagedData(treeId).objBools(:, activeIds );
  HDSManagedData(treeId).objBools(:, 1:newlength ) = aux2(:,I);
  HDSManagedData(treeId).objBools(:, newlength+1: oldlength) = false(4, oldlength-newlength);

end
