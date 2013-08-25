function str = propclass(obj, propname)
  %PROPCLASS  Returns the class-name of the data in a property.
  %   STR = PROPCLASS(OBJ, 'propName') returns the class name of the data
  %   in the property. If the property is considered a 'dataProp', it
  %   will not load any of the data from disk.
  %
  %   This method can be usefull to request the data type that is used
  %   for data stored in a 'dataProp' property without having to load any
  %   of the data into memory.
  %
  %   see also: HDS.GETPROP HDS.SIZEPROP HDS.LENGTHPROP

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  global HDSManagedData

  assert(length(obj)==1, 'Method not defined for arrays of objects');
  assert(isprop(obj,propname), ...
    'PROPCLASS: %s is not a valid property of the object.',upper(propname));

  datPropIdx = find(strcmp(propname, obj.dataProps),1);
  lnkPropIdx = find(strcmp(propname, obj.linkProps),1);
  if ~isempty(datPropIdx)

    typeId = obj.dPropSize(datPropIdx,1);

    switch typeId
      case 1
        str = 'int8';
      case 2
        str = 'char';
      case 3
        str = 'int16';
      case 4
        str = 'int32';
      case 5
        str = 'single';
      case 6
        str = 'double';
      otherwise
        % get default value from class definition.
        str = class(obj.(propname));
    end

  elseif ~isempty(lnkPropIdx)
    classId = obj.linkPropIds(1,lnkPropIdx);

    % Register object if not previously registered.
    treeId = obj.treeNr;
    if ~treeId; [~, treeId] = registerObjs(obj); end
        
    str = HDSManagedData(treeId).classes{classId};

  else
    str = class(obj.(propname));
  end
end