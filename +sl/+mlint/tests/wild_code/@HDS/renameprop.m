function obj = renameprop(obj, oldName, newName)
  %RENAMEPROP  Changes the name of a property.
  %   OBJ = RENAMEPROP(OBJ, 'oldName', 'newName') renames the property
  %   'oldName' to 'newName' in a single or array of objects. This method
  %   only works on properties that were added to the object using the
  %   ADDOBJ, ADDLINK or ADDPROP method.
  %
  %   See also: ADDOBJ ADDLINK ADDPROP

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  assert(nargin == 3, 'RENAMEPROP: Incorrect number of input arguments.');
  assert(ischar(oldName) && ischar(newName), ....
    'RENAMEPROP: OLDNAME and NEWNAME input arguments should be of type ''char''.');

  for iObj = 1: length(obj)

    % Check whether newName exist in obj  
    h = findprop(obj(iObj),newName);
    assert(isempty(h) && ~any(strcmp(newName,obj(iObj).linkProps)), ...
      'RENAMEPROP: Property ''%s'' already defined in object.', newName);

    % Get index in propNames if exist
    propIdx = find(strcmp(oldName, obj(iObj).linkProps),1);
    if ~isempty(propIdx)
      obj(iObj).linkProps{propIdx} = newName;
    else
      % Check if added using ADDPROP
      h = findprop(obj(iObj), oldName);
      
      assert(~isempty(h), 'RENAMEPROP: Property %s does not exist in object.',upper(oldName));
      assert(isa(h, 'meta.DynamicProperty'), ...
        'RENAMEPROP: Method only works on properties created by ADDOBJ, ADDLINK or ADDPROP.');
      assert(~strcmp(oldName,newName), 'RENAMEPROP: OLDNAME and NEWNAME are the same.');
      
      addprop(obj(iObj),newName);
      if h.Transient
        h2 = findprop(obj(iObj), newName);
        h2.Transient = true;
      end
      obj(iObj).(newName) = obj(iObj).(oldName);
      delete(h);
    end
  end
  
  HDS.objchanged('obj',obj);
end