function obj = revertobj(obj)
  %REVERTOBJ  Reverts object back to version on disk.
  %   OBJ = REVERTOBJ(OBJ) reverts OBJ and all its children
  %   objects back to the version on disk. It will close the
  %   object and its children regardless of any changes that are
  %   made to the object. It will then reload OBJ from disk and
  %   return it. 

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  global HDSManagedData

  assert(length(obj)==1, 'Method not defined for arrays of objects');

  [fileIds, locId, bools, Mindex] = getobjlocation(obj);
  treeId = obj.treeNr; %treeNr exist because this is checked in previous method.

  assert(bools(3), ...
    'Object has not previously been saved to disk. To remove the object, use the REMOBJ method.');

  % Set the booleans indicating changed object of obj and its
  % children to false. Then close the obj. CLOSE will work as it
  % does no longer detect that the objects have changed.

  % Create the fliparray to search for children objects.
  lastLocCol = find(HDSManagedData(treeId).locArray(1,:) > 0,1,'last');
  flipArray = zeros(size(HDSManagedData(treeId).locArray,1), lastLocCol);
  [irow,icol] = find(HDSManagedData(treeId).locArray ~= 0);
  for jj = 1 : lastLocCol
    aux = irow(icol == jj);
    flipArray(1:length(aux),jj) = HDSManagedData(treeId).locArray(aux(end:-1:1),jj);
  end

  % get indeces in HDSManagedData for children objects.
  mainLoc = double([locId(end:-1:1); fileIds(5)]);
  trucFlipArray = double(flipArray(1:length(mainLoc),:));
  mirroredArray = mainLoc(:,ones(size(flipArray,2),1));
  childLocs =  find(~any(trucFlipArray - mirroredArray));

  % Set the HDS.objchanged and datachanged booleans to false for obj. This is
  % necessary otherwise, the close method will not work. Unnecessary to
  % update the transient properties in objects themselves because the objects
  % are removed anyways.    
  HDSManagedData(treeId).objBools(1, Mindex) = false;
  HDSManagedData(treeId).objBools(2, Mindex) = false;

  % Set the HDS.objchanged and datachanged booleans to false for children.
  for ii = 1: length(childLocs)
    chdidx = HDSManagedData(treeId).objIds(4,:) == uint32(childLocs(ii));
    HDSManagedData(treeId).objBools(1, chdidx) = false;
    HDSManagedData(treeId).objBools(2, chdidx) = false;
  end

  % Close object and children.
  out = close(obj);
  assert(out, 'Something is wrong, close should have closed all objects.');

  % Get the path to the object
  curLoc = locId(end:-1:1);
  curPath = HDSManagedData(treeId).basePath;
  if HDSManagedData(treeId).treeConst(4) == 0
    curPath = fullfile(curPath, sprintf('%s', ...
      HDSManagedData(treeId).classes{curLoc(2)}));
  else
    curPath = fullfile(curPath, sprintf('%s_%i', ...
      HDSManagedData(treeId).classes{curLoc(2)}, curLoc(1)));
  end
  for ii = 3 : 2: length(curLoc)
    curPath = fullfile(curPath, sprintf('%s_%i', ...
      HDSManagedData(treeId).classes{curLoc(ii+1)}, curLoc(ii)));
  end

  dataName = sprintf('i%i',fileIds(5));

  HDS.loadobj(obj,true);
  out = load([curPath '.mat'],dataName);
  HDS.loadobj(obj,false);

  out = out.(dataName);                                                
  obj = registerObjs(out, treeId, curLoc(end:-1:1), fileIds(6), true);

  % Set fileChanged if the obj index should not be same as
  % fileindex becasue of sorting in the parent object.
  if fileIds(5) ~= fileIds(6)
    newMindex = find(HDSManagedData(treeId).objIds(1,:) == fileIds(1),1);
    HDSManagedData(treeId).objBools(1, newMindex) = true;
    HDSManagedData(treeId).objIds(5, newMindex) = fileIds(5);
  end

end
