function obj = addobj(obj, addClassName, varargin)   
  %ADDOBJ  Adds objects to the current object.
  %   OBJ = ADDOBJ(OBJ, 'class') will add one object to the current object.
  %   'class' is a string indicating the class name of the desired object. The
  %   added object will be generated without any additional constructor
  %   arguments and will be added to the default property as defined in the
  %   LISTAS property of the added object.
  %  
  %   OBJ = ADDOBJ(OBJ, 'class', NR) will add N objects to the current object.
  %   The added object will be generated without any additional constructor
  %   arguments and will be added to the default property as defined in the
  %   LISTAS property of the added object.
  %  
  %   OBJ = ADDOBJ(OBJ, 'class', 'propName') will add one object to the current
  %   object. 'propName' is a string indicating the property to which the object
  %   will be added.
  %  
  %   OBJ = ADDOBJ(OBJ, 'class', 'propName', NR) Will add N objects to the current
  %   object. The added object will be generated without any additional
  %   constructor arguments and will be added to the property PROP.
  %  
  %   OBJ = ADDOBJ(... , CONSTRUCTOR) In all cases, a cell-array can be
  %   specified as the last argument defining additional inputs to the
  %   class constructor of the added objects. In this case, the number of
  %   rows in the cell-array will be used to determine the number of
  %   objects that should be added. In case the number of objects is
  %   explicitely specified by NR, the cell-array should be one-dimensional
  %   and will be applied as a constructor argument for each object.
  %  
  %   Example
  %  
  %       E = Experiment; addobj(E,'Trial', {'Trial01' ; 'Trial02'})
  %  
  %       T = Trial; addobj(T,'KinData','kindata',4,{'name' argument2 argument3})
  %  
  %       K = KinData; addobj(K,'Marker','mrk', {'Hip' MarkerArray});            

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  persistent inAddObj
  
  if isempty(inAddObj); inAddObj = false; end;
  
  try
    % In order to eliminate the possibility to use addobj in the constructor of a class, we check 
    % for the INADDOBJ flag.
    assert(~inAddObj, ['ADDOBJ: Cannot call the ADDOBJ method from within the ADDOBJ method. '...
      'This is most likely caused by invoking this method in the constructor of an object.']);
    inAddObj = true; %#ok<NASGU>

    % Check length of OBJ
    assert(length(obj) == 1, 'ADDOBJ: Cannot add to an array of objects.');

    % Register object if not previously registered.
    treeId = obj.treeNr;
    if ~treeId ; [obj, treeId] = registerObjs(obj); end 

    % Create empty object to check if the object is a valid object for database.
    hdspreventreg(true); %Prevent registration
    emptyObj = eval(addClassName);
    assert(isa(emptyObj,'HDS'), 'ADDOBJ: %s is not a valid subclass of HDS.', upper(addClassName));
    hdspreventreg(false);
    
    % Check ObjectParent-Types and ObjectDynVars
    newObjParentClasses = emptyObj.parentClasses;
    isParentClass = cellfun(@(x,y) isa(obj,x), newObjParentClasses);
    isChildClass  = cellfun(@(x,y) isa(emptyObj,x), obj.childClasses);
    assert( any(isParentClass) && any(isChildClass), ['Cannot add an object of class %s '...
      'to an object of class %s.'], upper(addClassName), upper(class(obj)));

    %obj  = addobj(obj, type, varargin)             
    %OBJ = ADDOBJ(OBJ, TYPE, NR) -> uses list as
    %OBJ = ADDOBJ(OBJ, TYPE, PROP)
    %OBJ = ADDOBJ(OBJ, TYPE, PROP, NR)
    %OBJ = ADDOBJ(... , CONSTRUCTOR) In all cases, a cell-array can be     
    constructorCell = {}; 
    propname = emptyObj.listAs;
    N = 1;
    switch length(varargin)
      case 1
        if isnumeric(varargin{1}) && length(varargin{1})==1
          N = varargin{1};
        elseif ischar(varargin{1})
          propname = varargin{1};
        elseif iscell(varargin{1})
          constructorCell = varargin{1};
          N = size(constructorCell,1);
        else
          error('HDS:addobj','ADDOBJ: Incorrect input arguments.');
        end
      case 2
        if ischar(varargin{1})
          propname = varargin{1};
        elseif isnumeric(varargin{1}) && length(varargin{1})==1
          N = varargin{1};
        else
          error('HDS:addobj','ADDOBJ: Incorrect input arguments.');
        end
        if isnumeric(varargin{2}) && length(varargin{2})==1
          N = varargin{2};
        elseif iscell(varargin{2})
          constructorCell = varargin{2};
          assert(size(constructorCell,1) ==1 || size(constructorCell,1)==N, ...
            'ADDOBJ: Size NR and number of rows in CONSTRUCTOR mismatch.');
        else
          error('HDS:addobj','ADDOBJ: Incorrect input arguments.');
        end
      case 3
        if ischar(varargin{1}) && isnumeric(varargin{2}) && ...
            iscell(varargin{3}) && length(varargin{2})==1
          propname = varargin{1};
          N = varargin{2};
          constructorCell = varargin{3};
          assert(size(constructorCell,1) == 1 || size(constructorCell,1) == N, ...
            'ADDOBJ: Size NR and number of rows in CONSTRUCTOR mismatch.');
        else
          error('HDS:addobj','ADDOBJ: Incorrect input arguments.');
        end
    end

    % Get Class ID
    addClassId = HDS.getClassId(addClassName, treeId); 

    % Check availability of property name
    matchPropName = strcmp(propname, obj.linkProps);
    if any(matchPropName)
      assert( uint32(addClassId) == obj.linkPropIds(1,matchPropName), ...
        'Incorrect class; object of class %s cannot be added to property %s.',...
        upper(addClassName), upper(propname));
    else
      assert(all(uint32(addClassId) ~= obj.linkPropIds(1,:)), ...
        ['ADDOBJ: A property with objects of class %s already exists in the %s object...\n' ...
        'Objects of the same class should be stored in a single property of the object.'], ...
        upper(addClassName),upper(class(obj)));
    end

    % Determine implementation of constructor cell.
    if size(constructorCell,1) <= 1
      constructStr = '(constructorCell{:})' ;
    elseif size(constructorCell,1) == N
      constructStr = '(constructorCell{N,:})';
    else
      error('HDS:addobj','ADDOBJ: Incorrect nr. of arguments for object constructor'); 
    end

    % Create new objects.
    hdspreventreg(true);
    newObjs(N) = eval([addClassName constructStr]);
    newObjs(N).objIds(2:5) = [addClassId obj.objIds([1 4])' (obj.objIds(5)+1) ];
    if N > 1
      for i = 1: (N-1)
        newObjs(i) = eval([addClassName constructStr]);
        newObjs(i).objIds(2:5) = [addClassId obj.objIds([1 4])' (obj.objIds(5)+1) ];
      end
    end
    hdspreventreg(false);

    % Register new objects in HDSManagedData
    [~, locId, ~, ~] = getobjlocation(obj);
    registerObjs(newObjs, treeId, [addClassId; obj.objIds(1); locId]);

    % Set Parent property Attributes
    if any(matchPropName)
      propId = find(matchPropName, 1);
    else
      obj.linkProps   = [obj.linkProps propname];
      obj.linkPropIds = [obj.linkPropIds uint32([addClassId; 1])];
      propId = length(obj.linkProps);
    end

    % Put objects in object   
    newIds  = [newObjs.objIds];
    newIds  = newIds(1,:);
    aux     = uint32([newIds ; propId(ones(1,length(newIds))) ; zeros(1,length(newIds))]);
    obj.linkIds = [obj.linkIds aux];

    % Store save status if needed
    if obj.saveStatus == uint32(0)
      HDS.objchanged('obj',obj);
    end

    % Set persistent variable back to false.
    inAddObj = false;

  catch ME
    inAddObj = false;  %#ok<NASGU>
    hdspreventreg(false);
    if strcmp(ME.identifier,'MATLAB:undefinedVarOrClass');
      error('HDS:addobj','ADDOBJ: %s is not a valid class definition.', upper(addClassName));
    else
      rethrow(ME);
    end
  end
end
