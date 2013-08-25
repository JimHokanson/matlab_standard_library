classdef HDS < dynamicprops
  %HDS  Abstract class definition for HDS Toolbox.
  %   HDS is an abstract class definition which serves as the backbone
  %   for the HDS Toolbox. Derived subclasses should be defined as
  %   necessary to accomodate the structure of the desired database. When
  %   defining the subclasses, it is required to implement the
  %   properties: "listAs", "classVersion", "childClasses",
  %   "parentClasses", "metaProps", "dataProps", "propsWithUnits",
  %   "propUnits", "propDims", and "strIndexProp". These properties
  %   define the underlying structure of the data and internal structure
  %   of an object.
  % 
  %   The HDS Toolbox is designed to be a very general and multipurpose
  %   data structuring tool. The core functionality is to mimic the
  %   MATLAB-STRUCT behavior while using a distributed file structure forwp
  %   storage of the data. 
  %
  %   More information can be found in the help files for the HDS
  %   Toolbox.

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.

  % -- -- -- HDS Class Properties -- -- --    
  properties (SetAccess = private, Hidden)                                            
    objIds        = zeros(5,1,'uint32')   % [objId, objClassId, parentId, hostId, treeOffset]
    createDate    = zeros(1,6)            % Date of object creation
    objVersion    = zeros(1,2)            % [HDS Version, Object Version]
    linkProps     = cell(1,0)             % {propname}
    linkPropIds   = zeros(2,0,'uint32')   % [classID isChildProp]
    linkLocs      = zeros(5,0,'uint32')   % Array with classIds of linked object and parent objects. 
    linkIds       = zeros(3,0,'uint32')   % [objId propId linkLoc] of all linked objects.
    dPropSize     = zeros(2,3,'uint32')   % Array that describes data in dataprops when they are not loaded in mem.
  end

  properties (SetAccess = private, Transient, Hidden)                      
    treeNr        = 0                     % Data is managed in index X of HDSManagedData.
    saveStatus    = zeros(1,1,'uint32')  	% Status: 0-onDisk, 1-objSave, 2-dataSave, 3-updated.
    parent        = []                    % Returns parent object if it exists.
    dataInMem     = zeros(0,3,'uint32')   % [changed min max ... ] changed indicator - indeces that are loaded for each data prop.
  end
    
  properties (Constant, Hidden)                                                       
    HDSClassVersion     = 1.0   % Version Number of HDS Toolbox class definition.
  end
    
    % -- -- -- Abstract Properties -- -- --
  properties (Abstract, Constant, Hidden)                                             
    listAs            % String with name of property the class will be listed as by default.
    classVersion      % Version number of the sub-class.
    childClasses      % Cell array of strings with class-types of possible dynamic variables.
    parentClasses     % Cell array of strings with class-types of possible parent objects.
    metaProps         % Cell array of strings with property names that should be searchable.
    dataProps         % Cell array of strings with property names that contain pure data.
    propsWithUnits    % Cell array of strings with property names that contain values with units.
    propUnits         % Cell array with strings indicating the units of the properties with units.
    propDims          % Cell array of cells with the names for the dimensions of the properties with units.
    strIndexProp      % Property name that is used to specify string indexing for object.
    maskDisp          % StrCellarray indicating properties that should not be evaluated during display.
  end
    
    % -- -- -- HDS Methods -- -- --
  methods
    function obj = get.parent(obj)                                                  
      %This function is only called if the parent property is called
      %from a class function using the '.'-notation. It forces the
      %parent to be called through the subsref method.

      %The function should return an empty arry when the parent is
      %called from within the HDS class as this only happens when we
      %try to get the size of the object.

      %Only problem so far is that it will call the parent if the
      %struct(obj) function is called from the base workspace.

      aux = dbstack(1);
      if ~isempty(aux)
        skipFiles = {'HDS.m' 'HDS.objchanged.m' 'objchanged.m' 'propclass.m'};
        if ~any(strcmp(aux(1).file, skipFiles))
          obj = subsref(obj, substruct('.','parent'));
        else
          obj = [];
        end
      else
        obj = subsref(obj, substruct('.','parent'));
      end
    end
    updateobj(obj)
  end
    
  methods (Sealed)
    function obj = HDS                                                              
      persistent HDSCheckedClasses

      obj.createDate  = clock;
      obj.objIds      = uint32([0 ;1 ;0 ;0 ;0]);
      obj.objVersion  = [obj.HDSClassVersion obj.classVersion];
      obj.saveStatus  = uint32(1);
      obj.dataInMem   = zeros(length(obj.dataProps),3, 'uint32');
      obj.dPropSize   = zeros(length(obj.dataProps),3, 'uint32');

      % Check if the class definition is well defined if not
      % previously done. 
      % 1) The class name should only contain characters [A-Za-z0-9], no underscores! 
      % 2) Data properties should be Transient and should exist as
      % properties
      % 3) The meta properties cannot be transient.
      % 4) The STRINDEXPROP should exist and not be Transient.
      % 5) Max number of childClasses set to 50.
      % 6) PropsWithUnits should exist.
      % 7) The length of the dataUnits and DataDims should be same as length dataProps
      % 8) check for reserved metaNames

      if ~strcmp(class(obj), HDSCheckedClasses)
        className = class(obj);
        assert(length(regexp(className,'[A-Za-z0-9]')) == length(className),...
          ['HDS: The classname %s is not a valid name for the HDS_Toolbox.'...
            'Names should only contain characters from the set [A-Za-z0-9].'...
            'No underscores are allowed.'],upper(className));  

        % Check DataProps  
        for i = 1 : length(obj.dataProps)
          h = findprop(obj, obj.dataProps{i});
          assert(~isempty(h), ...
            'HDS: The ''dataProps'' property in %s contains non-existing property names.', ...
            upper(class(obj)));
          
          assert(h.Transient, ...
            ['HDS: Properties defined in the ''dataProps'' property of %s ' ...
            'should be set to ''Transient''.'],upper(class(obj)));
        end

        % Check the meta-props
        for i = 1 : length(obj.metaProps)
          h = findprop(obj, obj.metaProps{i});
          reservedNames = {'link' 'oid' 'pid' 'parentId' 'fLink' 'linkId' 'linkClassId' ...
            'comboId' 'parentIdx'};
          assert(~isempty(h), ...
            'HDS: The ''metaProps'' property contains non-existing property names.');
          assert(~h.Transient, ...
            'HDS: Properties from the ''metaProps'' property cannot be set to ''Transient''.');
          assert(any(strcmp(class(obj.(obj.metaProps{i})), ...
            {'char' 'double' 'logical' 'single' 'cell'})), ...
            ['HDS: Properties defined in the ''metaProps'' property should be '...
            'initialized as either ''char'', ''logical'', ''double'' or ''single''.']);
          aux = strcmp(obj.metaProps{i}, reservedNames);
          assert(~any(aux), ...
            '%s is a reserved HDS meta-name and cannot be used in the class definition.', ...
            upper(['' reservedNames{find(aux,1)}]));
        end
        
        % Check the string-index prop
        if ~isempty(obj.strIndexProp)
          h = findprop(obj, obj.strIndexProp);
          assert(~isempty(h), ['HDS: The STRINDEXPROP constant is set to a property '...
            'name that does not exist in the object.']);
          assert(~h.Transient, ['HDS: The property that is defined in the STRINDEXPROP '...
            'constant cannot be defined as ''Transient''.']);
        end
        
        % Check the PropsWithUnits and PropDims properties.
        fnames = fieldnames(obj);
        checkNames = cellfun(@(x) any(strcmp(x, fnames)), obj.propsWithUnits);
        assert(all(checkNames), ['HDS: One of the properties defined in the '...
          '''propsWithUnits'' constant of class %s does not exist.'],upper(class(obj)));
        assert(length(obj.propUnits) == length(obj.propsWithUnits) && ...
          length(obj.propDims) == length(obj.propsWithUnits), ...
          ['HDS: Incorrect definition of ''DataUnits'' constant. Length of '...
          '''propsWithUnits'',''propUnits'' and ''propDims'' should be equal.']);

        % Add class to HDSCHeckedClasses
        HDSCheckedClasses{length(HDSCheckedClasses)+1} = className;

        % Finally, check if it is possible to create object without  constructor variables. 
        % set activeHDStree to prevent registration when data-properties are assigned.
        try
          hdspreventreg(true);
          aux = eval(className); %#ok<NASGU>
          hdspreventreg(false);
        catch ME
          hdspreventreg(false);
          HDSCheckedClasses{length(HDSCheckedClasses)} = []; %#ok<NASGU>
          error('HDS:init', ['HDS:%s: The HDS Toolbox requires that each class' ...
            'constructor can be called without input arguments.'], upper(className));
        end
      end
    end
    function varargout = subsref(obj, s)                                            

      try
        iS = 0;
        while iS < length(s)
          iS = iS + 1;
          assert(ischar(s(iS).type), 'ERROR: Incorrect subsref inputs.');

          switch s(iS).type
            case '.' 
              % Make sure that the reference is correctly formatted.
              assert(ischar(s(iS).subs), 'ERROR: Incorrect subsref inputs.');

              if length(obj) == 1

                % Switch request function based on type of property that is requested.
                switch s(iS).subs
                  case obj.linkProps                                      
                    [obj, iS] = subsref_getLinks(obj, s, iS);
                  case obj.dataProps                  
                    [obj, iS] = subsref_getData(obj, s, iS);
                  case 'parent'                       
                    [obj, ~] = subsref_getParent(obj, [], iS);                 
                  otherwise   
                    obj = builtin('subsref', obj, s(iS:end));
                    break
                end

              elseif length(obj) > 1

                % Make sure that this is last step of request
                assert(iS == length(s), ['Field reference for multiple object elements '...
                    'that is followed by more reference blocks is an error.']);

                sIsSubs = s(iS).subs;  

                % Check whether we can use matlabs internal subsref function or not.
                if any(strcmp(sIsSubs,[ [obj.linkProps] [obj.dataProps] 'parent']))  

                  % Check if all objects belong to same Host object.
                  allIds = [obj.objIds]; 
                  assert(all(allIds(4,1) == allIds(4,:)), ['All objects in a vector should '...
                    'have the same ''hostId'' when you index linked objects or data-properties.']);                                           

                  % Use a for loop to get the referenced propertes.
                  data = cell(1, length(obj));
                  for iObj = 1: length(obj)
                    temp = obj(iObj);
                    try
                      data{iObj} = subsref(temp, substruct('.', sIsSubs));
                    catch ME 
                      error('HDS:subsref',['Property %s does not exist in all instances of %s. ' ...
                        'First missing index: %i'], upper(s(iS).subs), upper(class(obj)), iObj);
                    end
                  end

                else % Get the objects using the matlab subsref function.
                  data = {obj.(sIsSubs)}; 
                end
                obj = data;  % set obj to data. 

              else
                % Lenght obj == 0, return empty. This should be caught somewhere else in future.
                varargout = {[]};
                return
              end
            case '()' % Get subset of object-array
              obj = obj(s(iS).subs{1}); 
            case '{}' % Only index if obj is not an object.
              assert(isobject(obj), ...
                '%s object cannot be referenced using the ''{}'' notation.', upper(class(obj)));
              obj = builtin('subsref', obj, s(iS:end));
              iS = length(s);
            otherwise
              error('HDS:subsref', 'Unexpected MATLAB expression.');
          end 
        end

        % Format varargout such that it corresponds with the nargout value.
        if nargout <= 1
          varargout = {obj};% Nargout equals 1 --> return single cell. 
        else
          varargout = obj;  % Nargout does not equal 1 --> return cell array. 
        end
      catch ME
        throwAsCaller(ME);
      end
    end
    function obj = subsasgn(obj, s, val)                                            

      % There are two situations in which the VAL can be an object.
      % One is to initiate an array of objects and two is to replace
      % or concatenate an array of objects with other objects.
      
      if isa(val, 'HDS')
        objForVal = true;
        if isempty(obj)
          % Now there are two situations; 1) single vector of
          % indices and 2) multi-vector of indices.
          if length(s.subs) == 1                            
            indeces = s.subs{1};
            assert(length(s.subs{1}) == length(val), ...
              'In an assignment  A(I) = B, the number of elements in B and I must be the same.');
            assert(strcmp(s.type,'()'), ...
              'Subsasgn called with unexpected parameter.');
            assert(all(indeces)>0 && ~isempty(indeces), ...
              'Subscript indices must either be real positive integers or logicals.');

            [maxVal loc]  = max(indeces);
            allLoc        = 1:maxVal;
            noLoc         = find(~ismembc(allLoc, sort(indeces)));

            obj = val(1);
            obj(maxVal) = val(loc);
            for i = 1:length(indeces)
              obj(indeces(i)) = val(i);
            end

            hdspreventreg(true);
            for i = 1:length(noLoc)
              obj(noLoc(i)) = eval(class(val));
            end
            hdspreventreg(false);

            return
          else
            indeces = [s.subs{:}];

            assert(length(s.subs) == length(indeces) && isnumeric(indeces), ...
              'Subscript indices must be real positive integers on LHS.');
            assert(strcmp(s.type,'()'), 'Subsasgn called with unexpected parameter.');
            assert(all(indeces) > 0 && ~isempty(indeces), ...
              'Subscript indices must either be real positive integers or logicals.');
            assert(length(val) == 1, ...
               'In an assignment  A(I) = B, the number of elements in B and I must be the same.');

            lastindex = prod(indeces);
            obj = val;
            obj(lastindex) = val;

            hdspreventreg(true);
            for k = 1:lastindex-1
               obj(k) = eval(class(val));
            end
            hdspreventreg(false);

            % Reshape array to output array.
            obj = reshape(obj, indeces);
            return
          end

        elseif length(s)==1 && strcmp(s(1).type, '()') 

          assert(isa(val,class(obj)), ...
            'Conversion to %s from %s is not possible.', class(obj), class(val));
          obj(s(1).subs{1}) = val;
          return;

        end
      else
        objForVal = false;
      end

      % -- VAL is not an object and can therefore be assigned to
      % properties in other objects. --     

      treeId = obj.treeNr;
      if ~treeId; [obj, ~] = registerObjs(obj); end

      curObj  = obj;
      iS      = 0;
      while 1
        iS = iS + 1;
        switch s(iS).type
          case '.'  
            assert(length(curObj) == 1, ...
              'Cannot set multiple instances of %s.', upper(class(curObj)) );
            
            switch s(iS).subs
              case [curObj.linkProps] 

                assert(length(s) > iS, ...
                  'Use ADDOBJ and REMOBJ to change dynamic variable %s of object %s.', ...
                  upper(s(iS).subs), upper(class(curObj)) );
                
                if strcmp(s(iS+1).type,'()') 
                  assert(length(s) > iS + 1, ...
                    'Use ADDOBJ and REMOBJ to change dynamic variable %s of object %s.', ...
                    upper(s(iS).subs), upper(class(curObj)) );
                  
                  curObj = subsref(curObj, s(iS:iS+1));
                  iS = iS+1;
                else
                  curObj = subsref(curObj,s(iS));
                end

              case [curObj.dataProps] 
                % If we want to change a subpart of the data, force load the data into the object.
                if length(s) > iS
                  if strcmp(s(iS+1).type, '()')
                    aux = hdsoption;
                    dataOption = aux.dataMode;
                    switch dataOption
                      case 1
                        % force load data
                        subsref(curObj, s(iS));
                      case 2
                        % Check if dec is off
                        aux = hdsoption();
                        assert(all(aux.decimation==1), ...
                          'HDS : Cannot set data property when decimation factor ~= 1.');

                        % Force load the property.
                        aux = subsref(curObj, s(iS));
                        curObj.(s(iS).subs) = aux;
                      otherwise
                        error( 'HDS:SUBSASGN',...
                          'HDS: Incorrect Data Option, use HDSOPTION to set to a valid setting.');
                    end
                  end
                end
                break   
              case 'parent' 
                assert(length(s) > iS, ...
                  'Cannot set the PARENT property of object %s.',upper(class(curObj)));
                assert(strcmp(s(iS+1).type,'.'), ...
                  'Cannot set the PARENT property of object %s.',upper(class(curObj)));
                curObj = subsref(curObj, s(iS));
                
              otherwise
                  break
            end

          case '()' 
            assert(length(s) > iS, 'Use ADDOBJ and REMOBJ to change objects.');
            curObj = curObj(s(iS).subs{1});
          case '{}'
            error('HDS:AssgnCell', 'Cell contents reference from a non-cell array object.');
        end
      end

      % Check if property is public
      mc = findprop(curObj, s(iS).subs);
      
      assert(~isempty(mc), 'Property ''%s'' does not exist in current object of class %s.', ...
        s(iS).subs, upper(class(curObj)) );
      assert(strcmp(mc.SetAccess,'public'), ...
        'Cannot access private variable %s of class %s', upper(s(iS).subs), upper(class(curObj)));
      assert(mc.Transient || ~objForVal, ['Use ADDOBJ method to add object to current '...
        'object or assign object to ''Transient'' property for temporary use (see ADDPROP).']);

      % If trying to set dataPropsstrcmp(curObj.dataProps, s(iS).subs
      dataPropId = find(strcmp(curObj.dataProps, s(iS).subs),1);
      isDataProp = any(strcmp(curObj.dataProps, s(iS).subs));

      if isDataProp
        assert(isnumeric(val) || ischar(val), ...
          ['Properties defined as ''dataProps'' in the class definition can only contain '...
          'numeric data or a string.']);

        switch class(val)
          case 'double'
            typeId = 6;
          case 'single'
            typeId = 5;
          case 'int32'
            typeId = 4;
          case 'char'
            typeId = 2;
          case 'int8'
            typeId = 1;
          case 'int16'
            typeId = 3;
          otherwise
            error('HDS:savehds', ['Values in ''dataProp'' properties have to be either: '...
              '''double'', ''single'', ''char'', ''int8'',''int16'' or ''int32''']);
        end

        builtin('subsasgn', curObj, s(iS:end), val);
        ps = size(curObj.(s(iS).subs));
        curObj.dPropSize(dataPropId,1:(1+length(ps))) = uint32([typeId ps]);

        % Set the memory vector to include all data.
        memVec = [ones(1,length(ps)) ; ps];
        curObj.dataInMem(dataPropId,1:(1+2*length(memVec))) = uint32([3 memVec(1:end)]);

        HDS.objchanged('data',curObj);
      else
        builtin('subsasgn', curObj, s(iS:end), val);
        if curObj.saveStatus == uint32(0)
          HDS.objchanged('obj',curObj);
        end
      end

    end
    function [objs, treeId] = registerObjs(objs, treeId, locId)                     
      % REGISTEROBJS(OBJS) registers object when the treeId or locID are unknown
      % REGISTEROBJS(OBJS, TREEID, LOCID) registers objects when treeID and locID are known.
      
      global HDSManagedData

      switch nargin
        case 1
          % Make sure that the length of objs equals 1.
          assert(length(objs) == 1, 'Undefined registration can only have one input object.');

          % HDSPREVENTREG returns true if the created object should not be registered.
          if hdspreventreg(); treeId = []; return; end

          % Check if object that is being registered is a new Host.
          locId = [];
          if objs.objIds(4) == 0 % No previous hostID
            % Create random host/object ID for object [0 1e6]
            newHostId = uint32(1e6 * rem(sum(objs(1).createDate) * rand(1), 1));
            objs.objIds(4) = newHostId;
            
            % Set locID to host path [1;1]
            locId = [1 ; 1];
          else
            % Make sure that saveStatus is not set to 1 or 2.
            assert(~any(objs(1).saveStatus == uint32([1 2])), ['Trying to register object '...
              'without LocID that has previously been saved with 1 or 2 saveStatus is error']);
          end

          % Find tree Index associated with hostID
          [treeId, ~] = HDS.getTreeId(objs.objIds(4));
        case 3
          assert(~hdspreventreg, ...
            'HDSPREVENTREG returns true in REGISTEROBJS call with multiple inputs. (Bug.)');
          assert(treeId > 0, ...
            'TreeId returns 0 or less during registration. (This is a bug.)');
          assert(all([objs.saveStatus] == objs(1).saveStatus), ...
            'SaveStatus of objects to be registered is not the same for all objects. (Bug.)');
        otherwise
          error('HDS:registerobjs','REGISTEROBJS: Incorrect number of input arguments.');
      end
      
      % If the objects are from disk, link the objects to the path on disk,
      % otherwise, define the object IDs based on the hostID and objectID
      % increment.
      if any(objs(1).saveStatus == uint32([0 3]))

        if isempty(HDSManagedData(treeId).basePath)
          try
            HDS.linkTree2Disk(treeId);
          catch ME
            % Remove index from HDSManagedData if it does not contain any data.
            if ~any(HDSManagedData(treeId).objIds(1,:))
              HDSManagedData(treeId) = []; %#ok<NASGU>
            end
            rethrow(ME);
          end
        end

        if isempty(locId)
          locId = HDS.findObjonDisk(objs.objIds(1), objs.objIds(2), treeId, objs.objIds(5));
        end
      else
        % Change the object id number to be incremental and belong to certain host object.
        maxIDidx = HDSManagedData(treeId).treeConst(3);
        for i = 1:length(objs)
          objs(i).objIds(1) = maxIDidx + uint32(i);
        end
        HDSManagedData(treeId).treeConst(3) = maxIDidx + i;
      end

      % Define Class and ClassID for objects to be registered.
      addClassName = class(objs);
      addClassId   = HDS.getClassId(addClassName, treeId);

      % --- Check which objects are already managed --- It is possible to
      % register objects that are already in the repos. This happens when a file
      % is loaded that has been loaded from disk before. In this case, we will
      % ask the user which to use.

      Ids = [objs.objIds];
      Ids = Ids(1,:);

      active = HDSManagedData(treeId).objIds(1,:) > uint32(0);
      managedIds  = ismembc2(Ids, HDSManagedData(treeId).objIds(1, active)); 
      
      assert(~any(managedIds), ['Cannot register the object with the HDS Toolbox as it already '...
        'has a pointer assigned in memory. To revert back to the object version currently '...
        'stored on disk, use the REVERTOBJ method.']);

      % Check if user is trying to register objects that have been removed from databasse
      if ~isempty(HDSManagedData(treeId).remIds)
        inRemIds = ismembc(Ids, sort(HDSManagedData(treeId).remIds(2,:)));
        assert(~any(inRemIds), ['Trying to load objects that have been deleted from the '...
          'datatree using REMOBJ results in an error. To revert back to the object version '...
          'currently stored on disk, use the REVERTOBJ method.']);
      end

      % --- Add objects to the 'clasname' field ---
      % Grow the property 'classname' if necessary.
      allIdsForClass = HDSManagedData(treeId).objIds(2, :) == addClassId;
      freePos = (length(HDSManagedData(treeId).(addClassName)) - sum(allIdsForClass));
      if freePos < length(objs)
        hdspreventreg(true); % Prevent registration of objects during the eval step
        nr = length(objs) - freePos + 150;
        addClassPropLength = length(HDSManagedData(treeId).(addClassName));
        HDSManagedData(treeId).(addClassName)(addClassPropLength + nr) = eval(addClassName);
        HDSManagedData(treeId).objIds = [HDSManagedData(treeId).objIds zeros(6, nr,'uint32')];
        HDSManagedData(treeId).objBools = [HDSManagedData(treeId).objBools false(4, nr)];
        hdspreventreg(false);
      end

      % IDX: Find open/free indeces in the HDSManagedData.('classname') array.
      if any(allIdsForClass)
       activeIds = 1:length(HDSManagedData(treeId).(addClassName));
       activeIds(HDSManagedData(treeId).objIds(3, allIdsForClass)) = [];
      else
       activeIds = 1: length(HDSManagedData(treeId).(addClassName));
      end
      idx = activeIds(1 : length(objs));

      % Place objects in the open/free spots in the class field.
      HDSManagedData(treeId).(addClassName)(idx) = objs;


      % --- Add additional object info in the standard fields ---
      % Find open/free indeces in the HDSManagedData.objIds array.
      objIdx = find(~HDSManagedData(treeId).objIds(1,:), length(objs), 'first');

      % Grow the location array if necessary and place locId in 'LocArray'. Add
      % the FILEID to the 'locArray' field of the repository. Expand file
      % location for comparison to existing file locations and match file
      % locations.            
      s1 = size(HDSManagedData(treeId).locArray);
      if s1(1) < length(locId)
        padding = zeros((s1(1)-length(locId))+5, s1(2));
        HDSManagedData(treeId).locArray = [HDSManagedData(treeId).locArray ; padding];
      end

      % Get FileId
      fileId = HDS.getFileId(locId, treeId);

      % Set generic HDSBOOLS  
      if any(objs(1).saveStatus == uint32([0 3]))
        % The objects are loaded from disk
        objIdxLength = length(objIdx);
        HDSManagedData(treeId).objBools(:,objIdx) = ...
          [false(2, objIdxLength) ; true(1, objIdxLength); false(1, objIdxLength)];
      else
        % The objects are created in this session and not on disk.
        objIdxLength = length(objIdx);
        HDSManagedData(treeId).objBools(:,objIdx) = ...
          [true(1, objIdxLength) ; false(2, objIdxLength); true(1, objIdxLength)];        
      end

      % Find the object sizes and set object treeNr;
      warning('OFF','MATLAB:structOnObject');
      objSize = zeros(1, length(objs));
      for ii = 1: length(objs)
        aux         = struct(objs(ii)); %#ok<NASGU>
        aux2        = whos('aux');
        objSize(ii) = aux2.bytes;
        objs(ii).treeNr = treeId;

        % Set the dataInMem property
        dataPropLength = length(objs(ii).dataProps);
        objs(ii).dataInMem = zeros(dataPropLength, 1+2*(size(objs(ii).dPropSize,2)-1), 'uint32');
      end
      warning('ON','MATLAB:structOnObject');

      % Set the object Ids in HDSManagedData
      clk = (60*1440)*(datenummx(clock) - HDSManagedData(treeId).treeInitTime);

      objIdxLength = length(objIdx);
      HDSManagedData(treeId).objIds(:,objIdx) = ...
        uint32([ Ids ; addClassId(ones(1, objIdxLength));  idx ; ...
        fileId(ones(1, objIdxLength)); clk(ones(1, objIdxLength)); objSize]);

      % The objIds and objBools properties should always be sorted based on the
      % first row in objIds to accomodate ismembc and ismembc2 to get the data.
      activeObjs = HDSManagedData(treeId).objIds(1,:) > uint32(0);
      [~ , I] = sort(HDSManagedData(treeId).objIds(1 , activeObjs ));
      HDSManagedData(treeId).objIds(:, activeObjs )   = HDSManagedData(treeId).objIds(:, I);   
      HDSManagedData(treeId).objBools(:, activeObjs ) = HDSManagedData(treeId).objBools(:, I);

      % Set objChanged 'data' for object with dataproperties that changed before registering
      allSaveStatus = [objs.saveStatus];
      if any(allSaveStatus == uint32(2))
        display('Updating data changed');
        HDS.objchanged('data', objs(allSaveStatus == uint32(2)));  
      end

    end
    function disp(obj)                                                              
      %DISP  Displays the object in the console.
      %   DISP(OBJ) displays the object in the console. This method formats the
      %   data in the object and displays the object including links to
      %   informative methods.
      global HDSManagedData

      % Check if matlab is running in terminal. If so, no links are used.
      if usejava('desktop')
        showLinks = true;
      else
        showLinks = false;
      end

      % Ignore list
      igList = {'listAs' 'classVersion' 'childClasses' 'parentClasses' 'maskDisp' ...
        'metaProps' 'dataProps' 'propUnits' 'propDims' 'propsWithUnits' 'strIndexProp'};

      % Create links to methods
      Link1 = sprintf('<a href="matlab:help(''%s'')">%s</a>',class(obj),class(obj));
      Link2 = sprintf('<a href="matlab:methods(%s)">Methods</a>',class(obj));
      Link3 = sprintf('<a href="matlab:properties(%s)">Properties</a>',class(obj));
      Link4 = sprintf('<a href="matlab:childclasses(%s)">ChildClasses</a>',class(obj)); 

      if length(obj) == 1 

        % Check if object is deleted.
        if isvalid(obj)
          treeId = obj.treeNr;
          if treeId
            isChanged = obj.saveStatus > uint32(0);
          elseif obj.saveStatus == uint32(0)
            % Data not Loaded, otherwise would be in HDSManagedData.
            isChanged = true;
          else
            % Data loaded, and most likely empty.
            isChanged = true;
          end

          fieldn  = fieldnames(obj);
          fieldn  = fieldn(~cellfun(@(x) any(strcmp(x, igList)), fieldn));

          % Find unitprops.
          hasUnits = cellfun(@(x) max([0 find(strcmp(x, obj.propsWithUnits),1)]), fieldn);

          nFields = length(obj.linkProps);
          props   = [fieldn ; cell(nFields,1)];
          valTxts{1,length(props)} = [];
          unitTxts{1,length(props)} = [];
          for i = 0: (nFields-1)
            props{end-i} = obj.linkProps{end -i};
          end

          for i = 1:length(props) - nFields
            curProp = obj.(props{i});
            dProp = find(strcmp(props{i}, obj.dataProps),1);

            % --If data property, load data if necessary
            if any(dProp)
              % Determine string from dPropSize.
              emptyStr = '[]';
              curdProp = obj.dPropSize(dProp,:);
              switch curdProp(1)
               case 6
                  typeId = 'double';
                case 5
                  typeId = 'single';
                case 4
                  typeId = 'int32';
                case 2
                  typeId = 'char';
                  emptyStr = '''''';
                case 1
                  typeId = 'int8';
                case 3
                  typeId = 'int16';
                otherwise
                  typeId = 'unknown';
              end

              aux = find(curdProp(2:end),1,'last');
              if isempty(aux)
                valTxts{i} = [': ' emptyStr];
              else
                if aux > 1
                  sizestr = [num2str(curdProp(2)) sprintf('x%d',curdProp(3:aux+1))];
                  valTxts{i} = sprintf(': [%s %s]',sizestr, typeId);
                else
                  valTxts{i} = [': ' emptyStr];
                end
              end

            else
              if ischar(curProp)
                if length(curProp) < 50 && size(curProp,1)<=1
                  valTxts{i} = [': ''' curProp ''''];
                else
                  s = size(curProp);
                  valTxts{i} = sprintf(': [%ix%i char]',s(1), s(2));
                end
              elseif iscellstr(curProp)
                aux = cellfun(@(x) ['''' x '''  '], curProp, 'UniformOutput', false);
                if ~isempty(aux);aux(end) = strtrim(aux(end));end
                  valTxts{i} = [': {' [aux{:}] '}'];
                  if length(valTxts{i})>50
                    s = size(curProp);
                    sizestr = [num2str(s(1)) sprintf('x%d',s(2:end))];
                    valTxts{i} = sprintf(': {%s cell}',sizestr);
                  end
              elseif isnumeric(curProp)
                if length(curProp)==1
                  valTxts{i} = num2str(curProp,': %g');
                elseif length(curProp)<10 && ndims(curProp) == 2 && any(size(curProp) <= 1)
                  %Needs to be a row vector
                  if size(curProp,1) > 1
                    s = size(curProp);
                    sizestr = [num2str(s(1)) sprintf('x%d',s(2:end))];
                    valTxts{i} = sprintf(': [%s %s]',sizestr, class(curProp));
                  else
                    valTxts{i} = [': [' regexprep(num2str(curProp,'% g'),' +',' ') ']'];
                  end
                  if length(valTxts{i}) > 50
                    s = size(curProp);
                    sizestr = [num2str(s(1)) sprintf('x%d',s(2:end))];
                    valTxts{i} = sprintf(': [%s %s]',sizestr, class(curProp));
                  end
                else
                  s = size(curProp);
                  sizestr = [num2str(s(1)) sprintf('x%d',s(2:end))];
                  valTxts{i} = sprintf(': [%s %s]',sizestr,class(curProp));
                end
              elseif islogical(curProp)
                if curProp; valTxts{i} = ': True';else valTxts{i} = ': False';end
              else 
                s = size(curProp);
                sizestr = [num2str(s(1)) sprintf('x%d',s(2:end))];
                valTxts{i} = sprintf(': [%s %s]',sizestr, class(curProp));
              end
            end

            % -- Check for Units and dimensions
              if hasUnits(i)
                unitStr = obj.propUnits{hasUnits(i)};
                if isempty(obj.propDims{hasUnits(i)})
                  callstr = sprintf('The %s property contains values with unit: %s.',props{i}, unitStr);
                else
                  if iscell(obj.propDims{hasUnits(i)})
                    l = length(obj.propDims{hasUnits(i)});
                    if l == 1
                      dimStr = sprintf(': %s.',obj.propDims{hasUnits(i)}{1});
                      dimnum = '1';
                    else
                      dimnum = num2str(l);

                      dimStr = 's: ';
                      for ii = 1:(length(obj.propDims{hasUnits(i)})-1)
                        dimStr = [dimStr  sprintf('%i) %s,',ii, obj.propDims{hasUnits(i)}{ii})]; %#ok<AGROW>
                      end
                      dimStr = [dimStr  sprintf(' and %i) %s.',ii+1, obj.propDims{hasUnits(i)}{end})]; %#ok<AGROW>
                    end
                  else
                    dimnum = '1';
                    dimStr = sprintf(': %s.',obj.propDims{hasUnits(i)});
                  end
                  callstr = sprintf('The %s property contains values (%s) in %s dimension%s',props{i}, unitStr, dimnum, dimStr);
                end
                if showLinks
                  callstr = sprintf('display(''%s'')',callstr);
                  unitTxts{i} = sprintf(' <a href="matlab:%s ">%s</a>',callstr,unitStr);%,   %sprintf(''The %s property contains values (%s) in %i dimensions'', upper(curProp), obj.dataUnits{dProp}, length(obj.dataUnits{dProp}))">test</a>');
                else
                  unitTxts{i} = [' < ' unitStr ' >'];
                end
              else
                unitTxts{i} = '';
              end

            % -- Add Transient indicator to property string if applicable.
              if ~any(strcmp(props{i}, obj.dataProps))
                h = findprop(obj, props{i});
                if h.Transient 
                  valTxts{i} = [valTxts{i} ' [T] ' ];
                end
              end
          end

          sizeStr = [];
        else
          % Object is deleted, show deleted info and return from method.
          if showLinks
              display([ '  deleted '  Link1]);
              display([sprintf('\n  ') Link2 ', ' Link3 ', ' Link4 sprintf('\n')]);
          else
              display([ '  deleted '  class(obj)]);
          end
          return
        end

        % format the childObjects. This requires the object to be registered.
        if nFields
          %Register object if needed.
          if ~obj.treeNr; [obj, ~] = registerObjs(obj); end
          
          % Get values for linked properties.
          for i = 1: nFields
            n = sum(obj.linkIds(2,:) == uint32(i));
            cl = HDSManagedData(obj.treeNr).classes{obj.linkPropIds(1,i)};
            if ~obj.linkPropIds(2,i)
                lnkStr = ' [L]';
            else
                lnkStr = '';
            end

            valTxts{i+length(fieldn)} = sprintf(': [1x%i %s]%s',n, cl, lnkStr);
          end
        end

      else
        % Display array of objects.
        sizeStr = sprintf('%ix%i ',size(obj,1), size(obj,2));
        props   = fieldnames(obj);
        valTxts{1,length(props)} = [];
        unitTxts{1,length(props)} = [];
        isChanged = false;
      end

      % Create save indicator.
      if isChanged; chStr = ' *'; else chStr = ''; end

      % --- Actual printing to display ---
      
      % Display top links
      maxPropNameLength = max(cellfun(@length,props));
      if showLinks
        display([ '  ' sizeStr  Link1 ':' chStr sprintf('\n')]);
      else
        display([ '  ' sizeStr  class(obj) ':' chStr sprintf('\n')]);
      end

      % Display Properties
      for i=1:length(valTxts)
        pad = char(32*ones(1,(maxPropNameLength - length(props{i})  +2)));
        disp([ '   ' pad ' '  props{i} valTxts{i} unitTxts{i}]);
      end

      % Display methods
      if showLinks
        display([sprintf('\n  ') Link2 ', ' Link3 ', ' Link4 sprintf('\n')]);
      end
      
      % --- ---


    end
    function [fileIds, locId, bools, Mindex] = getobjlocation(obj)                  
      %GETOBJECTLOCATION  Returns HDS info about object.
      %   LocId output is defined as vector starting with the classId
      %   of the object.

      global HDSManagedData

      % Check input
      assert(length(obj) == 1, 'Cannot get location of multiple objects');

      % Get Info
      treeId = obj.treeNr;
      Mindex  = HDSManagedData(treeId).objIds(1, :) == obj.objIds(1);
      fileIds = HDSManagedData(treeId).objIds(:, Mindex);
      locId   = HDSManagedData(treeId).locArray(:, fileIds(4));
      bools   = HDSManagedData(treeId).objBools(:, Mindex);

      % Format LocId
      k = find(locId==0,1);
      if ~isempty(k)
        locId = locId(1:k-1);
      end

    end
    function m = methods(obj, arg)                                                  
      %METHODS  Shows all methods associated with the object.
      %   METHODS(OBJ) displays all methods of the object OBJ that
      %   are defined for the subclass OBJ. Methods belonging to the
      %   HDS Toolbox are not shown. Clicking on the methods link
      %   will display the full description on the method.
      %
      %   METHOD(OBJ,'-all') includes the HDS Toolbox methods and
      %   displays them as well as the class specific methods.

      dBMethods = {'addobj' 'remobj' 'addlink' 'remlink' 'addprop' 'remprop' 'getprop' ...
        'setprop' 'sortprop' 'lengthprop' 'sizeprop' 'isprop' 'propclass' 'properties'...
        'methods' 'childclasses' 'save' 'close' 'getpath' 'revertobj' 'propforclass' ...
        'renameprop' 'hdsdefrag' 'HDS.objchanged' 'setobjversion' 'subsref' 'subsasgn' ...
        'hdsexport' 'hdsupdate' 'hdsoption' 'showtree' ...
        };
      dBMethodStr = {...
        'Adds objects to the current object.'...
        'Removes objects from the current object.' ...
        'Adds links to the current object.'...
        'Removes links from the current object.' ...
        'Adds property to the current object.'...
        'Removes property from the current object.' ...
        'Returns the contents of a property of the object.',...
        'Sets the contents of a property in the object.',...
        'Sorts objects in a property of the object.'...
        'Returns length of a property without loading contents.',...
        'Returns size of a property without loading contents.'...
        'Indicates whether a property exists in object.',...
        'Returns the class-name of the data in a property.',...
        'Summary of properties of the object.' ...
        'Summary of the methods of the object.'...
        'Summary of the childclasses defined for the object'...
        'Saves the database associated with the object.'...
        'Removes object(s) from memory.' ...
        'Returns the path of the object on disk.'...
        'Resets the object to the last saved state.'...
        'Returns properties with objects of specified class.'...
        'Changes the name of a property.'...
        'Minimizes disk-space occupied by ''.nc'' files.'...
        'Signals the Toolbox that the object has changed.' ...
        'Updates the object version number.'...
        'Overloaded indexing method.'...
        'Overloaded assign method.'...
        'Copies part of the database to another location.'...
        'Updates search lookup tables for given data tree.'...
        'Sets certain properties for the database behavior.'...
        'Displays an interactive schematic of the database,',...
        };

      HDSMethods    = {'hdsload' 'hdscast' 'hdsmonitor' 'hdsrebuild' 'hdsinfo' 'hdscleanup'};
      HDSMethodsStr = {...
        'Loads and initializes an HDS-object.'...
        'Casts a structure or object as an HDS-object.'...
        'Monitor the memory usuage of the HDS toolbox.'...
        'Validate and check the integrity of the HDS filesystem.'...
        'Show info about current HDS objects in memory.'...
        'Cleanup memory occupied by HDS objects.'...
        };

      blockmethods = {'addlistener' 'delete' 'disp' 'eq' 'ge' 'ne' 'gt'  ...
        'le' 'lt' 'notify' 'isvalid' 'findobj' 'findprop' 'copy' 'asignhostinbase' ...
        'displaymessage' 'getClassId' 'getFileId' 'getLocFromPath' 'getobjlocation' ...
        'getPathFromLoc' 'linkTree2Disk' 'loadobj' 'registerObjs' 'findObjonDisk' ...
        'getTreeId' 'savehds' 'Contents' 'castHDSprops' 'hdsupdateobj' ...
        'subsref_getLinks' 'subsref_getData' 'subsref_getParent' ...
        };

      fncs = builtin('methods', obj);


      blockIdx = cellfun(@(x) any(strcmp(x, blockmethods)), fncs);
      fncs(blockIdx) = [];

      if nargin == 2
        assert(strcmp('-all',arg), 'METHODS: Incorrect input argument.');
        showHDS = true;
      elseif nargin == 1
        showHDS = false;
      else
        error('HDS:methods','METHODS: Incorrect number of input arguments.');
      end

      if nargout
        if ~showHDS
          blockIdx = cellfun(@(x) any(strcmp(x, dBMethods)), fncs);
          fncs(blockIdx) = [];
        end
        m = fncs;
        return;  
      else
        blockIdx = cellfun(@(x) any(strcmp(x, dBMethods)), fncs);
        fncs(blockIdx) = [];
      end

      % -- Get H1 lines  
      txts{1,length(fncs)} = [];
      for i=1:length(fncs)
        aux = help(sprintf('%s.%s',class(obj), fncs{i}));
        tmp = regexp(aux,'\n','split');
        tmp = regexp(tmp{1},'\s*[\w\d()\[\]\.]+\s+(.+)','tokens','once');
        if ~isempty(tmp)
          txts(i) = tmp;
        end
      end

      Link1 = sprintf('<a href="matlab:help(''%s'')">%s</a>',class(obj),class(obj));

      %Display Methods

      display([sprintf('\n') Link1 sprintf(' methods:\n')]);

      %The class specific methods
      [~,I] = sort(lower(fncs));
      fncs = fncs(I);
      txts = txts(I);

      %Define indenting steps for unusual long method names.
      STEP_SIZES = [20 30 40 50];
      SAMPLES_TOO_CLOSE = 2;
      L = cellfun('length', fncs);

      %Display methods sorted by the length of the method name and
      %then alphabetically. 
      for iSize = 1:length(STEP_SIZES)
        if iSize == length(STEP_SIZES)
          iUse = 1:length(txts);
        else
          iUse = find(L <= STEP_SIZES(iSize) - SAMPLES_TOO_CLOSE);
        end
        txtsUse = txts(iUse);
        fncsUse = fncs(iUse);
        LUse    = L(iUse);
        txts(iUse) = [];
        fncs(iUse) = [];
        L(iUse)    = [];
        for i=1:length(txtsUse)
          link = sprintf('<a href="matlab:help(''%s>%s'')">%s</a>',...
            class(obj),fncsUse{i},fncsUse{i});
          pad = char(32*ones(1,(STEP_SIZES(iSize)-LUse(i))));
          disp([ ' ' link pad txtsUse{i}]);
        end
      end

      if showHDS
        fprintf('\nHDS Toolbox methods:\n');
        for i = 1:length(dBMethods)
          method = dBMethods{i};
          link = sprintf('<a href="matlab:help(''%s>%s'')">%s</a>','HDS',method, method);
          pad = char(32*ones(1,(20-length(method))));
          disp([ ' ' link pad dBMethodStr{i}]);
        end
        fprintf('\n');

        for i = 1:length(HDSMethods)
          method = HDSMethods{i};
          link = sprintf('<a href="matlab:help(''%s'')">%s</a>',method, method);
          pad = char(32*ones(1,(20-length(method))));
          disp([ ' ' link pad HDSMethodsStr{i}]);
        end	
        fprintf('\n');
      else
        Link2 = sprintf('<a href="matlab:methods(%s,''-all'')">show more.</a>',class(obj));
        fprintf(['\n + ' Link2 '\n\n']);
      end
    end
    function p = properties(obj, varargin)                                          
      %PROPERTIES  Shows all properties of the object.
      %   P = PROPERTIES(OBJ) Returns a list of visible objects. If no output is defined, it
      %   displays the properties in the console and in addition, it shows some of the
      %   read-only properties of the RNEL_DB class.
      %
      %   PROPERTIES(OBJ,'-hds') displays all the visible
      %   properties of the object plus the readonly properties
      %   defined in the HDS class.

      if length(obj)==1
        if ~isempty(obj.linkProps)
          props = [fieldnames(obj); obj.linkProps'];
        else
          props = fieldnames(obj);
        end
      else
        props = fieldnames(obj);
      end

      hdsProps = {'parent' 'createDate' 'listAs' 'childClasses' 'parentClasses' 'dataProps' ...
          'metaProps' 'maskDisp' 'propsWithUnits' 'propUnits' 'propDims' 'strIndexProp'...
          'saveStatus' 'objVersion' 'classVersion' 'HDSClassVersion'  }; 
      hdsProps2 = {...
          'Returns the parent object.'...
          'Date of object initialization.' ...
          'String with default property name used to add objects of this class.' ...
          'StrCellarray indicating classes that can be used with ADDOBJ.'...
          'StrCellarray indicating classes that allow adding the current class with ADDOBJ.'...
          'StrCellarray indicating properties used for (non-meta) data .'...
          'StrCellarray indicating properties used for meta-data .'...
          'StrCellarray indicating properties that should not be evaluated during display'...
          'Cell array of strings with property names that contain values with units.'...
          'Cell array with strings indicating the units of the properties with units.'...
          'Cell array of cells with the names for the dimensions of the properties with units.'...
          'String indicating the property that is used for string-indexing'...
          'Indicates saving status (0:unchanged,1:obj changed,2:data changed, 3:obj updated).'...
          '[1x2] vector with the version of the current object.'...
          'Version number of the current class definition of the object.'...
          'Version number of the HDS Toolbox.'...
          };

      % Check input arguments
      if nargin > 1
        assert(strcmp(varargin{1},'-all'), 'PROPERTIES: Incorrect input argument.');  
        showHidden = true;
      else
        showHidden = false;
      end

      if nargout
        if showHidden
          p = [props ;hdsProps'];
        else
          p = props;
        end
        return;
      else
        %Remove hdsProps from props
        hdspropsInProps = cellfun(@(x) any(strcmp(x, hdsProps)),props);
        props(hdspropsInProps) = [];
        txts{1,length(props)} = [];
        for i=1:length(props)
          txts{i} = help([class(obj) '.' props{i}]);
        end

        Link1 = sprintf('<a href="matlab:help(''%s'')">%s</a>',class(obj),class(obj));

        %Display Methods
        display(sprintf('\n'))
        display([Link1 sprintf(' properties:\n')]);
        for i=1:length(txts)
        %Format ' [PropertyName] - [Contents of line following help]'
          h = regexp(txts{i},'-','split','once');
          pad = char(32*ones(1,(21-length(h{1}))));
          if length(h) > 1 && ~isempty(strtrim(h{2}))
            disp([h{1} pad strtrim(h{2})]);
          else
            try
              curProp = obj.(props{i});
              if isobject(curProp)
                pad = char(32*ones(1,(20-length(props{i}))));
                helpProp = help(sprintf('%s',class(obj.(props{i}))));
                helpProp = strtrim(regexp(helpProp,'  .*?\n','match','once'));
                disp([' ' props{i} pad helpProp]);
              else
                disp([' ' props{i}]);
              end
            catch ME %#ok<NASGU>
              disp([' ' props{i}]);
            end
          end
        end

        if showHidden
          fprintf('\nRead Only:\n'); 
          for i=1:length(hdsProps)
            pad = char(32*ones(1,(20-length(hdsProps{i}))));
            disp([' ' hdsProps{i} pad hdsProps2{i}]);
          end
          fprintf('\n');
        else
          Link2 = sprintf('<a href="matlab:properties(%s,''-all'')">show more.</a>',class(obj));
          fprintf(['\n + ' Link2 '\n']); 
          fprintf('\n');
        end

      end
    end
    function c = childclasses(obj)                                                  
      %CHILDCLASSES  Shows all objects that can be added to current object.
      %   CHILDCLASSES(OBJ) shows links to all objects that can be added to the
      %   object using the ADDOBJ method. These classes can be defined in the
      %   class definition of the object. Note that you should also specify the
      %   name of the current class in the 'parentClasses' constant of the class
      %   definition of the class you want to add. 

      if nargout
        c = obj(1).childClasses;
        return;
      end

      var = obj(1).childClasses;
      if ~isempty(var)
        txts{1,length(var)} = [];
        for i=1:length(var)
          aux = help(sprintf('%s',var{i}));
          aux = regexp(aux,'\n','split');
          txts{i} = aux{1}; 
          aux = strfind(txts{i},' ');
          if length(aux)>1; aux = aux(2); else aux=0; end;
          txts{i} = txts{i}((aux+1):end);
        end

        Link1 = sprintf('<a href="matlab:help(''%s'')">%s</a>', class(obj), class(obj));

        %Display Methods
        display([sprintf('\n') Link1 sprintf(' Childclasses:\n')]);
        for i=1:length(var)
          link = sprintf('<a href="matlab:help(''%s'')">%s</a>',var{i},var{i});
          pad = char(32*ones(1, (20-length(var{i}))));
          disp([' ' link pad txts{i}]);
        end
        fprintf('\n');
      else
        fprintf('\nObject has no Child classes defined.\n');
      end
    end
    function obj = castHDSprops(obj, oldobjs, oProps, nProps, option, mustMatch)    
      %CASTHDSPROPS  Populates standard HDS props in new obj.
      %   The method either transfers all properties or none. The
      %   output PROPS return the list of properties that are
      %   transferred.

      warningShown = false;
      for iObj = 1: length(obj)
        for iProp = 1: length(oProps)

          try
            obj(iObj).(nProps{iProp}) = oldobjs(iObj).(oProps{iProp});
          catch ME %#ok<NASGU>
            if any(strcmp(option, {'incl' 'inclP'}))
              h = findprop(obj(iObj),'orphanProps');
              if isempty(h)
                  addprop(obj(iObj),'orphanProps');
                  h = findprop(obj(iObj),'orphanProps');
              end
              if strcmp(option,'incl'); h.Transient = true; end

              obj(iObj).orphanProps.(oProps{iProp}) = oldobjs(iObj).(oProps{iProp});
            else
              if mustMatch && ~warningShown
                fprintf(2,'\nHDSCAST: Warning, could not populate target object correctly!\n');
                fprintf(2, 'Method was unable to write to property: %s of class %s.\n',upper(nProps{iProp}), upper(class(obj)));
                warningShown = true;
              end
            end
          end
          
        end
      end
    end
    function obj = setobjversion(obj, newVersion)                                   
      %SETOBJVERSION  Updates the object version number.
      %
      %   OBJ = SETOBJVERSION(OBJ, VERSION) sets the object version
      %   of the object(s) to VERSION. VERSION should be a single
      %   number. This method should normally be called from the user
      %   defined UPDATEOBJ method which changes the contents of the
      %   object during the loading process to conform with the new
      %   version number.
      %
      %   see also: HDS.UPDATEOBJ HDSCAST

      assert(isnumeric(newVersion) && length(newVersion)==1, ...
        'NewVersion input should be a single numeric.');

      if length(obj) == 1
        obj.objVersion(2) = newVersion;
      else
        for i = 1: length(obj)
          obj(i).objVersion(2) = newVersion;
        end
      end

    end
    function l = lengthprop(obj, propname)                                          
      %LENGTHPROP  Returns length of property without loading the data.
      %   L = LENGTHPROP(OBJ,'propName') returns the length of the
      %   property without loading the contents of the property in
      %   memory.
      %
      %   The builtin LENGTH method can be used to find the length of
      %   the contents of a property. However, as the contents are
      %   evaluated as an input to the length method, this will
      %   result in loading the contents of the property in memory.
      %   This overloaded method will return the length of the
      %   property contents without loading the contents of the
      %   propertie itself when they consist of other objects.
      %
      %   For multi-dimensional properties the length will be
      %   equivalent to MAX(SIZE(X)).
      %
      %   This method is most usefull for determining the number of
      %   objects in a property of an object. For meta-data the
      %   standard MATLAB syntax can be used.

      assert(nargin==2,'LENGTHPROP :  Incorrect input arguments.');

      aux   = strcmp(propname, obj.linkProps);
      aux2  = strcmp(propname, obj.dataProps);
      if any(aux)
        propId = find(aux,1);
        l = sum(obj.linkIds(2,:) == uint32(propId));
      elseif any(aux2)
        propId = find(aux2,1);
        sizeVec = double(obj.dPropSize(propId, 2:end));
        l = max(sizeVec);
      else
        l = builtin('length', obj.(propname));
      end

    end
    function s = sizeprop(obj, propname)                                            
      %SIZEPROP  Returns size of property without loading the data.
      %   S = SIZEPROP(OBJ,'propName') returns the size of the
      %   property without loading the contents from disk. 
      %
      %   This method is most usefull for determining the number of
      %   objects in a property of an object. For meta-data the
      %   standard MATLAB syntax can be used.

      assert(nargin==2,'SIZEPROP :  Incorrect input arguments.');

      aux   = strcmp(propname, obj.linkProps);
      aux2  = strcmp(propname, obj.dataProps);
      if any(aux)
        propId = find(aux,1);
        s = [1 sum(obj.linkIds(2,:) == uint32(propId))];
      elseif any(aux2)
        propId = find(aux2,1);
        sizeVec = double(obj.dPropSize(propId, 2:end));
        s = sizeVec(1:max([2 find(sizeVec,1,'last')]));
      else
        s = builtin('size', obj.(propname));
      end

    end
    function out = isprop(obj, propname)                                            
      %ISPROP  Indicates whether a property exist in object.
      %   OUT = ISPROP(OBJ,'propname') Returns a boolean indicating
      %   whether a property exists in the object. If OBJ is a single
      %   object, all dynamically added properties are included. If
      %   obj is an array of objects, only the static properties are
      %   included.

      props = properties(obj,'-all');
      if any(strcmp(propname, props));
        out = true;
      else
        out = false;
      end

    end
    
    function [obj, iS] = subsref_getLinks(obj, s, iS)                               
      % This function is called by the subsref function to get linked objects.
      global HDSManagedData
      
      sIsSubs = s(iS).subs;
      treeId  = obj.treeNr;

      options = hdsoption;

      % Register obj if not previously registered. 
      if ~treeId; [obj, treeId] = registerObjs(obj); end

      % Find current object in HDSManagedData, sanity check.
      objIdExists = any(HDSManagedData(treeId).objIds(1, :) == obj.objIds(1));
      assert( (treeId && objIdExists) || (~treeId && ~objIdExists), ...
        ['ERROR: Object has treeID and cannot be found in mem or '...
        'has no treeID but is present in mem.']);      

      % Get location of object with respect to the host object.
      HDSindex  = HDSManagedData(treeId).objIds(1, :) == obj.objIds(1);
      ids       = HDSManagedData(treeId).objIds(:, HDSindex);
      locId     = HDSManagedData(treeId).locArray(:, ids(4));

      k = find(locId == 0, 1);
      if ~isempty(k)
        locId = locId(1:k-1);
      end
      useTime = uint32((60*1440)*(datenummx(clock) - HDSManagedData(treeId).treeInitTime));
      HDSManagedData(treeId).objIds(5, HDSindex) = useTime;
      % --- ---

      propId  = find(strcmp(sIsSubs, obj.linkProps),1);
      classId = obj.linkPropIds(1, propId);
      getID   = obj.linkIds(:, obj.linkIds(2,:) == uint32(propId));

      strIndexing = false; % STRINDEXING is flag to select obj based on string later in method.
      if length(s) > iS
        nextIsType = s(iS+1).type;
        nextIsSubs = s(iS+1).subs;

        if strcmp(nextIsType, '()')
          if isnumeric(nextIsSubs{1}) && length(nextIsSubs) == 1
            objIdx = double(nextIsSubs{1});
            assert(max(objIdx) <= size(getID, 2), 'Index exceeds matrix dimension.');

          elseif islogical(nextIsSubs{1}) && length(nextIsSubs)==1
            objIdx = find(nextIsSubs{1});            
            assert(length(objIdx) <= size(getID, 2), 'Index exceeds matrix dimensions.');

          elseif ischar(nextIsSubs{1})
            % If indexed by string, load all objects and select afterwards.
            objIdx = 1: size(getID, 2);
            strIndexing = true;
          else
            error('HDS:subsref', 'Incorrect indexing of the %s property in the %s object.',...
              upper(sIsSubs), upper(class(obj)));
          end
          increaseIs = true;
        else
          objIdx      = 1: size(getID, 2);
          increaseIs  = false;
        end

      else
        objIdx = 1: size(getID,2);
        increaseIs = false;
      end  

      getLoc = getID(3, objIdx); % Locations for Links
      getID  = getID(1, objIdx); % Ids of objects  

      %Check data Struct for object: ix=0 when object not in memory.
      allObjForClass  = find(HDSManagedData(treeId).objIds(2,:) == classId);
      allObjs         = HDSManagedData(treeId).objIds(:, allObjForClass);
      ix              = ismembc2(getID, allObjs(1,:));

      % Check which indeces need to be loaded from disk.
      toBeLoaded = ix == 0;
      if any(toBeLoaded)

        % Find which objects belong to same file.
        loadIds = getID(toBeLoaded); 

        % Check if Link or Child object
        isChild = logical(obj.linkPropIds(2, propId));

        if isChild
          curLoc  = [locId(end:-1:1) ; ids(1) ; classId];
          nIter   = 1;
        else
          loadLocs    = getLoc(toBeLoaded);
          uniqueLocs  = unique(loadLocs); 
          nIter       = length(uniqueLocs);
        end

        for iLoc = 1: nIter
          if ~isChild
            loadIds2  = loadIds(loadLocs == uniqueLocs(iLoc));
            aux1      = find(obj.linkLocs(:, uniqueLocs(iLoc)), 1, 'last');
            curLoc    = [1 ; obj.linkLocs(aux1:-1:1, uniqueLocs(iLoc)) ; classId];
          else
            loadIds2  = loadIds;
          end

          curPath    = HDS.getPathFromLoc(curLoc, treeId);

          % DataNames is cell array with the names of the data variables in the data-file.
          dataNames = regexp(sprintf(sprintf('i%i\n', loadIds2)), '\n', 'split');
          dataNames = dataNames(1:end-1);

          % Set flag in loadobj to true, then load objects and reset flag.
          if ~isempty(dataNames)
            HDS.loadobj(obj, true);
            try
              warning('off','MATLAB:load:variableNotFound');
              if options.metaMode
                objs = load([curPath '.mat'], dataNames{:});
              else
                objs = load([curPath '.mat']);
              end
              warning('on','MATLAB:load:variableNotFound');
              % Create array of new objects.
              out = objs.(dataNames{1});
              out = out(ones(length(dataNames),1));
              for i = 2:length(dataNames)
                out(i) = objs.(dataNames{i}); 
              end

              registerObjs(out, treeId, curLoc(end:-1:1));
            catch %#ok<CTCH>
              % Some objects could not be loaded. Check if data names exist
              if exist([curPath '.mat'],'file')
                namesInFile = mex_whofile([curPath '.mat']);
                checkNames = false(length(dataNames),1);
                for i = 1: length(dataNames)
                  checkNames(i) = any(strcmp(dataNames{i},namesInFile));
                end
                if ~all(checkNames)
                  % Some variables are missing in file and will not be loaded.
                  HDS.displaymessage('-- -- -- -- -- --',2,'',''); 
                  HDS.displaymessage(['HDS Warning: One or more requested variables '...
                    'could not be loaded from disk.'],1,'',''); 
                  HDS.displaymessage('-- -- -- -- -- --',2,'','\n'); 
                  dataNames(~checkNames) = [];
                end
              else
                % File Missing
                HDS.displaymessage('-- -- -- -- -- --',2,'',''); 
                HDS.displaymessage(['HDS Warning: The file containing the requested variables '...
                  'is missing and one or more variable could not be loaded from disk.'],1,'',''); 
                HDS.displaymessage('-- -- -- -- -- --',2,'','\n'); 
                dataNames = [];
              end

              if ~isempty(dataNames)
                if options.metaMode
                  objs = load([curPath '.mat'], dataNames{:});
                else
                  objs = load([curPath '.mat']);
                end

                % Create array of new objects.
                out = objs.(dataNames{1});
                out = out(ones(length(dataNames),1));
                for i = 2:length(dataNames)
                    out(i) = objs.(dataNames{i}); 
                end

                registerObjs(out, treeId, curLoc(end:-1:1));
              end
            end
            HDS.loadobj(obj,false);

          end
        end                                            

        % Find objects again in HDSMANAGEDDATA
        allObjForClass = find(HDSManagedData(treeId).objIds(2,:) == classId);
        allObjs        = HDSManagedData(treeId).objIds(:,allObjForClass);                                            

        % ix is location in objIds for requested objects. If it does not exist at
        % this point the database is corrupted and warning is shown before.
        ix = ismembc2(getID, allObjs(1,:));
        ix(ix == 0) = [];
      end

      if ~isempty(ix)
        % Set 'touch'-time for requested objects
        useTime = uint32((60*1440)*(datenummx(clock) - HDSManagedData(treeId).treeInitTime));
        HDSManagedData(treeId).objIds(5, allObjForClass(ix)) = useTime;

        % Get all the requested objects from HDSMAnagedData
        aux2 = allObjs(:,ix);
        obj = HDSManagedData(treeId).(HDSManagedData(treeId).classes{classId})(aux2(3,:));

        % Get objIdx for strIndexing
        if strIndexing
          IndexProp = obj(1).strIndexProp;
          assert(~isempty(IndexProp), ['Objects of class %s cannot be indexed using a string;' ...
            'the STRINDEXPROP constant is not set.'],upper(class(obj)));

          obj = obj(strcmp(s(iS+1).subs{1}, {obj.(IndexProp)})); 

          assert(~isempty(obj),'No %s object exists where property %s has a value of ''%s''.', ...
            upper(class(obj)), upper(IndexProp), s(iS+1).subs{1});
        end
      else
          obj = [];
      end

      % Increasse Is by one if index was supplied in s(iS+1).
      if increaseIs; iS = iS+1; end;
    end
    function [obj, iS] = subsref_getParent(obj, ~, iS)                              
      global HDSManagedData

      % Register obj if not previously registered.
      treeId = obj.treeNr;
      if ~obj.treeNr; [obj, treeId] = registerObjs(obj); end

      % Find current object in HDSManagedData, sanity check.
      objIdExists = any(HDSManagedData(treeId).objIds(1, :) == obj.objIds(1));
      assert( (treeId && objIdExists) || (~treeId && ~objIdExists), ...
        ['ERROR: Object has treeID and cannot be found in mem or '...
        'has no treeID but is present in mem.']);
      % --- --- 

      % Get location of object with respect to the host object.
      HDSindex  = HDSManagedData(treeId).objIds(1, :) == obj.objIds(1);
      ids       = HDSManagedData(treeId).objIds(:, HDSindex);
      locId     = HDSManagedData(treeId).locArray(:, ids(4));

      k = find(locId == 0, 1);
      if ~isempty(k)
        locId = locId(1:k-1);
      end

      useTime = uint32((60*1440)*(datenummx(clock) - HDSManagedData(treeId).treeInitTime));
      HDSManagedData(treeId).objIds(5, HDSindex) = useTime;
      % --- ---      

      % If object is does not have parent because host object, throw error.
      if length(locId) == 2 && all(locId(1:2) == [1;1]);
        error('HDS:subsref', 'The %s object is host object of the dataTree and has no parent.', ...
          upper(class(obj)));
      end

      %Find class of parent
      classId = locId(3);

      % Check if object is in memory.
      index = find(obj.objIds(3) == HDSManagedData(treeId).objIds(1,:), 1);

      if isempty(index)
        % If you have to load the parent, you don't have to check for remobjs
        % because if the parent objects have been removed or sorted, they are by
        % definition loaded in memory and close does not work. 

        % Get path to file
        offset = 2*HDSManagedData(treeId).treeConst(4);
        curLoc = locId(end - offset: -1: 3);

        assert(~isempty(curLoc), ['The %s object is the topmost object in database although '...
          'it has a parent object. This means that the ''HDSconfig.mat'' file is moved to the '...
          'folder where the %s object is stored.'], upper(class(obj)) ,upper(class(obj)));

        curPath  = HDS.getPathFromLoc(curLoc, treeId);
        dataName = sprintf('i%i', locId(2));

        % Load the parent object
        HDS.loadobj(obj,true);
        parobj = load([curPath '.mat'], dataName);
        HDS.loadobj(obj,false);

        % Check parent objId 
        assert(parobj.(dataName).objIds(1) == obj.objIds(3), ...
          'Incorrect reference to parent while trying to load parent from disk.');

        % Register the parent object.
        registerObjs(parobj.(dataName), treeId, locId(3:end));

        % find index of parent object in HDSManagedData 
        index = find(obj.objIds(3) == HDSManagedData(treeId).objIds(1,:), 1);
      end

      objIdx = HDSManagedData(treeId).objIds(3, index);
      useTime = uint32((60*1440)*(datenummx(clock) - HDSManagedData(treeId).treeInitTime));
      HDSManagedData(treeId).objIds(5, index) = useTime;
      obj = HDSManagedData(treeId).(HDSManagedData(treeId).classes{classId})(objIdx);       
    end
    function [obj, iS] = subsref_getData(obj, s, iS)                                
      global HDSManagedData
      persistent lastSaveId lastLoc lastPath lastClass lastDataVec 
      

      % Init booleans if necessary.
      if isempty(lastSaveId)
        lastLoc     = 0;
        lastPath    = '';
        lastClass   = 0;
        lastDataVec = 0;
        lastSaveId  = 0;
      end

      sIsSubs = s(iS).subs;
      treeId  = obj.treeNr;
      
      % Register obj if not previously registered. 
      if ~obj.treeNr; [obj, treeId] = registerObjs(obj); end
      
      % Get location of object with respect to the host object.
      HDSindex  = HDSManagedData(treeId).objIds(1, :) == obj.objIds(1);
      ids       = HDSManagedData(treeId).objIds(:, HDSindex);
      locId     = HDSManagedData(treeId).locArray(:, ids(4));

      k = find(locId == 0, 1);
      if ~isempty(k)
        locId = locId(1:k-1);
      end

      useTime = uint32((60*1440)*(datenummx(clock) - HDSManagedData(treeId).treeInitTime));
      HDSManagedData(treeId).objIds(5, HDSindex) = useTime;
      % --- ---

      % Get data Option: 1)default 2)from disk
      curOptions  = hdsoption;
      dataOption  = curOptions.dataMode;
      propId      = find(strcmp(sIsSubs, obj.dataProps),1);

      % Get StrideMatrix if subindex provided.
      if length(s) > iS               

        if strcmp(s(iS+1).type,'()')
          subIndexData = true;

          % Get property size
          sizeVec     = double(obj.dPropSize(propId, 2:end));
          curPropSize = sizeVec(1 : find(sizeVec,1,'last')); 

          % Check the number of dimensons that are indexed.
          lSubs = length(s(iS+1).subs);
          assert(lSubs <= length(curPropSize), 'Index exceeds matrix dimensions.');

          strideMatrix = zeros(length(curPropSize),2);

          % - Get the stride matrix if we are sub indexing. If single dimension indexing,
          %   find the largest dimension and index there.
          if lSubs == 1
            % Check if we are using linear indexing
            assert(length(find(curPropSize >1)) <= 1, 'Linear indexing of multidimensional data property currently not allowed.');

            if isnumeric(s(iS+1).subs{1})
              % find largest dimension
              [~, largestDim] = max(curPropSize);
              minI = min(s(iS+1).subs{1});
              maxI = max(s(iS+1).subs{1});

              % Create stride matrix
              getAllData = true;
              for i = 1:size(strideMatrix,1)
                if i == largestDim
                  strideMatrix(i,1) = minI-1;
                  strideMatrix(i,2) = maxI - strideMatrix(i,1);
                  getAllData = getAllData && minI == 1 && maxI == curPropSize(largestDim);
                else
                  strideMatrix(i,1) = 0;
                  strideMatrix(i,2) = 1;
                end
              end


            elseif strcmp(s(iS+1).subs{1},':')
              % You want all data, don't subIndex
              subIndexData = false;
              strideMatrix = [];
              getAllData = true;
            else
              throwAsCaller(MException('HDS:subsref',sprintf('Incorrect indexing of the %s property in the %s object.',upper(sIsSubs), upper(class(obj)))));
            end

          else
            getAllData = true;
            for i = 1: lSubs

              if isnumeric(s(iS+1).subs{i})

                minI = min(s(iS+1).subs{i});
                maxI = max(s(iS+1).subs{i});

                assert(minI > 0 || maxI <= curPropSize(i), 'Index exceeds matrix dimensions.');

                strideMatrix(i,1) = min(s(iS+1).subs{i})-1;
                strideMatrix(i,2) = max(s(iS+1).subs{i}) - strideMatrix(i,1);

                getAllData = getAllData && minI == 1 && maxI == curPropSize(i);


              elseif strcmp(s(iS+1).subs{i},':')
                strideMatrix(i,1) = 0;
                strideMatrix(i,2) = curPropSize(i);
              else
                throwAsCaller(MException('HDS:subsref',sprintf('Incorrect indexing of the %s property in the %s object.',upper(sIsSubs), upper(class(obj)))));
              end 
            end
          end

          increaseIs = true;
        elseif strcmp(s(iS+1).type,'.')
          error('HDS:SUBSREF','Attempt to reference field of non-structure array.');
        elseif strcmp(s(iS+1).type,'{}')
          error('HDS:SUBSREF','Cell contents reference from a non-cell array object.');
        end
      else %length(s) == iS
        subIndexData  = false;
        increaseIs    = false;
        strideMatrix  = [];
        getAllData    = true;
      end 



      % Alter dataOption depending on special scenarios.
      if ~isempty(obj.dataInMem)
        if obj.dataInMem(propId,1) > uint32(1) 
          dataOption = 3;
        elseif obj.dPropSize(propId, 2) == uint32(0)
          dataOption = 4;
        end
      elseif obj.dPropSize(propId, 2) == uint32(0)
        dataOption = 4;
      end


      if any(dataOption == [1 2]);
        % DataOption is 1 or 2

        curLoc = locId(end:-1:1);

        maxL        = max([length(curLoc) length(lastLoc)]);
        sameLoc     = all([curLoc ;zeros(maxL-length(curLoc),1)] == ...
          [lastLoc ;zeros(maxL-length(lastLoc),1)]);
        sameSaveID  = sum(HDSManagedData(treeId).treeConst([1 2])) == lastSaveId;
        getLastPath = sameLoc && sameSaveID;
        getLastVec  = getLastPath && lastClass == ids(2);

        % - Get Path to file  
        if getLastPath
          curPath = lastPath;
        else
          curPath = HDS.getPathFromLoc(curLoc, treeId) ;

          lastLoc     = curLoc;
          lastPath    = curPath;
          lastSaveId  = sum(HDSManagedData(treeId).treeConst([1 2]));
        end

        % - Only get DataVec when not already loaded.
        if getLastVec
          fileIDVec = lastDataVec;
        else
          dataFileName = [curPath '.nc'];

%           assert(exist(dataFileName, 'file'), 'Data File Not Found.');
          ncid = netcdf.open(dataFileName, 0); % Open file for read-only

          % - Get the fileIDVec which determines which subfile contains which indeces.
          varid = netcdf.inqVarID(ncid, 'chIndexVec');
          fileIDVec = netcdf.getVar(ncid, varid);
          netcdf.close(ncid);

          lastClass   = ids(2);
          lastDataVec = fileIDVec;
          lastSaveId  = HDSManagedData(treeId).treeConst(2);
        end 
      end

      % Retrieve data via different methods depending on the value of dataOption.
      switch dataOption               
        case 1 % Get and store in obj          

          propSize = double(obj.dPropSize(propId,2:end));
          propSize = propSize(1: find(propSize,1,'last'));

          % Depending on the loadLimit, define the subset of data or
          % indicate that all data should be loaded.
          if prod(propSize) > curOptions.loadLimit

            % Check if dataInMem falls within range of previously loaded data.
            if size(obj.dataInMem, 1) < uint32(propId)
                obj.dataInMem(propId, 1: (1+length(propSize)*2)) = zeros(1, (1+length(propSize)*2), 'uint32');
            end

            curInMem = double(obj.dataInMem(propId, 2:(1+2*length(propSize))));

            % If subIndexData then figure out if all data is already in memory (inMem=true)
            if obj.dataInMem(propId,1) == uint32(2)
              inMem = true;

            elseif subIndexData

              inMem = true;
              for i = 1: size(strideMatrix,1)
                  inMem = inMem && curInMem((i*2)-1)<=(strideMatrix(i,1)+1) && curInMem((i*2)) >= (strideMatrix(i,1) +strideMatrix(i,2));
              end

              if inMem
                if lSubs ==1
                  s(iS+1).subs{1} = s(iS+1).subs{1} - curInMem((largestDim*2)-1)+1;
                else
                  for i = 1: length(s(iS+1).subs)
                    if ~ischar(s(iS+1).subs{i}) % Only if index is not (:)
                      s(iS+1).subs{i} = s(iS+1).subs{i} - curInMem((i*2)-1) + 1;
                    end
                  end
                end
              else
                if lSubs ==1
                  s(iS+1).subs{1} = s(iS+1).subs{1} - strideMatrix(largestDim,1);
                else
                  for i = 1: length(s(iS+1).subs)
                    if ~ischar(s(iS+1).subs{i}) % Only if index is not (:)
                      s(iS+1).subs{i} = s(iS+1).subs{i} - strideMatrix(i,1);
                    end
                  end   
                end
              end

            else
              inMem = false;
            end

          else
            % Check if dataInMem falls within range of previously loaded data.
            if size(obj.dataInMem,1) < propId
              obj.dataInMem(propId, 1: (1+length(propSize)*2)) = zeros(1, (1+length(propSize)*2),'uint32');
            end

            if obj.dataInMem(propId,1) == uint32(2)
              inMem = true;
            else
              inMem = false;
            end

            getAllData = true;
          end

          % If not all data is in mem, load the requested data.
          if ~inMem               

            % - Open the subNC file containing the data.
            IDVecIndex = find(ids(1) == fileIDVec(:,1), 1);
            assert(~isempty(IDVecIndex), 'Unable to figure out which file contains the data.');

            if fileIDVec(IDVecIndex, 2) == 1
              ncid = netcdf.open([curPath '.nc'], 0); % Open file for read-only
            else
              fileName = [curPath sprintf('.%03d',fileIDVec(IDVecIndex,2))];
              try
                ncid = netcdf.open(fileName, 0); % Open file for read-only
              catch ME
                throwAsCaller(MException('HDS:SUBSREF','HDS: Unable to open data file, this should never happen...'));
              end
            end

            dataName = sprintf('%s_%i', sIsSubs, ids(1) );
            varid    = netcdf.inqVarID(ncid, dataName);

            if getAllData
              obj.(sIsSubs) = netcdf.getVar(ncid, varid);

              ps = size(obj.(sIsSubs));
              memVec = [ones(1,length(ps)) ; ps];
              memVec = memVec(1:end);
              obj.dataInMem(propId, 1 :(1+length(memVec))) = uint32([2 memVec]);
            else
              obj.(sIsSubs) = netcdf.getVar(ncid, varid, strideMatrix(:,1), strideMatrix(:,2) );

              memVec = strideMatrix';
              memVec(2,:) = memVec(1,:) + memVec(2,:);
              memVec(1,:) = memVec(1,:) + 1;
              memVec = memVec(1:end);
              obj.dataInMem(propId, 1 :(1+length(memVec))) = uint32([1 memVec]);
            end          

            % Close the NC. file.
            netcdf.close(ncid);

            warning('OFF','MATLAB:structOnObject');
            aux = struct(obj); %#ok<NASGU>
            objSize = whos('aux');
            objSize = objSize.bytes;
            warning('ON','MATLAB:structOnObject');

            HDSManagedData(treeId).objIds(6, HDSindex)   = uint32(objSize);
            HDSManagedData(treeId).objBools(4, HDSindex) = true;
          end

          % If subIndexing, get data from object
          if subIndexData
            obj = builtin('subsref',obj.(sIsSubs), s(iS+1));
          else
            obj = obj.(sIsSubs);
          end                                                
        case 2 % Get directly from disk        
          % Only requested data is loaded. Data is not stored in object.

          IDVecIndex = find(ids(1) == fileIDVec(:,1), 1);
          assert(~isempty(IDVecIndex), 'Unable to figure out which file contains the data.');

          if fileIDVec(IDVecIndex, 2) == 1
            ncid = netcdf.open([curPath '.nc'], 0); % Open file for read-only
          else
            fileName = [curPath sprintf('.%03d',fileIDVec(IDVecIndex,2))];
            try
              ncid = netcdf.open(fileName, 0); % Open file for read-only
            catch ME
              throwAsCaller(MException('HDS:SUBSREF','HDS: Unable to open data file, this should never happen...'));
            end
          end


          dataName = sprintf('%s_%i', sIsSubs, ids(1) );
          varid    = netcdf.inqVarID(ncid, dataName);

          if ~subIndexData
            % Get all data in variable
            obj = netcdf.getVar(ncid, varid);
          else
            % Get subset of data in variable
            obj = netcdf.getVar(ncid, varid, strideMatrix(:,1), strideMatrix(:,2) );

            if lSubs ==1
              s(iS+1).subs{1} = s(iS+1).subs{1} - strideMatrix(largestDim,1); 
            else
              for i = 1: length(s(iS+1).subs)
                if ~ischar(s(iS+1).subs{i}) % Only if index is not (:)
                  s(iS+1).subs{i} = s(iS+1).subs{i} - strideMatrix(i,1);
                end
              end     
            end

            obj = builtin('subsref',obj, s(iS+1));
          end

          netcdf.close(ncid);      
        case 3 % Get from object               
          % Data is in object and dataOption 2
          obj = builtin('subsref',obj, s(iS:end));
        case 4 % Object empty                  
          % Property is empty
          obj = [];
      end

      if increaseIs; iS = iS+1; end;
    end

    obj = revertobj(obj)
    obj = save(obj, varargin)
    obj = addobj(obj, addClassName, varargin)
    obj = remobj(obj, className, varargin)
    obj = addlink(obj, propName, linkObjs)
    obj = remlink(obj, propName, varargin)
    obj = addprop(obj, propName, varargin)
    obj = remprop(obj, propName)
    classStr = propclass(obj, propname)
    obj = sortprop(obj, propName, sortOption, varargin)
    obj = renameprop(obj, oldName, newName)
    varargout = hdsdefrag(obj)
    [path, index] = getpath(obj)
    varargout = close(obj, varargin)
    prop = propforclass(obj, className, includeLinks)
    hdsexport(obj, varargin)
    hdsupdate(obj, varargin)
    hdsupdateobj(obj)
  end
    
  methods (Sealed, Hidden)
    function obj = cleardataprops(obj, HDSIndex)                                    
      %CLEARDATAPROPS  Removes unchanged data from memory
      %   OBJ = CLEARDATAPROPS(OBJ) removes the dataproperties from
      %   memory. This is a private function that should only be used
      %   internally by the HDS Toolbox. Specifically by the
      %   HDSCLEANUP method.

      global HDSManagedData

      treeId = obj.treeNr;
      for iProp = 1: length(obj.dataProps)
          obj.(obj.dataProps{iProp}) = [];
      end
      obj.dataInMem = zeros(length(obj.dataProps), 1+2*(size(obj.dPropSize,2)-1), 'uint32');

      warning('OFF','MATLAB:structOnObject');
      aux = struct(obj); %#ok<NASGU>
      aux2 = whos('aux');
      HDSManagedData(treeId).objIds(6, HDSIndex)    = uint32(aux2.bytes);
      HDSManagedData(treeId).objBools(4, HDSIndex)  = false; % set dataprop to unloaded.
      warning('ON','MATLAB:structOnObject');

    end
  end
    
  methods (Sealed, Static, Hidden)
    function out = struct2bin(binstruct)                                            
      
      % Find length
      binLength = 5 + binstruct.initParams(4) + 3 * binstruct.nrParents + sum(binstruct.nrChildPP);
      out = zeros(binLength,1,'uint32');
      
      out(1:4) = binstruct.initParams;
      
      writeStart = 5;
      writeEnd = writeStart + binstruct.initParams(4) -1;
      out(writeStart : writeEnd) = binstruct.link;

      out(writeEnd + 1) = binstruct.nrParents;
      
      writeStart = writeEnd +2;
      writeEnd = writeStart + binstruct.nrParents -1;
      out(writeStart : writeEnd) = binstruct.parentIds;
      
      writeStart = writeEnd +1;
      writeEnd = writeStart + binstruct.nrParents -1;
      out(writeStart : writeEnd) = binstruct.updateBools;
      
      writeStart = writeEnd +1;
      writeEnd = writeStart + binstruct.nrParents -1;
      out(writeStart : writeEnd) = binstruct.nrChildPP;
      
      writeStart = writeEnd +1;
      for i = 1: binstruct.nrParents
        writeEnd = writeStart + binstruct.nrChildPP(i) -1;
        out(writeStart : writeEnd) = binstruct.childIDs(1: binstruct.nrChildPP(i),i);
        writeStart = writeEnd + 1;
      end
      
      assert(writeEnd == length(out), 'Incorrect parsing of binary file.');

    end
    function out = bin2struct(binVector)                                            
      % This function parses the binary vector and returns an easy to understand structure.
      
      out = struct(...
        'initParams',[],...
        'link',[],...
        'nrParents',[],...
        'parentIds',[],...
        'updateBools',[],...
        'nrChildPP',[],...
        'childIDs',[]);
      
      out.initParams = binVector(1:4);
      
      llink = binVector(4);
      startlim = 5;
      readlim = 4 + llink;
      out.link = binVector(startlim : readlim);
      
      nrparents = binVector(readlim+1);
      out.nrParents = nrparents;
      
      startlim = readlim + 2;
      readlim = startlim + nrparents -1;
      out.parentIds = binVector(startlim : readlim);
      
      startlim = readlim + 1;
      readlim = startlim + nrparents -1;
      out.updateBools = binVector(startlim : readlim);
      
      startlim = readlim +1;
      readlim = startlim + nrparents -1;
      out.nrChildPP = binVector(startlim : readlim);
      
      out.childIDs = zeros(max(out.nrChildPP),nrparents, 'uint32');
      startlim = readlim + 1;
      for i = 1: nrparents
        readlim = startlim + out.nrChildPP(i) -1;
        out.childIDs(1: out.nrChildPP(i),i) = binVector(startlim : readlim);
        startlim = readlim + 1;
      end
      
      assert(readlim == length(binVector), 'Incorrect parsing of binary file.');

    end
    function objs = getObjFromLoc(locArray, treeIx)                                 
      % CURRENLTY NOT WORKING!! ONLY USED BY HDSFIND

      % GETOBJFROMLOC  Returns objects given a loc vector.
      % This method is used by the query system. The locArray is a
      % cell-array where each cell is a vector starting with the
      % classId of the host (1) and ends with the object-id of the
      % requested object.

      global HDSManagedData

      % Check that all requested objects belong to same class.
      chk = zeros(length(locArray),1);
      for i = 1:length(locArray)
          chk(i) = locArray{i}(end-1);
      end
      
      assert(all(chk == chk(1)), 'Not all requested objects belong to same class.');
      returnId = chk(1);

      assert(length(HDSManagedData) >= treeIx, 'The specified tree index is not assigned.');

      % Initialize the returned objects array.
      returnClassStr = HDSManagedData(treeIx).classes{returnId};
      hdspreventreg(true);
      objs = eval(returnClassStr);
      hdspreventreg(false);
      objs = objs(ones(length(locArray),1));

      tobeassigned = true(length(locArray),1);

      for iLoc = 1: length(locArray)
        % Check if object is previously loaded.
        manIndex = find(HDSManagedData(treeIx).objIds(1,:) == locArray{iLoc}(end),1);

        if ~isempty(manIndex)
          % Load object from memory
          ix = HDSManagedData(treeIx).objIds(3,manIndex);
          objs(iLoc) = HDSManagedData(treeIx).(returnClassStr)(ix);
          tobeassigned(iLoc) = false;
        end
      end

      % The chksum is used to find the same folders. The only way
      % that the sum of the vector is the same is if the folder is
      % equal.
      chksum = zeros(length(locArray),1);
      for i = 1:length(locArray)
        chksum(i) = sum(locArray{i}(1:end-1));
      end

      while any(tobeassigned)
        index = find(tobeassigned, 1);
        loadTogether = find(chksum == chksum(index) & tobeassigned); 

        loadids = cellfun(@(x) x(end),locArray(loadTogether));
        locid = locArray{index}(1:end-2);

        [path, locid] = HDS.getPathFromLoc(locid', treeIx);
        curPath = fullfile(path, sprintf('%s_%i.mat',returnClassStr,locid(end)));

        % Get indeces from binary file.
        fid     = fopen(fullfile(path,sprintf('%s.bin',returnClassStr)),'r');
        data    = fread(fid, 'uint32');
        fclose(fid);        
        
        % Now find the next folder name --> Find index in parent.
        np      = data(u4 + data(3));       % Number of parent objects.
        iOffset = 4 + data(3) + 2*np;      % offset after which IDs start

        if locid(end)==1
          pOffset = 0;
        else
          pOffset = sum(data(4 + data(3) + np: 4 + data(3) + np + locid(end) -1));
        end

        searchVector = data( (iOffset+pOffset+1) : (iOffset+pOffset+data(4 + data(3) + np + locid(end))));

        if length(loadids)>1
          [sortSearchVector, location] = sort(searchVector);
          indeces = ismembc2(loadids, sortSearchVector);
          loadidx = location(indeces)';
        else
          loadidx = find(searchVector == loadids(1),1);
        end

        % DataNames is cell array with the names of the data variables in the data-file.
        dataNames = regexp(sprintf(sprintf('i%i\n', loadidx)), '\n', 'split');
        dataNames = dataNames(1:end-1);

        % Set flag in loadobj to true, then load objects and reset flag.
        HDS.loadobj(objs,true);
        out = load(curPath, dataNames{:});
        HDS.loadobj(objs,false);

        % Create array of new objects.

        for i = 1:length(loadids)
          objs(loadTogether(i)) = out.(dataNames{i}); 
        end

        registerObjs(objs(loadTogether), treeIx, [returnId ; locid(end:-1:1)]);

        tobeassigned(loadTogether) = false;                
      end 

    end
    function path = getPathFromLoc(curLoc, treeId)                                  
      %GETPATHFROMLOC returns folder to object from location vector

      global HDSManagedData

      path = HDSManagedData(treeId).basePath;
      if ~isempty(curLoc) % curLoc is empty for basePath
        if HDSManagedData(treeId).treeConst(4) == 0
          path = fullfile(path, sprintf('%s', ...
          HDSManagedData(treeId).classes{curLoc(2)}));
        else
          path = fullfile(path,sprintf('%s_%i', ...
            HDSManagedData(treeId).classes{curLoc(2)}, curLoc(1)));
        end

        for ii = 3 : 2: length(curLoc)
          path = fullfile(path,sprintf('%s_%i', ...
            HDSManagedData(treeId).classes{curLoc(ii+1)}, curLoc(ii)));
        end
      end

    end
    function locId = getLocFromPath(path, depth, treeIx)                            
      %GETLOCFROMPATH return the locID minus the object index from a given path.
      %

      % Path is a string containing the path of the object.

      global HDSManagedData

      if depth == 0 
        locId = [1;1];
      else
        locId = zeros(2*depth+2,1) ;
        for i = 1: 2: (depth-1)*2 +1
          [path, name, ~] = fileparts(path);
          aux = regexp(name,'_','split');
          if length(aux) == 1
            locId(i) = find(strcmp(aux{1}, HDSManagedData(treeIx).classes),1);
          else
            locId(i:i+1) = [find(strcmp(aux{1}, HDSManagedData(treeIx).classes),1); str2double(aux{2})];
          end
        end
        if HDSManagedData(treeIx).treeConst(4) == 0
          locId(i+2:i+3) = [1;1];
        end
      end
    end
    function [classId,new] = getClassId(className, treeId)                          
      %GETCLASSID Returns the ID of the requested classname
      %   CLASSID = GETCLASSID('className', TREEIX) returns the ID
      %   for a given 'className' in TREEIX. 
      %
      %   The method assumes that the HDSConfig file has been loaded
      %   at the time that the method is called.

      global HDSManagedData

      try
        % Define Class and ClassID for objects to be registerd.
        classId = find(strcmp(className, HDSManagedData(treeId).classes), 1);
        new     = false;

        % Check if 1) The class exists in the 'classes' field and 2) if
        % the a fieldname exists for this type of class.

        if isempty(classId)
          % Add class name
          classId = find(cellfun('isempty', HDSManagedData(treeId).classes),1);
          if isempty(classId)
            classId = length(HDSManagedData(treeId).classes) + 1;
            HDSManagedData(treeId).classes = [HDSManagedData(treeId).classes ; cell(10,1)];
          end
          HDSManagedData(treeId).classes{classId} = className;
          new = true;
        elseif ~any(strcmp(className, fieldnames(HDSManagedData(treeId))))
          % Class has an id but field does not exist. Occurs after
          % loading HDSconfig.mat file.
          new = true;
        elseif isempty(HDSManagedData(treeId).(className))
          % Class has an Id but no property yet; add field to struct.
          new = true;
        end
        
        if new
          % Expand objIds and objBools
          HDSManagedData(treeId).objIds   = [HDSManagedData(treeId).objIds zeros(6,1,'uint32')];
          HDSManagedData(treeId).objBools = [HDSManagedData(treeId).objBools false(4,1)];
          
          % Add field to struct.
          hdspreventreg(true);
          HDSManagedData(treeId).(className) = eval(className); 
          hdspreventreg(false);
        end
        
      catch ME
        hdspreventreg(false);
        throwAsCaller(ME);
      end
    end
    function [fileId, new] = getFileId(locId, treeId)                               
      % GETFILEID Returns the fileID for the object. Is empty when no
      % fileId exists. LocId should be locId from single object.

      % Technical note:
      % GETFILEID is only called by REGISTEROBJS and takes care of
      % assigning a fileID to the, tobe, registered objects. 

      global HDSManagedData

      % Check if the NEWFILELOC already exists and place NEWFILELOC in HDSMANAGEDDATA.LOCARRAY.
      sizeLocArray = size(HDSManagedData(treeId).locArray);

      % Pad locId with zeros to match length locArray
      locId = [locId ; zeros(sizeLocArray(1) - length(locId),1,'uint32') ];

      if length(locId) > sizeLocArray(1)
        match = false;
      else
        matchedFileLoc = double(locId(:,ones(sizeLocArray(2),1)));
        match = ~any(double(HDSManagedData(treeId).locArray) - matchedFileLoc, 1);
      end

      if any(match)
        fileId = find(match,1);
        new = false;
      else
        % Grow number of rows in locArray if necessary            
        if sizeLocArray(1) < length(locId)
          padding = zeros(10, sizeLocArray(2),'uint32');
          HDSManagedData(treeId).locArray = [HDSManagedData(treeId).locArray ; padding];
          sizeLocArray(1) = sizeLocArray(1) + 10;
        end

        % Grow number of colums in locArray if necessary
        fileId = find(HDSManagedData(treeId).locArray(1,:) == 0, 1);
        if isempty(fileId) 
          fileId = sizeLocArray(2) + 1;
          padding = zeros(sizeLocArray(1), 100,'uint32');
          HDSManagedData(treeId).locArray = [HDSManagedData(treeId).locArray padding];
          sizeLocArray(2) = sizeLocArray(2) + 100;
        end

        % Resize the locId again to match new size locArray and add to locArray.
        locId = [locId ; zeros( sizeLocArray(1) - length(locId),1,'uint32') ];
        HDSManagedData(treeId).locArray(:, fileId) = locId;
        new = true;
      end
    end
    function [treeId, new] = getTreeId(hostId)                                      
      %GETTREE  Returns the treeId for a specified hostId
      %   TREEID = GETTREEID(HOSTID) returns the TREEID that is
      %   associated with the specified HOSTID. If no tree is
      %   associated with the hostID, the method will create a new
      %   entry in HDSManagedData for this HOSTID.

      global HDSManagedData

      if isempty(HDSManagedData)
        % This runs if the HDSManagedData is called for the first time.

        % objIds = [objId classId classIx FileId FileIdx TimeStamp]
        saveId = 1;

        HDSManagedData = struct(...
          'basePath' ,'', ...
          'treeConst',uint32([hostId saveId 0 0]), ...
          'treeInitTime',datenummx(clock),...
          'isSaving',false, ...
          'objIds',zeros(6, 0,'uint32'), ...
          'objBools',false(4,0), ...
          'locArray', zeros(4,2,'uint32'), ...
          'classes',[], ...
          'remIds',zeros(2,0,'uint32'));
        
        HDSManagedData.classes = cell(100,1);
        treeId  = 1;
        new     = true;

        % Display copyright info once per Matlab session.
        hdscopyright('init');
      else
        % Check if there is already an entry for the hostID.

        hostIDS = [HDSManagedData.treeConst];
        hostIDS = hostIDS(1:4:end);
        treeId  = find(hostId == hostIDS, 1);
        new = false;

        % Only add an entry in the HDSManagedData struct if object
        % host is not managed, add a entry in repository.
        if isempty(treeId)
          names = fieldnames(HDSManagedData);
          names = [names' ; cell(1,length(names))];
          treeId = length(HDSManagedData)+1;
          saveId = 1;
          HDSManagedData(treeId)            = struct(names{:});
          HDSManagedData(treeId).basePath   = '';
          HDSManagedData(treeId).treeConst  = uint32([hostId saveId 0 0]);
          HDSManagedData(treeId).treeInitTime = datenummx(clock);
          HDSManagedData(treeId).isSaving   = false;
          HDSManagedData(treeId).classes    = cell(100,1);
          HDSManagedData(treeId).objIds     = zeros(6,2,'uint32');
          HDSManagedData(treeId).objBools   = false(4,2);
          HDSManagedData(treeId).locArray   = zeros(4,2,'uint32');
          HDSManagedData(treeId).remIds     = zeros(2,0,'uint32');

          new = true;
        end
      end
    end
    function linkTree2Disk(treeId, path, pathDepth)                                 
      %LINKMANAGEDDATA2DISK  Links the HDSManagedData entry to the saved files.
      %   LINKMANAGEDDATA2DISK(TREEIX) Asks the user to specify the
      %   'config.mat' file for TREEIX. It then sets the path in
      %   TREEIX and determines the baseOffset.
      %
      %   LINKMANAGEDDATA2DISK(TREEIX, 'path', LOCID) is called by
      %   HSDLOAD when the path is already known. Based on the 'path'
      %   and the LOCID, the baseOffset is determined.
      %
      %   This method sets the 'classes', 'baseOffset', and
      %   'basePath' properties in HDSManagedData.

      global HDSManagedData

      % Check if treeId exists
      assert(treeId <= length(HDSManagedData) && treeId > 0, 'Incorrect TREEID : %i', treeId);
      assert(nargin == 1 || nargin ==3, 'LINKTREE2DISK: Incorrect number of inputs.');

      % If number of arguments is 1 then ask user to specify the
      % location of the file, otherwise use the supplied path.
      if nargin == 3
        % Strip Path to root
        if ~exist(fullfile(path, 'HDSconfig.mat'),'file');
          for i = 1 : pathDepth
            path = fileparts(path);
            isRoot = exist(fullfile(path,'HDSconfig.mat'),'file');
            if isRoot; break; end;
          end
        else
          isRoot = true;
        end         

        assert(isRoot, ['Unable to find the root folder and the associated ''HDSconfig.mat'' '...
          'file. Please use the HDSREBUILD method to create this file.']);

        s = load(fullfile(path,'HDSconfig.mat'));
      else
        % Display message in console.
        text = ['To correctly load the requested data, the HDS toolbox needs information from '...
          'the ''HDSconfig.mat'' file. This file is located in the folder of the top level '...
          'object of the data-tree that you are currently using. The HDS toolbox can '...
          'automatically locate this file when the function ''HDSLoad'' is used to load '...
          'one of the objects into memory. Please locate the file manually in the opened '...
          'dialog window.'];
        HDS.displaymessage(text, 2);

        % Get the file.
        [filename, path, ~] = uigetfile('','Specify location of the ''HDSConfig.mat'' file.');
        [path, ~, ~] = fileparts( fullfile(path, filename) ); %To fix Matlab trailing '/' bug.

        % Return when ui is cancelled
        assert(~isempty(path),'HDS:LoadCanceled','Load operation cancelled'); 

        % Check if the filename is correct.
        assert(strcmp(filename, 'HDSconfig.mat'), 'User selected the incorrect file.'); 

        % Load the file.
        s = load(fullfile(path,filename));
      end

      % Check contents of file.
      n = fieldnames(s);
      assert(any(strcmp('classes',n)) && any(strcmp('hostId',n)), ...
        ['The ''HDSConfig.mat'' file should contain the variables ''classes'' and ''hostId''.'...
        'Somehow this is not the case and therefore the file is corrupt.']);

      % Check if HDSConfig.mat belongs to this treeId.
      assert(s.hostId == HDSManagedData(treeId).treeConst(1), ...
        ['The ''HDSconfig.mat'' file that was selected does not belong to the same data '...
        'tree as the object that relies on this data.']);

      % Check location of objects in same folder as HDSconfig file to determine offset.
      aux = what(path);
      ix = 0;
      while 1
        ix = ix+1;
        chk = ~cellfun('isempty', strfind(aux.mat,s.classes{ix}));
        if any(chk)
          fileName = aux.mat{find(chk,1)};
          break;
        end
      end

      sLoadState = HDS.loadobj('request', true);
      HDS.loadobj([], false);
      temp = load(fullfile(path, fileName),'i1');
      HDS.loadobj([], sLoadState);

      % Set the offset, classes and basePath
      HDSManagedData(treeId).treeConst(4) = temp.i1.objIds(5);
      HDSManagedData(treeId).classes      = s.classes;
      HDSManagedData(treeId).basePath     = path;
      HDSManagedData(treeId).treeConst(2) = s.saveId;
      HDSManagedData(treeId).treeConst(3) = s.idsNr;

    end
    function obj = loadobj(obj, varargin)                                           
      %LOADOBJ  Automatically called when an object is loaded from disk.
      %   OBJ = LOADOBJ(OBJ) Checks if the object is correctly loaded. If the
      %   version numbers of the loaded object and the class do not match, it
      %   calls the UPDATEOBJ function. If the matlab load function is unable to
      %   parse the data into an object and returns a structure, the
      %   HDSCAST method is called to parse the struct as an object.
      %   Values of missing properties are stored in the
      %   'orphanProps' property.
      %
      %   For details on updating the objects, see the help for UPDATEOBJ
      %
      %   see also: UPDATEOBJ HDSCAST

      persistent HDSLoader
      if nargin > 1
        % The linkTree2Disk calls this function with obj = 'request'
        if ischar(obj)
          obj = HDSLoader;
        else
          HDSLoader = varargin{1};
        end
        return
      end

      if isempty(HDSLoader)
        HDSLoader = false;
      end

      % HDSLoader check is because functions like WHO calls HDSLoad as well...
      if HDSLoader
        try
          if isa(obj,'struct')
            % Object is a struct when the saved data has properties that are no longer
            % available in the class definition.
            classes = HDS.findHDSclasses(obj.objIds(4));
            obj = hdscast(obj, classes{obj.objIds(2)}, '-incl');
            obj.saveStatus = uint32(3);

            % Check if there are any orphan properties in object.
            if ~isempty(findprop(obj,'orphanProps'))
              fprintf(2,['Unmatched property values in %s class; saving will ' ...
                'remove values permanently.\n'], upper(class(obj)));
            end

          end
        catch ME
          fprintf(2,'Warning: An error occurred while casting the struct as an object.\n');
          fprintf(2,'Message: %s\n',ME.message);
        end

        % Check to see if object needs updating, and do so if necessary.
        needUpdate = obj.objVersion == [obj.HDSClassVersion obj.classVersion];
        if ~all(needUpdate)
          
          %Update HDSVersion if necessary
          if ~needUpdate(1)
            fprintf(1,'* %s: Updating HDSVersion <v%0.2f --> v%0.2f>. *\n', ...
              upper(class(obj)), obj.objVersion(1), obj.HDSClassVersion);
            obj = hdsupdateobj(obj);
          end

          %Update OBJVersion if necessary
          if ~needUpdate(2)
            if ismethod(obj, 'updateobj')
              fprintf(1,'* %s: Updating objVersion <v%0.2f --> v%0.2f>. *\n', ...
                upper(class(obj)), obj.objVersion(2), obj.classVersion);
              obj = updateobj(obj);
            else
              HDS.displaymessage(['The loaded object(s) were created using a different HDS-version'...
              ' then is currently used. However, no UPDATEOBJ method is defined for this class'...
              'Please create this method to update the objects (see help for template method).' ], 2,'\n','\n');
            end
          end

          % Display message if new VERSION does not correspond with CLASS Version
          if obj.objVersion(2) ~= obj.classVersion || obj.objVersion(1) ~= obj.HDSClassVersion
            fprintf(2,'!! Error updating: <Object v%0.2f vs. v%0.2f> , <HDS v%0.2f vs. v%0.2f>\n',...
              obj.objVersion(2), obj.classVersion, obj.objVersion(1), obj.HDSClassVersion);
          end
          
          % Set save status for object.
          obj.saveStatus = uint32(3);
        end
      end
    end
    function displaymessage(text, option, pre, post)                                
      %DISPLAYMESSAGE  Displays message to user in console
      %   DISPLAYMESSAGE(TEXT, OPTION) will display the TEXT in the
      %   console. This method differs from DISPLAY or FPRINTF in
      %   that it automatically crops the message to fit within the
      %   console independent of the size of the window. OPTION
      %   should be an integer indicating the type of message similar
      %   to the type defined in the FPRINTF method.

      if nargin < 4
        pre  = '\n';
        post = '\n';
      end

      cmdDim = get(0,'CommandWindowSize');
      maxwordlength = max([diff(regexp(text,' ')) length(text)- regexp(text,'\S+$')+1 ]);
      maxwidth = cmdDim(1) - maxwordlength;
      if maxwidth < 40; maxwidth = 40; end; % set minimum width

      if length(text) > maxwidth
        str = sprintf('.{%i}\\S*\\W?', maxwidth);
        aux =  strtrim(regexp(text, str,'match'));
        lstr = sum(cellfun(@length,aux));

        aux2 = repmat({'\n'},1,length(aux));
        aux3 = [aux ; aux2];

        aux4 = strtrim(text(lstr + length(aux):end));
        text = [strcat(aux3{:}) aux4];
      end
      % replace % in string
      text = strrep(text,'%','%%');

      fprintf(option, [pre text '\n' post]);
    end
    function locId = findObjonDisk(objId, classId, treeId, treeOffset)              
      %FINDOBJONDISK Finds the locId of an object on disk. It also
      %sets the objIndex of the object.

      global HDSManagedData
      basePath  = HDSManagedData(treeId).basePath;
      className = HDSManagedData(treeId).classes{classId};
      fileName  = sprintf('%s.bin',className);

      % Find all folders at treeOffset
      folders     = cell(100,1);
      folders{1}  = basePath;
      offset      = zeros(100,1);
      offset(1)   = HDSManagedData(treeId).treeConst(4);
      ix  = 1; % active row.
      ix2 = 2; % first available row.
      while 1
        if offset(ix) < treeOffset

          % Get all folder names; remove folders starting with '.'.
          list        = dir(folders{ix});
          prevFolder  = folders{ix};
          folderIdx   = find(cellfun(@(x) x(1),{list.name}) ~= '.' & [list.isdir] == true);

          if ~isempty(folderIdx)
            folders{ix} = fullfile(folders{ix} , list(folderIdx(1)).name );
            offset(ix)  = offset(ix)+1;

            for i = 2: length(folderIdx)
              folders{ix2} = fullfile(prevFolder , list(folderIdx(i)).name);
              offset(ix2)  = offset(ix) ;
              ix2 = ix2+1;
            end
          else
            ix=ix+1;
          end

        else
          % check for obj Id in file.
          filePath = fullfile(folders{ix}, fileName);
          if exist(filePath,'file')
            fid = fopen(filePath,'r','l');
            y = fread(fid, 'uint32');
            fclose(fid);
            
            binstruct = HDS.bin2struct(y);
            
            np = length(binstruct.parentIds);

            foffset = 6 + y(4) + 3*np;
            loc     = find( y(foffset:end) == objId , 1);
            if ~isempty(loc)

              cIdx    = [0; cumsum(y(foffset-np: (foffset-1) ) )] + 1; 

              findex   = find(cIdx > loc, 1)-1;
              parentIDs  = y(foffset-3*np: foffset-2*np-1);

              filePath = fullfile(fileparts(filePath) , sprintf('%s_%i.mat',className, parentIDs(findex)));

              locId  = HDS.getLocFromPath(filePath, treeOffset, treeId);
              return
            end
          end

          ix = ix + 1;
        end

        if ix==ix2; break; end;
      end

      error('HDS:findobjondisk','HDS Toolbox could not locate the object.');

    end
    function assignhostinbase(hostID)                                               
      global HDSManagedData

      % Find treeID
      if ~isempty(HDSManagedData)
        hostIDS = [HDSManagedData.treeConst];
        hostIDS = hostIDS(1:4:end);
        treeId = find(hostIDS == hostID);
      else
        treeId = [];
      end

      if isempty(treeId)
        HDS.displaymessage('-- -- -- -- -- --',2,'','');
        HDS.displaymessage(['The associated database is no longer active in memory, ' ...
          'please reload the object using HDSLOAD.'],1,'','');  
        HDS.displaymessage('-- -- -- -- -- --',2,'',''); 
        return
      end

      className   = HDSManagedData(treeId).classes{1};
      ids = HDSManagedData(treeId).objIds(:,HDSManagedData(treeId).objIds(1,:) == 1);

      if isempty(ids)
        % Host object is not in memory. Find on disk.
        assert(~isempty(HDSManagedData(treeId).basePath), ...
          'Unable to locate host object. HDS memory management is corrupted.');
        
        filePath = fullfile(HDSManagedData(treeId).basePath, className);
        assert(exist(filePath, 'file'), 'Unable to locate file with host object.');
        assert(HDSManagedData(treeId).treeConst(4) == 0, ...
          'Unable to locate host object; only part of the database is present on disk.');


        % DataNames is cell array with the names of the data variables in the data-file.
        dataName = 'i1'; %Host variable is always stored as i1;
        HDS.loadobj([], true);
        aux      = load(filePath, dataName);
        HDS.loadobj([], false);
        
        assert(~isempty(aux), 'Unable to locate host object.');

        aux = aux.(dataName);
        locId = HDS.getLocFromPath(filePath, 0, treeId);
        registerObjs(aux, treeId, locId);
      else
        % Host object is already managed.
        aux =  HDSManagedData(treeId).(HDSManagedData(treeId).classes{ids(2)})(ids(3));
      end

      % Assign the found object in base workspace.
      template = className;
      tname = [template '_1'];
      ix = 2;
      while 1
        if evalin('base',['exist(''' tname ''',' '''var'')']);
          tname = sprintf('%s_%d',template, ix);
        else
          break
        end
        ix = ix+1;
      end
      assignin('base', tname, aux); 

      % Display message with variable name. 
      HDS.displaymessage('-- -- -- -- -- --',2,'','');  
      display(sprintf('Object assigned in base workspace as : ''%s''', tname));
      HDS.displaymessage('-- -- -- -- -- --',2,'','\n');  
    end
    function classes = findHDSclasses(hostId)                                       
      %FINDHDSCLASSES  Returns the vector of classes belonging to HOSTID
      %
      %   Method is used by HDSLOAD in case it is incapable of casting
      %   the loaded data as the object. The method will create an
      %   index in HDSManagedData for the hostID and link it to disk
      %   if this it is not done yet.

      global HDSManagedData

      [treeId, ~] = HDS.getTreeId(hostId);

      if isempty(HDSManagedData(treeId).basePath)
        try
          HDS.linkTree2Disk(treeId);
        catch ME
          if ~any(HDSManagedData(treeId).objIds(1,:))
            HDSManagedData(treeId) =[]; %#ok<NASGU>
          end
          rethrow(ME);
        end
      end

      classes = HDSManagedData(treeId).classes;

    end
    objchanged(option, obj)
  end
    
end