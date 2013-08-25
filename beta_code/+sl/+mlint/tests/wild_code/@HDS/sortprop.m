function obj = sortprop(obj, propName, sortOption, varargin)
  %SORTPROP sorts the objects of a property of the object.
  %   OBJ = SORTPROP(OBJ, 'propName', NEWINDECES) reorganizes the
  %   objects in the indicated property of object OBJ. The
  %   objects are resorted such that: NEW = OLD(NEWINDECES). 
  %
  %   OBJ = SORTPROP(OBJ, 'propName', 'sortProperty') can be used to
  %   align the index of the sorted object in the OBJ property 'propName'
  %   with a numeric value in the sorted object. In case that the values
  %   in the properties of the sorted objects are not consequent numbers,
  %   the method will add empty objects in the unspecified locations.
  %   This means that the total number of objects in the 'propName'
  %   property of OBJ can be larger after calling this method. 
  %
  %   OBJ = SORTPROP(OBJ, 'propName', 'sortProperty, '-noEmpty') the
  %   '-noEmpty' parameter can be added to prevent the method from
  %   addding empty objects in case the some indeces are not assigned.
  %   The indeces will be assigned based on the values in the
  %   'sorProperty' of the sorted objects where the object with the
  %   lowest value will be assigned to the first index and the object
  %   with the highest value will be assigned to the the last index. In
  %   this case it is possible that the index of the object does not
  %   align with the number in the 'sortProperty'.
  %
  %   Examples:
  %       sortprop(M.exp(3), 'trial', [4 3 2 1])
  %           Will reassign the indeces of the trial objects such that
  %           the trial object that used to be at index 4 will now be
  %           assigned to index 1.
  %       sortprop(M.exp(3), 'trial', 'trialId')
  %           Will align the index of the trials in the experiment object
  %           with the value of the trialId property in the trial
  %           objects. 
  %       sortprop(M.exp(3), 'trial', 'trialId', '-noEmpty') 
  %           Will sort the 'trial' objects in the experiment object
  %           based on the values in the 'trialId' property of the trial
  %           objects. 

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  

  global HDSManagedData

  % Get childProp index
  childIndex = find(strcmp(propName, obj.linkProps),1);

  %Check if obj is single object
  assert(length(obj)==1, 'Method not defined for arrays of objects');
  assert(~isempty(childIndex), ...
    'SORTPROP: Object does not have a property ''%s'' that contains other objects.', propName);

  % Check input arguments.
  noEmpty = false;
  assert(any(nargin == [3 4]), 'SORTPROP: Incorrect number of input variables.');
  if nargin == 4
    assert(ischar(varargin{1}),'SORTPROP: Incorrect fourth argument: ''%s''.',varargin{1});
    assert(strcmp(varargin{1},'-noEmpty'), ...
      'SORTPROP: Incorrect fourth argument: ''%s''.',varargin{1});
    noEmpty = true;
  end

  % Register object if not previously registered.
  treeId = obj.treeNr;
  if ~treeId
      [obj, treeId] = registerObjs(obj);
  end 

  % Get all the objects
  propObjs = subsref(obj, substruct('.', propName) );

  % Get all indeces in HDSManagedData
  activeIds = HDSManagedData(treeId).objIds(1,:) > 0;

  % Find objects in HDSManagedData
  IxChildIds  = find(obj.linkIds(2,:) == uint32(childIndex));
  objIdsInM   = ismembc2(obj.linkIds(1, IxChildIds), HDSManagedData(treeId).objIds(1, activeIds) );

  % reassign indeces in HDSManagedData and OBJ.
  if isnumeric(sortOption) && isvector(sortOption)
    % Round input to nearest integer and check for errors in the input.
    sortOption = round(sortOption);
    assert(length(sortOption) == length(propObjs), ...
      'SORTPROP: Incorrect number of elements in the ''sortOption'' input variable.');
    assert(all(ismembc(1:length(propObjs), sort(sortOption))), ...
      'SORTPROP: ''SortOption'' input does not contain indeces 1 throught the number of objects.');

    % Change indeces in OBJ
    obj.linkIds(:, IxChildIds) = obj.linkIds(:, sortOption);

    % Change indeces in HDSManagedData
    [~,Sindex] = sort(sortOption);
    HDSManagedData(treeId).objIds(6, objIdsInM) = Sindex; 

  elseif ischar(sortOption)
    % Check if the child property exists.
    h = fieldnames(propObjs);
    
    assert(any(strcmp(sortOption, h)), ...
      'SORTPROP: ''%s'' is not a correct property name for objects of class %s.', ...
      sortOption, upper(class(propObjs)));
    
    % Get values of property
    try
        propValues = [propObjs.(sortOption)];
    catch ME
        error('HDS:sortprop','SORTPROP: Unable to extract indeces from property values.');
    end
    assert(length(propValues) == length(propObjs), ...
      'SORTPROP: Empty values in the property ''%s'' of the sorted objects.',sortOption);
    assert(isvector(propValues) && isnumeric(propValues), ...
      'SORTPROP: Unable to extract new indeces from property values.');

    % Rearrange objects depending on the noEmpty option.
    if noEmpty
      [~, sIndeces] = sort(propValues);

      % Change indeces in OBJ
      obj.linkIds(:, IxChildIds) = obj.linkIds(:, sIndeces);

      % Change indeces in HDSManagedData
      HDSManagedData(treeId).objIds(6, objIdsInM) = sIndeces;
    else

      propValues = round(propValues);
      assert(all(propValues) > 0 ,...
        'SORTPROP: Not all values in the ''%s'' property have values > 0.',sortOption);
      assert(ength(unique(propValues)) == length(propValues), ...
        'SORTPROP: Unable to resolve duplicate values determining the object indeces.');

      % All condition have been met. Check if the maximum index is way bigger
      % than the current length of the property and ask user to continue if so.
      if max(propValues) > length(subsref(obj,substruct('.',propName))) + 100
        ix = 1;
        while 1
          ok = input(...
            sprintf('\nSORTPROP will generate an additional %i objects, continue (y/n)?  ', ...
            max(propValues)-length(subsref(obj,substruct('.',propName)))),'s');
          switch ok
            case 'y'
              break;
            case 'n'
              fprintf('SORTPROP cancelled.\n');
              return;
          end
          assert(ix<=3, ...
            'SORTPROP: Incorrect input value, please answer using either ''y'' or ''n''.');
          ix=ix+1;
        end
      end 

      missingIdx = find(~ismembc(1:max(propValues), sort(propValues)));
      if ~isempty(missingIdx)
        addobj(obj, class(propObjs),length(missingIdx));

        % populate the sortOption property with missing values.
        propObjs = subsref(obj, substruct('.', propName) );
        for i = 1: length(missingIdx) 
            propObjs(length(propValues)+i).(sortOption) = missingIdx(i);  
        end

        % Get values again:
        propValues = [propObjs.(sortOption)];
        propValues = round(propValues);

        % Check propValues; this should not ever fail.
        memberOfValues = ismembc(1:max(propValues),sort(propValues));
        lengthCheck = length(propValues) == max(propValues);
        assert(memberOfValues && lengthCheck && all(propValues > 0), ['SORTPROP: Exception in '...
          'sortprop call, propValues are not correct: This should never happen.']);

        % Get all indeces in HDSManagedData
        activeIds = HDSManagedData(treeId).objIds(1,:) > 0;

        % Find objects in HDSManagedData
        IxChildIds  = find(obj.linkIds(2,:) == uint32(childIndex));
        objIdsInM   = ismembc2(obj.linkIds(1, IxChildIds), ...
          HDSManagedData(treeId).objIds(1, activeIds) );
      end
      [~, sIndeces] = sort(propValues);

      % Change indeces in OBJ
      obj.linkIds(:, IxChildIds) = obj.linkIds(:, sIndeces);

      % Change indeces in HDSManagedData
      HDSManagedData(treeId).objIds(6, objIdsInM) = propValues;
    end
  else
      error('HDS:sortprop','SORTPROP: ''SortOption'' input not correctly defined.');
  end

  % Set the obj and the childObj changed-flag.
  HDS.objchanged('obj',propObjs);
  HDS.objchanged('obj',obj);

  % Add the current fileId to the remIds with index 0;
  fileId = HDSManagedData(treeId).objIds(4, objIdsInM(1));
  HDSManagedData(treeId).remIds = [HDSManagedData(treeId).remIds [fileId; 0; 0] ];
end
