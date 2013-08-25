function [path, index] = getpath(obj)                                           
  %GETPATH  Returns the path where the object is stored on disk.
  %   PATH = GETPATH(OBJ) returns the path where the object is
  %   stored on disk. Path returns an empty string if the object
  %   has not been saved before.
  %
  %   [PATH, INDEX] = GETPATH(OBJ) also returns the index of the
  %   object in the .mat file. Note that the index can be
  %   different from the index in memory when, for example, the
  %   objects are resorted. The index reflects the index of the
  %   object on the disk.

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  global HDSManagedData

  %Check if obj is single object
  assert(length(obj)==1, 'Method not defined for arrays of objects');

  % Register object if not previously registered.
  treeId = obj.treeNr;
  if ~treeId; [obj, treeId] = registerObjs(obj); end

  % Get location of object with respect to the host object.
  [ids, locId,~,~] = getobjlocation(obj);
  locIdi = [ids(1) ; locId];

  % Get location with respect to the basePath.
  curLoc = locIdi(end - (2*HDSManagedData(treeId).treeConst(4)):-1:1) ;

  curPath = HDSManagedData(treeId).basePath;
  if length(curLoc) > 2
    % Use no index for first folder/file when there is no basepath offset.
    if HDSManagedData(treeId).treeConst(4)
      curPath = fullfile(curPath, sprintf('%s_%i', ...
        HDSManagedData(treeId).classes{curLoc(2)}, curLoc(3)));
    else
      curPath = fullfile(curPath, sprintf('%s', ...
        HDSManagedData(treeId).classes{curLoc(2)}));
    end
    for ii = 4:2:length(curLoc)
      curPath = fullfile(curPath,sprintf('%s_%i', ...
        HDSManagedData(treeId).classes{curLoc(ii)}, curLoc(ii-1)));
    end
  end

  path = curPath;
  index = locIdi(1);
end
