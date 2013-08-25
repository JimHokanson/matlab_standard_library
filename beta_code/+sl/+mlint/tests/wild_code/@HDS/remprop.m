function obj = remprop(obj, propName)                                           
  %REMPROP  Removes dynamic property from object.
  %   REMPROP(OBJ, 'fieldname') removes property with 'fieldname' from the
  %   object if the property is a dynamic property which was added using the
  %   addprop method. Therefore, no properties that contain objects added by
  %   the ADDOBJ method can be removed using this method and no properties
  %   that are defined in the object's class definition can be removed.
  %   
  %   See also: hdscleanup addprop addobj remobj addlink remlink getprop

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  % Check if obj is single object
  assert(length(obj)==1, 'Method not defined for arrays of objects');
  assert( ~any(strcmp(propName, obj.linkProps)), ...
    'Use the REMOBJ or REMLINK methods to remove linked objects.');

  % Register obj if not previously registered.
  treeId = obj.treeNr;
  if ~treeId; [obj, ~] = registerObjs(obj); end

  h = findprop(obj, propName);
  delete(h);

  %Check if removed: If user tries to remove original property, it will not be removed.
  assert(isempty(findprop(obj, propName)), ...
    'Cannot remove property that is defined in the object''s class definition.');

  HDS.objchanged('obj',obj);
end
