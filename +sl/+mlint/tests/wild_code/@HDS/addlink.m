function obj = addlink(obj, propName, linkObjs)                                 
  %ADDLINK  Adds a link to other objecs in the object structure.
  %   OBJ = ADDLINK(OBJ, 'propName', LINKOBJS) Adds links to the
  %   LINKOBJS HDS-objects to the 'propName' property in the OBJ.
  %   LINKOBJS need to have the same 'hostID' property as the OBJ
  %   which means that the LINKOBJS belong to the same database
  %   as the OBJ.
  %
  %   Links to objects have to have their own property in the OBJ
  %   and cannot be added to a property that contains objects of
  %   the same class that have been added using the ADDOBJ
  %   method.

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  global HDSManagedData

  %Check if obj is single object
  assert(length(obj)==1, 'ADDLINK: Cannot add to an array of objects.');
  assert(~isempty(linkObjs), 'ADDLINK: Empty array of link objects.');

  % Register object if not previously registered.
  treeId = obj.treeNr;
  if ~treeId; [obj, treeId] = registerObjs(obj); end

  % Currently limit the database such that you can only add links
  % if the offset is 0
  assert(HDSManagedData(treeId).treeConst(4) == 0, ...
    'You can currently not add links when a partial datatree is used.');

  linkObjTree = [linkObjs.treeNr];
  assert(all(linkObjTree == treeId), ...
    ['The objects you are trying to add do not belong to the same data structure as '...
    'the object you are trying to add them to.']);

  addClassId = find(strcmp(class(linkObjs), HDSManagedData(treeId).classes), 1);

  % Check if property can be used for linked objects. Property
  % needs to be empty currently a linkProp with the same class
  % objects.
  matchPropName = strcmp(propName, [obj.linkProps]);
  if any(matchPropName)
    propIndex = find(strcmp(propName, [obj.linkProps]), 1);

    assert(~obj.linkPropIds(2, propIndex), ...
      ['The property %s cannot contain linked objects as it already contains child ' ...
      'objects of the current object.'],upper(propName));
    assert(obj.linkPropIds(1, propIndex) == uint32(addClassId), ...
      ['The property %s cannot contain linked objects of class %s as it already '...
      'contains linked objects of another class.'], upper(propName), upper(class(linkObjs)));
    assert(uint32(addClassId) == obj.linkPropIds(1,matchPropName), ...
      'Incorrect class; object of class %s cannot be added to property %s.',...
      upper(class(linkObjs)), upper(propName));

  else
    obj.linkProps = [obj.linkProps propName];
    obj.linkPropIds = [obj.linkPropIds uint32([addClassId; 0])];
    propIndex = length(obj.linkProps);
  end

  % Get LocIds as cell array: First index in locid is parent objid and parent class.
  locIdCell = cell(length(linkObjs),1);

  for ii = 1: length(linkObjs)
    curObj = linkObjs(ii);
    for jj = 1: (curObj.objIds(5))
      curObj = subsref(curObj, substruct('.', 'parent'));
      locIdCell{ii}((2*jj)-1:(2*jj)) = [curObj.objIds(1) curObj.objIds(2)];
    end
  end

  % Reshape LinkLocs into array
  maxLength = max([cellfun('length', locIdCell) ; size(obj.linkLocs,1)]);

  % Grow linkLocs if necessary
  if size(obj.linkLocs,1) < maxLength
    obj.linkLocs = [obj.linkLocs ; zeros(maxLength - size(obj.linkLocs,1), size(obj.linkLocs,2), 'uint32')];
  end 

  locIdArr = zeros(maxLength, length(linkObjs), 'uint32');
  for ii = 1: length(linkObjs)
    locIdArr(1:length(locIdCell{ii}), ii) = uint32(locIdCell{ii});
  end

  % get Location ids and populate locations if new.
  loc = zeros(1, length(linkObjs));
  for ii = 1: length(linkObjs)
    aux = find(~any( double(obj.linkLocs) -  repmat(double(locIdArr(:,ii)), 1, size(obj.linkLocs,2))),1);
    if isempty(aux)
      obj.linkLocs = [obj.linkLocs locIdArr(:,ii)];
      loc(ii) = size(obj.linkLocs,2);
    else
      loc(ii) = aux;
    end
  end

  lnkIds = [linkObjs.objIds];
  lnkIds = lnkIds(1,:);
  aux = uint32([lnkIds ; propIndex(ones(1,length(lnkIds))) ; loc]);
  obj.linkIds = [obj.linkIds aux];
  HDS.objchanged('obj',obj);
end
