function out = hdsload(varargin)
  %HDSLOAD  Loads objects from the HDS Toolbox from disk.
  %   OUT = HDSLOAD() will prompt the user to specify the file to load in
  %   with a file dialog window. OUT will be an array containing the
  %   objects that were located in the specified file.
  %
  %   OUT = HDSLOAD('path') will load all objects that are saved at the
  %   indicated location. OUT will be an array containing the
  %   requested objects.
  %
  %   OUT = HDSLOAD('path', INDEX) will load the objects stored at the
  %   specified location. INDEX is a numeric vector indicating the
  %   indeces of the objects that should be loaded. OUT is an array
  %   containing the objects at the INDEX positions of the file.
  %
  %   OUT = HDSLOAD('path', 'name') will load the object for which the
  %   'strindex' property of the object contains the string specified in
  %   'name'. OUT is the requested object.

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  global HDSManagedData

  try
    if isempty(varargin)
      [FileName, PathName]    = uigetfile();
      [PathName, FileName, ~] = fileparts( fullfile(PathName, FileName) ); %fix trailing '/' bug.
    else
      assert(ischar(varargin{1}), 'Path must be of type ''char''.');
      [PathName, FileName, ~] = fileparts(varargin{1});
      if isempty(PathName) %Then the input was just the file
        PathName = fileparts(which(varargin{1}));
        if isempty(PathName)
          PathName = fileparts(which([FileName '.mat']));
        end
      end

    end

    HDS.loadobj([], true);
    objs = load(fullfile(PathName, FileName));
    HDS.loadobj([], false);

    if nargin == 2
      if ischar(varargin{2})
        dataNames = fieldnames(objs);
        [~, loc] = sort(dataNames); 
        out(length(loc)) = objs.(dataNames{loc(end)});
        for i = 1:length(loc)-1
            out(i) = objs.(dataNames{loc(i)});
        end

        strIndex = out(1).strIndexProp;
        indeces = find(strcmp(varargin{2}, [out.(strIndex)] ),1);

        assert(~isempty(indeces), ...
          'HDSLOAD: Cannot find object with string index : ''%s''',varargin{2});
        out = out(indeces);

      elseif isnumeric(varargin{2})
        dataNames = regexp(sprintf(sprintf('i%i\n', varargin{2})), '\n', 'split');
        dataNames = dataNames(1:end-1);

        out(length(dataNames)) = objs.(dataNames{length(dataNames)});
        for i = 1:length(dataNames)-1
          out(i) = objs.(dataNames{i});
        end
      end
    else
      % Return a sorted array of objects based on their index.
      dataNames = fieldnames(objs);
      [~, loc]  = sort(dataNames); 
      out(length(loc)) = objs.(dataNames{loc(end)});
      for i = 1:length(loc)-1
        out(i) = objs.(dataNames{loc(i)});
      end
    end

    treeOffset = out(1).objIds(5);
    hostId = builtin('subsref', out, substruct('()',{1},'.','objIds','()',{4}));
    [treeId, new] = HDS.getTreeId(hostId);

    if new
      % If new tree than link tree to disk
      HDS.linkTree2Disk(treeId, PathName, treeOffset);
    else
      % If not new tree, than check if loaded object belongs to same folder
      % structure. This fails when an object from an exported dataset is loaded
      % while the original dataset is in memory.
      basePath = HDSManagedData(treeId).basePath;
      assert(strcmp(basePath, PathName(1: length(HDSManagedData(treeId).basePath))), ...
        ['HDSLOAD: The HDS Toolbox does not allow the user to have objects from the '...
        'original and exported data-tree in memory simultaneously.']);
    end

    % Determine LocId and register obj
    locId = HDS.getLocFromPath(fullfile(PathName,FileName), treeOffset, treeId);
    out   = registerObjs(out, treeId, locId);  
    
  catch ME
    HDS.loadobj([], false);
    throwAsCaller(ME);
  end
  
end