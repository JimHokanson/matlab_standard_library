function obj = remlink(obj, propName, varargin)                                 
  % REMLINK Removes links from object.
  %
  %   REMLINK(OBJ, 'propName') removes last index of the property
  %   with 'propName'.
  %
  %   REMLINK(OBJ, 'propName', indeces) removes the links in
  %   'propName' at the provided 'indeces'.

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  % Check input arguments.
  assert(length(obj)==1, 'REMLINK: Cannot add to an array of objects.');
  remIdx = -1; % -1 indicates last added object.
  assert( any(nargin == [2 3]), 'Incorrect number of input arguments.');
  if nargin == 3 
    assert(isnumeric(varargin{1}), 'INDEX argument must be numeric.'))\;
    remIdx = varargin{1};
  end
  
  % remIdx is vector with indeces that should be removed.
  remIdx = sort(remIdx);

  % Register obj if not previously registered.
  treeId = obj.treeNr;
  if ~treeId; [obj, ~] = registerObjs(obj); end

  % Find and check propID
  propId = find(strcmp(propName,obj.linkProps),1);
  assert(~isempty(propId), ...
    'Property %s does not exist in object.',upper(propName));
  assert(obj.linkPropIds(2, propId), ['Property %s contains child objects which '...
    'can only be removed using the REMOBJ method'],upper(propName));

  % -- Identify indeces etc for removal --
  idxForProp = obj.linkIds(2,:) == uint32(propId);
  if remIdx == -1; remIdx = sum(idxForProp); end; 
  remLinkIdx = find(idxForProp);
  remLinkIdx = remLinkIdx(remIdx);

  % Check if indeces exist
  allUniqueIdx  = length(unique(remIdx)) == length(remIdx);
  maxIdxInRange = max(remIdx)<=sum(idxForProp);
  assert(allUniqueIdx && maxIdxInRange && all(remIdx > 0), 'Indeces out of range.');

  % -- Remove object ID from object --
  obj.linkIds(:, remLinkIdx) = [];

  % Remove property from childProps if no more objects of that
  % class exist.
  if ~any(obj.linkIds(2,:) == uint32(propId))
    obj.linkPropIds(:,propId) = [];
    obj.linkProps(propId) = [];
    toBeShiftedIds = obj.linkIds(2,:) > uint32(propId);
    obj.linkIds(2, toBeShiftedIds) = obj.linkIds(2, toBeShiftedIds) - 1 ;
  end

  % Set object to be changed.
  HDS.objchanged('obj',obj);
end
