function  prop = propforclass(obj, className, includeLink)
  %PROPFORCLASS  Returns properties with objects of specified class.
  %   PROP = PROPFORCLASS(OBJ, 'className') returns a cell-array with the
  %   names of properties that contain objects of class 'className'. This
  %   includes objects added using ADDPROP or ADDLINK. If no properties
  %   contain objects of class 'className', PROP will be an empty cell.
  %
  %   PROP = PROPFORCLASS(OBJ, 'className', INCLUDELINK) Behaves the same
  %   as the previous example if INCLUDELINK is set to TRUE. If
  %   INCLUDELINK is set to FALSE, the method returns the property that
  %   contains child objects of class 'className'. The method returns a
  %   single cell containing the property name or returns an empty cell
  %   if no property exists containing children objects of class
  %   'className'.
  %
  %   Examples:
  %       P = PROPFORCLASS(M.exp(4), 'trial', false)
  %
  %   See also: addprop addlink

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  global HDSManagedData

  % -- Check if obj is single object
  assert(length(obj)==1, 'Method not defined for arrays of objects');

  % Register obj if not previously registered.
  treeId = obj.treeNr;
  if ~treeId; [obj, treeId] = registerObjs(obj); end

  assert(any(nargin == [2 3]), 'PROPFORCLASS: Incorrect number of input arguments.');
  if nargin == 2
    includeLink = true;
  else
    assert(islogical(includeLink), 'PROPFORCLASS: The ''includeLink'' input should be a logical.');
  end
  assert(ischar(className), 'PROPFORCLASS: The ''className'' input should be a string.');
  
  if isempty(obj.linkProps)
      prop = cell(0,1);
      return
  end

  % -- Get the property names
  classNames = HDSManagedData(treeId).classes;
  classId = uint32(find(strcmp(className, classNames),1));

  if includeLink
    allPropIds = find(obj.linkPropIds(1,:) == classId);  
  else
    allPropIds = find(obj.linkPropIds(1,:) == classId  & obj.linkPropIds(2,:) == uint32(1));  
  end
  prop = obj.linkProps(allPropIds);
end