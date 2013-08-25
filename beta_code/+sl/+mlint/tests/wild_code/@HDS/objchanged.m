function objchanged(option, obj)                                          
  % OBJCHANGED  Sets the flags to indicate the object needs saving.
  %   OUT = OBJCHANGED('obj', OBJ) flags the HDS Toolbox that the object
  %   has changed and requires saving. The 'obj' input parameter
  %   indicates that the change occurred in any of the object properties
  %   except the properties described in 'dataProps'.
  %
  %   OUT = OBJCHANGED('data', OBJ) flags the HDS Toolbox that a
  %   'data'-property of the object has been changed and requires
  %   saving. 
  %
  %   When both data and object properties have changed, calling this
  %   method with the 'data' option is sufficient as this automatically
  %   results in resaving the complete object.
  %
  %   This method is normally automatically called by the HDS Toolbox in
  %   case of changes with one exception. If objects are changed from
  %   within a class-method, the overloaded subsref and subsasgn
  %   functions are not called and it is required that the OBJCHANGED
  %   method is called manually. See the documentation for additional
  %   information about subsref and subsasgn calls from class methods.

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  global HDSManagedData
  
  assert(nargin == 2, 'OBJCHANGED: Incorrect number of input arguments.');
  if isempty(obj); return; end;
  assert(any(strcmp(option, {'obj' 'data'})), ...
    'OBJCHANGED: Incorrect option for function call with two arguments.');
  
  % Check if all belong to same tree and all are associated with tree.
  treeId = obj(1).treeNr;
  assert( all([obj.treeNr] == treeId), ...
    ['OBJCHANGED: Cannot call OBJCHANGED method using an array of objects from different '...
    'databases or a mixed array of registered and unregistered objects.']);
  
  % If object(s) not registered yet, only change the obj.saveStatus. 
  if treeId == 0
    switch option
      case 'obj'
        % Change saveStatus in the objects. 
        for i=1:length(obj)
          obj(i).saveStatus = max([uint32(1) obj(i).saveStatus]);
        end
      case 'data'
        for i=1:length(obj)
          obj(i).saveStatus = uint32(2);
        end
    end
    return
  end
  
  % Find the CHANGEDIDS
  if length(obj) == 1
    % If object has treeNr, than find object in HDSManagedData.
    changedIds = HDSManagedData(treeId).objIds(1,:) == obj.objIds(1);

    % If the object is not found, something is really wrong.
    assert(any(changedIds), ...
      'The object thinks it is registered but is not referenced in memory. (HDS BUG)');
  else
    % Find logical index of the changed objects.
    changedIds = HDSManagedData(treeId).objIds(1,:) > 0;  %get all active Units
    iD = [obj.objIds];
    iDSorted = sort(iD(1,:));

    % select from all active units only the once that have changed.
    changedIds(changedIds) = ismembc(HDSManagedData(treeId).objIds(1, changedIds), iDSorted);

    % Check if all objects were found
    assert(sum(changedIds) == length(obj) ,...
      'OBJCHANGED: Not all objects are found in HDSMANAGEDDATA. (This is a bug)');
  end
  
  switch option
    case 'obj'  
      % Set 'obj'-save flag in HDSMANAGEDDATA
      HDSManagedData(treeId).objBools(1, changedIds) = true;

      % Change saveStatus in the objects. 
      for i=1:length(obj)
        obj(i).saveStatus = max([uint32(1) obj(i).saveStatus]);
      end

    case 'data'     
      % Get the size of the object and update the HDSManagedData.
      warning('OFF','MATLAB:structOnObject');
      objSize = zeros(length(obj),1);
      for i = 1: length(obj)
        aux = struct(obj); %#ok<NASGU>
        aux2 = whos('aux');
        objSize(i) = aux2.bytes;
        obj(i).saveStatus = uint32(2);
      end
      warning('ON','MATLAB:structOnObject');

      % Set flags in HDSMANAGEDDATA
      HDSManagedData(treeId).objIds(6, changedIds) = uint32(objSize);
      HDSManagedData(treeId).objBools(4,changedIds) = true;
      HDSManagedData(treeId).objBools(2,changedIds) = true;
      HDSManagedData(treeId).objBools(1,changedIds) = true;  
  end
end
