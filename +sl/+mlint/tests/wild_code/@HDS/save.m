function obj = save(obj, varargin)   
  %SAVE  Saves the database associated with the object.
  %   OBJ = SAVE(OBJ) saves the database associated with OBJ. If the
  %   database has previously been saved, it will update the objects on
  %   disk to mirror the version in memory. If this is the first time the
  %   SAVE method is called, a user interface will ask the user to select
  %   an empty folder as the root of the database.
  %
  %   OBJ = SAVE(OBJ, 'path') save the object and all related objects in
  %   memory to the folder specified in 'path'. If the database has
  %   previously been saved, 'path' should should point to the location
  %   where the database has been saved previously or should be omitted.
  %   If this is the first time that the SAVE method is called, the path
  %   should point to an empty folder on disk.
  %
  %   OBJ = SAVE(... ,'-noDefrag') omits calling the
  %   HDSDEFRAG method following the saving procedure. This might speed
  %   up the saving process in some cases but can result in unnecessary
  %   large datafiles on disk. The HDSDEFRAG method can be called
  %   seperately of the SAVE method. 
  %
  %   see also: HDS.hdsdefrag

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  global HDSManagedData

  try
    % -- Check inputs for '-noDefrag' tag
    switch nargin
      case 1
        defragOn = true;
      case 2
        assert(ischar(varargin{1}), ...
          'SAVE: Second argument to SAVE method should be of type ''char''.');
        if strcmp(varargin{1}, '-noDefrag')
          defragOn = false;
        else
          defragOn = true;
        end
      case 3
        assert(ischar(varargin{1}) && ischar(varargin{1}), ...
          'SAVE: Second and third argument to SAVE method should be of type ''char''.');
        defragTag = find(strcmp('-noDefrag',varargin),1);
        assert(any(defragTag), 'SAVE: Incorrect input arguments.');     
        varargin(defragTag) = [];
        defragOn = false;
      otherwise
        error('HDS:save','SAVE: Incorrect number of input arguments.');
    end

    % -- Check dimemions of obj. Obj can only be vector of objects.
    assert(isvector(obj), ...
      'SAVE: The array of objects has to be one-dimensional in order to be saved to disk.');

    % -- Save Database.
    obIds = [obj.objIds];
    if length(obj) > 1
      % Check if all hostIds are the same
      hostIds = obIds(4,:);
      assert(all(hostIds(1) == hostIds), ...
        'SAVE: You can only save arrays of objects if all objects belong to the same database.');

      % All objects are either registered or all are not registered.
      treeId = obj(1).treeNr;

      % Register all objs if not previously registered.
      assert(treeId > 0, ['SAVE: Method is not capable of saving arrays of objects other '...
        'than arrays containing previously saved objects.']);  
      
      % Call method that does the actual saving of objects.
      createdDummy = savehds(treeId, varargin{:});

    else % length(obj) == 1
      treeId = obj.treeNr;
      if ~treeId; [obj, treeId] = registerObjs(obj); end 
      
      % Call method that does the actual saving of objects.
      createdDummy = savehds(treeId, varargin{:});
    end

    % -- Defrag files if necessary.
    if defragOn && createdDummy
      hdsdefrag(obj(1));
    end

    % -- Display message to user. 
    HDS.displaymessage('-- -- -- -- -- --', 2, '\n', '');
    fprintf('The database has been saved to :\n  %s\n', HDSManagedData(treeId).basePath);
    if createdDummy && ~defragOn
      HDS.displaymessage( ...
        '* Use the HDSDEFRAG method to reduce the size of the data-files on disk. *', 1, '\n', '');
    end
    HDS.displaymessage('-- -- -- -- -- --', 2, '', '\n');
      
  catch ME
    rethrow(ME)
  end
end

function createdDummy = savehds(treeId, varargin)   
 global HDSManagedData

  aux = hdsoption;
  maxNCFileSize = aux.maxNCFileSize;
  HDSManagedData(treeId).isSaving = true;
  cleanupGlobal = onCleanup(@()cleanupCB());

  % -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  % -- -- -- Get the path to which the data will be saved -- 
  if isempty(HDSManagedData(treeId).basePath)                 
    % * DataTree has never been saved before. 
    previouslySaved = false;

    if nargin == 2
      basePath = HDSManagedData(treeId).basePath;
      assert(isempty(basePath) || strcmp(varargin{1}, basePath), ...
        ['Database is already stored in a different location, use the HDSEXPORT '...
        'method to make a copy in a different location.']);

      newdir = varargin{1};
      if ispc && (strcmp(newdir(2),':') || strcmp(newdir(1:2),'//'))
        newdir = varargin{1};
      elseif isunix && strcmp(newdir(1),'/')
        newdir = varargin{1};
      else
        newdir = fullfile(pwd, varargin{1});
      end

      if ~exist(newdir,'dir')
        mkdir(newdir);
        ok = isdir(newdir);
        if ~ok
          rmdir(newdir);
          error('HDS:savehds','Unable to create folder: %s',newdir);
        end
      else
        %  Make sure selected folder is empty.
        aux = dir(newdir);
        aux(strncmp('.', {aux.name}, 1)) = [];
        assert(isempty(aux),...
          'The specified folder already contains files/folders, please specify an empty folder.');  
      end

    else
      display('Specify Location for object.');
      newdir = uigetdir('', sprintf('Specify folder in which the data should be stored.'));

      assert(~isempty(newdir), 'Save operation cancelled');
      % Check folder and get rid of hidden folders.
      aux = dir(newdir);
      aux(strncmp('.', {aux.name}, 1))= [];
      assert(isempty(aux),...
        'The specified folder already contains files/folders, please specify an empty folder.'); 
    end

    HDSManagedData(treeId).basePath = newdir;
  else
    previouslySaved = true;
  end

  % -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  % -- -- -- Save config file  -- -- -- -- -- -- -- -- -- -- 

  % load previous HDSconfig.mat file, check classes, hostId and get saveId.
  if previouslySaved
    try
      cStruct = load(fullfile(HDSManagedData(treeId).basePath, 'HDSconfig.mat'));

      % check classes
      activeClasses       = ~cellfun('isempty', cStruct.classes);
      allClassesInStruct  = cStruct.classes(activeClasses);
      allClassesInMem     = HDSManagedData(treeId).classes(activeClasses);

      assert(all(strcmp(allClassesInStruct, allClassesInMem)), ...
        ['SAVE: The classIds in the previously saved dataset do not correspond with '...
        'the classIds in memory. This should normally not be possible. The best '...
        'thing to do is CLEAR ALL and reload data from disk. Changes will not be saved.']);
      assert(cStruct.hostId == HDSManagedData(treeId).treeConst(1), ...
        ['SAVE: The hostId is the previously saved dataset does not correspond with the ' ...
        'hostId in memory. The best thing to do is CLEAR ALL and reload data from disk. '...
        'Changes will not be saved.']);

      isExported = cStruct.isExport;

    catch ME
      if strcmp(ME.identifier, 'MATLAB:load:couldNotReadFile')
        warning('HDS:SAVE',['SAVE : Unable to find ''HDSconfig.mat'', '...
          '''HDSconfig.mat'' will be generated from data in memory.']);
        isExported = false;
      else
        rethrow(ME);
      end
    end
  else
    isExported = false;
  end

  % Increase the save counter.
  HDSManagedData(treeId).treeConst(2) = HDSManagedData(treeId).treeConst(2) + 1;

  % Create and save config.mat
  config = struct(...
    'hostId'  , HDSManagedData(treeId).treeConst(1), ...
    'idsNr'   , HDSManagedData(treeId).treeConst(3), ...
    'classes' , [], ...
    'isExport', isExported, ...
    'saveId'  , HDSManagedData(treeId).treeConst(2));
  config.classes  = HDSManagedData(treeId).classes; %#ok<STRNU>
  
  configPath      = fullfile(HDSManagedData(treeId).basePath, 'HDSconfig.mat');
  save(configPath, '-struct', 'config');

  % Get HDS options.
  options = hdsoption;
  
  % -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  % -- -- -- Prep for saving BIN file per folder -- -- -- --
  
  activeIds       = HDSManagedData(treeId).objIds(1,:) > 0;
  toBeSaved       = HDSManagedData(treeId).objBools(1, activeIds);

  allFileLocs     = HDSManagedData(treeId).objIds(4, activeIds);
  changedFileLocs = allFileLocs(toBeSaved);
  remFileLocs     = HDSManagedData(treeId).remIds(1, :);
  changedFileLocs = unique([remFileLocs changedFileLocs]);
  
  objIdsPerFile   = cell(length(changedFileLocs), 1);
  locFolders      = unique(HDSManagedData(treeId).locArray(end:-1:3, changedFileLocs)', 'rows');
  locFolders      = double(locFolders'); %double to make possible substraction...

  % -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  % -- -- -- Save the objects that have changed  -- -- -- --   

  while any(toBeSaved)                                        
    % Get the current location vector.
    curFileId   = HDSManagedData(treeId).objIds(4, find(toBeSaved, 1));
    curLoc      = HDSManagedData(treeId).locArray(:, curFileId);
    curLoc      = curLoc(end: -1: 1);
    curLoc      = curLoc(find(curLoc > 0, 1):end);
    
    % Find Class ID and Class string.
    classId     = curLoc(end);
    classStr    = HDSManagedData(treeId).classes{classId};

    % -- Load objects that are not in memory but are in files that contain changed objects. --
    curPath = HDS.getPathFromLoc(curLoc, treeId);
    if exist([curPath '.mat'], 'file')

      % ALLMANOBJID is all objIds stored in current file or is removed.
      allCurFileId    = HDSManagedData(treeId).objIds(4, :) == curFileId;
      allCurRemId     = HDSManagedData(treeId).remIds(1, :) == curFileId;
      curFileIDObjIds = HDSManagedData(treeId).objIds(1, allCurFileId);
      curFileIDRemIds = HDSManagedData(treeId).remIds(2, allCurRemId);
      allManObjId     = [curFileIDObjIds curFileIDRemIds];

      % Find the ids that are currently not loaded and define the variable names
      % of those unloaded objects. Then, load and register the missing variable
      % such that all objects of the file to be saved are loaded in memory.
      names           = regexp(sprintf('i%i\n', allManObjId), '\n', 'split');
      names           = names(1: end-1);
      namesInFile     = mex_whofile([curPath '.mat']); %fast version of who('-file', ...)
      missingNames    = cellfun(@(x) ~any(strcmp(x, names)), namesInFile);
      loadNames       = namesInFile(missingNames);

      hdspreventreg(true);
      tempobjs = eval(sprintf('%s', classStr));
      hdspreventreg(false);

      if ~isempty(loadNames)
        
        HDS.loadobj([], true);
        if options.metaMode
          loadobjs = load([curPath '.mat'], loadNames{:});
        else
          loadobjs = load([curPath '.mat']);
        end        
        HDS.loadobj([], false);

        tempobjs(length(loadNames)) = loadobjs.(loadNames{length(loadNames)}); 
        for i = 1:length(loadNames) - 1
          tempobjs(i) = loadobjs.(loadNames{i}); 
        end

        registerObjs(tempobjs, treeId, curLoc(end:-1:1));  

        % Reset ActiveIds        
        activeIds = HDSManagedData(treeId).objIds(1,:) > 0;
      end

    else
      % Create folder if necessary.
      if ~isdir(fileparts(curPath))
        mkdir(fileparts(curPath));
      end
    end

    % Find all the objects of the file in the repository.
    allCurFileId    = HDSManagedData(treeId).objIds(4, :) == curFileId;
    allCurReposIdx  = HDSManagedData(treeId).objIds(3, allCurFileId);
    saveObjs        = HDSManagedData(treeId).(classStr)(allCurReposIdx);

    % -- save objects --

    % ALLMANOBJID is all floor(object ids) stored in current file.
    allManObjId = HDSManagedData(treeId).objIds(1, allCurFileId);
    
    % Update the names variable to reflect loaded missingIndeces.
    names = regexp(sprintf('i%i\n', allManObjId), '\n','split');
    names = names(1: end-1);               

    % Set the saveStatus property and save the objects.
    for j =1: length(saveObjs)
      saveObjs(j).saveStatus = uint32(0);
      eval(sprintf('%s = saveObjs(%i);', names{j}, j));
    end
    save([curPath '.mat'], names{:}, '-v6');

    % - find the folderId and the ID -
    curLocDouble        = double(curLoc);
    strippedLocFolders  = locFolders(end - (length(curLocDouble)-3): end, :);
    mirroredCurLoc      = repmat(curLocDouble(1:end-2), 1, size(locFolders,2));
    folderId            = find(~any(strippedLocFolders - mirroredCurLoc,1), 1);
    parentID            = curLoc(end-1);

    % - Add to cell-array for BIN FILE info. -
    perFileIdx  = find(curFileId == changedFileLocs, 1);
    objIdsPerFile{perFileIdx} = uint32([folderId classId parentID allManObjId]);

    % - Make Changes to HDSManagedData -
    HDSManagedData(treeId).objBools(1, allCurFileId) = false;
    HDSManagedData(treeId).objBools(3, allCurFileId) = true;

    % - Find new tobesaved.
    toBeSaved = HDSManagedData(treeId).objBools(1, activeIds);
  end
  
  % Add folder class and parent info for deleted files.
  % Iterate over remIds and fill in objIdsPerFile for completely removed objects.
  % If the removed objects were the last objects in a file, the mat-file will be obsolete and should
  % be removed. This is done later in the code.
  emptyIdx = find(cellfun('isempty',objIdsPerFile));
  for i = 1: length(emptyIdx)
    
    % - find the folderId and the ID -
    curLoc   = HDSManagedData(treeId).locArray(:, changedFileLocs(emptyIdx(i)));
        curLoc      = curLoc(end: -1: 1);
    curLoc      = curLoc(find(curLoc > 0, 1):end);
    curLocDouble        = double(curLoc);
    strippedLocFolders  = locFolders(end - (length(curLocDouble)-3): end, :);
    mirroredCurLoc      = repmat(curLocDouble(1:end-2), 1, size(locFolders,2));
    folderId            = find(~any(strippedLocFolders - mirroredCurLoc,1), 1);
    parentID            = curLoc(end-1);
    classId             = curLoc(end);
    
    objIdsPerFile{emptyIdx(i)} = [folderId classId parentID];
  end
  
  % -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  % -- -- -- Generate and save BIN files   -- -- -- -- -- --
  hostIDBin = HDSManagedData(treeId).treeConst(1);
  if ~isempty(objIdsPerFile)                                  

    % Check that all objIdsPerFile cells has content.
    assert(~any(cellfun('isempty', objIdsPerFile)), ...
      'SAVE : objIdsPerFile has empty entries... This should never happen.');

    % AllFolderIds is vector with folder ids in which changes are made.
    allFolderIds  = cellfun(@(x) x(1), objIdsPerFile);

    % Iterate over changed folders and generate a single bin file per folder per class.
    for i = 1: size(locFolders, 2)

      % - FileIdsInFolder is vector of all files that have been saved in the current folder.
      objIdsFileFolder    = objIdsPerFile(allFolderIds == i);
      allClassIds         = cellfun(@(x) x(2), objIdsFileFolder);
      uniqueClassInFolder = unique(allClassIds); 

      % - Get the path to the folder
      curLoc  = locFolders(:,i);
      curLoc  = curLoc(find(curLoc>0, 1):end);
      curPath = HDS.getPathFromLoc(curLoc, treeId);

      % - Store binary file for each of the classes in folder.
      for iClass = 1: length(uniqueClassInFolder)

        curClassId              = uniqueClassInFolder(iClass);
        objIdsFileFolderClass   = objIdsFileFolder(allClassIds == curClassId);
        curBinFile = fullfile(curPath, [HDSManagedData(treeId).classes{curClassId} '.bin']);

        % Check if there already is a BIN file for this class in the curren folder.
        if exist(curBinFile,'file')
          fid         = fopen(curBinFile, 'r', 'l');
          NBStruct    = HDS.bin2struct(fread(fid, '*uint32'));
          fclose(fid);
          
          % Check folderLink
          lengthInBin = NBStruct.initParams(4);
          assert(lengthInBin == length(curLoc),'FolderLink in Bin file has incorrect length.');
          assert(all(NBStruct.link == curLoc), 'FolderLink and curLoc should be equal.');
                    
          allParentIds = cellfun(@(x) x(3), objIdsFileFolderClass);
          newParentIds = allParentIds(~ismembc(allParentIds, sort(NBStruct.parentIds)));
          
          NBStruct.parentIds    = [NBStruct.parentIds ; uint32(newParentIds)];
          NBStruct.updateBools  = [NBStruct.updateBools ; ones(length(newParentIds),1,'uint32')];
          NBStruct.nrChildPP    = [NBStruct.nrChildPP ; zeros(length(newParentIds),1,'uint32')];
          NBStruct.nrParents    = length(NBStruct.parentIds);
            
          checkVec = false(length(objIdsFileFolderClass),1);
          for iP = 1: NBStruct.nrParents
            % See if parentID is in memory ---> in allParenIds
            select = find(NBStruct.parentIds(iP) == allParentIds, 1); 
            checkVec(select) = true;
            if ~isempty(select)
               allObjIds      = objIdsFileFolderClass{select}(4:end);

               NBStruct.nrChildPP(iP) = length(allObjIds);
               sizeDiff = NBStruct.nrChildPP(iP) - size(NBStruct.childIDs, 1);
               if sizeDiff > 0
                 padding = zeros(sizeDiff, size(NBStruct.childIDs, 2),'uint32');
                 NBStruct.childIDs = [NBStruct.childIDs ; padding];
               end
               
               NBStruct.childIDs(:, iP) = [allObjIds' ; ...
                 zeros(size(NBStruct.childIDs,1) - length(allObjIds),1)];
               
            end
          end 
          
          assert(all(checkVec), 'Did not update all parentIDS in binary file.');

        else       
          % Define the New Binary Structure.
          NBStruct = struct(...
            'initParams',[],...
            'link',[],...
            'nrParents',[],...
            'parentIds',[],...
            'updateBools',[],...
            'nrChildPP',[],...
            'childIDs',[]);
          
          NBStruct.initParams   = [0 hostIDBin curClassId length(curLoc)];
          NBStruct.link         = curLoc;
          NBStruct.nrParents    = uint32(length(objIdsFileFolderClass));
          NBStruct.parentIds    = uint32(cellfun(@(x) x(3), objIdsFileFolderClass));
          NBStruct.updateBools  = zeros(NBStruct.nrParents,1, 'uint32');
          
          %find length of objIDS
          NBStruct.nrChildPP = zeros(NBStruct.nrParents,1);
          for iP = 1: NBStruct.nrParents
            NBStruct.nrChildPP(iP) = length(objIdsFileFolderClass{iP}(4:end));
          end
          
          NBStruct.childIDs = zeros(max(NBStruct.nrChildPP), NBStruct.nrParents, 'uint32');
          for iP = 1: NBStruct.nrParents
            NBStruct.childIDs(1:NBStruct.nrChildPP(iP),iP) = ...
              objIdsFileFolderClass{iP}(4:end);
          end
        end 

        % save Bin file
        binVector = HDS.struct2bin(NBStruct);
        fid = fopen(curBinFile, 'w', 'l');
        fwrite(fid, binVector, 'uint32'); 
        fclose(fid);
      end
    end
  end

  % -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  % -- -- -- Save the dataprops that have changed - -- -- --
  toBeSaved       = HDSManagedData(treeId).objBools(2, activeIds);
  createdDummy    = false;
  while any(toBeSaved)                                        
    % Find the location ID and the location of the file.
    curFileId   = HDSManagedData(treeId).objIds(4, find(toBeSaved,1));
    curLoc      = HDSManagedData(treeId).locArray(:, curFileId);
    curLoc      = curLoc(end:-1:1);
    curLoc      = curLoc(find(curLoc>0, 1):end);

    classId     = curLoc(end);
    classStr    = HDSManagedData(treeId).classes{classId};

    % Get the path based on the location.
    curPath = HDS.getPathFromLoc(curLoc, treeId);      

    % Find all the objects of the file in the repository that need to
    % be saved in this File.
    allCurFileId   = HDSManagedData(treeId).objIds(4, activeIds) == curFileId;
    allCurFileId   = allCurFileId & toBeSaved;
    allCurReposIdx = HDSManagedData(treeId).objIds(3, allCurFileId);
    allCurFileIDs  = HDSManagedData(treeId).objIds(1, allCurFileId);

    % Find dataProperty names of current class.
    hdspreventreg(true);
    curObj = eval(classStr);
    hdspreventreg(false);
    datProps = curObj.dataProps;

    % First create or open the master file; .nc and extract the
    % fileChannelVector which indicates which subfile the indeces
    % are stored.
    curFile = [curPath '.nc']; 
    new = ~exist(curFile, 'file');
    if new
      ncid = netcdf.create(curFile, 512); % 512 is NC_64BIT_OFFSET 

      % Create attribute that tracks for dummy variables.
      netcdf.putAtt(ncid, -1, 'hasDummyVars', 0); 

      % Create varid and dimid for trakcing the file indeces of
      % the different objects. Set the filecHannelVec to empty.
      dimid   = netcdf.defDim(ncid,'nchannel', 1000);
      dimid2  = netcdf.defDim(ncid,'2col', 2);
      chIndexVarid = netcdf.defVar(ncid, 'chIndexVec', 'double', [dimid dimid2]);

      fileChannelVec = zeros(1000, 2);
      netcdf.close(ncid);
    else
      % Open file and read the channelIndex vector to find where
      % all channels are stored.
      ncid = netcdf.open(curFile, 1); % 1 is NC_WRITE

      try
        chIndexVarid = netcdf.inqVarID(ncid, 'chIndexVec');
      catch ME
        netcdf.close(ncid);
        error('HDS:SAVE', ...
          'SAVE: File expected to contain chIndexVector but variable does not exist.');
      end

      fileChannelVec = netcdf.getVar(ncid, chIndexVarid);
      netcdf.close(ncid);
    end        

    % Find size of objects that need to be saved and determine in which
    % files each variable should go. SizePerIndex is an approximation
    % of the size per index in a data variable taking into account the
    % class of the data. This is based on the NC dataclass ids.
    %
    % 'double' = 6 ; 'single' = 5 ; 'int32' = 4 ; 'char' = 2 ; 'int8' =
    % 1 ; 'int16' = 3
    sizePerIndex = [1 1 2 4 4 8]; % Bits per index.
    varStats = zeros(length(allCurFileIDs), 3); % [size subFileIdx ndim]
    for iObj = 1: length(allCurFileIDs)
      cObj = HDSManagedData(treeId).(classStr)(allCurReposIdx(iObj));
      for iVar = 1: length(datProps)
        aux = cObj.dPropSize(iVar,:);
        propDims = aux(2: find(aux,1,'last'));
        if ~isempty(propDims)
          varStats(iObj,1) = varStats(iObj,1) + (prod(double(propDims)) * sizePerIndex(aux(1)) );
          varStats(iObj,3) = varStats(iObj,3) + length(propDims);
        end
      end
    end


    % - Get fileSizes/ndim/nvar for existing data-files
    curFileSizes = zeros(max([1 max(fileChannelVec(:,2))]), 3);  % [size, ndim, nvar]
    for iFile = 1: size(curFileSizes,1)
      if iFile ==1 
        tFname = [curPath '.nc'];
      else
        tFname = [curPath sprintf('.%03d',iFile)];
      end
      tempfid = fopen(tFname); 

      assert(tempfid > 0, 'SAVE: Expected ''data'' file (%s) not found.',tFname);
      fseek(tempfid,0,'eof'); curFileSizes(iFile) = ftell(tempfid);fclose(tempfid);
      ncid = netcdf.open(tFname,'NC_NOWRITE'); 
      [curFileSizes(iFile,2), curFileSizes(iFile,3),~,~] = netcdf.inq(ncid);
      netcdf.close(ncid);
    end

    % - Determine where each variable will be located.
    for iObj = 1: length(allCurFileIDs)
      IDindex = find(fileChannelVec(:,1) == double(allCurFileIDs(iObj)),1);


      if ~isempty(IDindex)
        % Keep dataProps for iObj in same file
        varStats(iObj,2) = fileChannelVec(IDindex,2);
      else
        IDindex = find(fileChannelVec(:,1) == 0, 1);
        % Find file that meets requirements
        ix = 1;
        while varStats(iObj, 2) == 0
          if ix <= size(curFileSizes, 1) 
            estFileSize = curFileSizes(ix,1) + varStats(iObj,1);
            estFileNrDims = curFileSizes(ix,2) + varStats(iObj,3);
            estFileNrData = curFileSizes(ix,3);
           
            if estFileSize < maxNCFileSize && estFileNrDims < 1000 && estFileNrData < 500
              curFileSizes(ix,1) = estFileSize;
              curFileSizes(ix,2) = estFileNrDims;
              curFileSizes(ix,3) = estFileNrData + 1;
              varStats(iObj,2) = ix;
              fileChannelVec(IDindex,:) = [allCurFileIDs(iObj) ix];
            else
              ix = ix + 1;
            end
          else
            % Create new file
            curFileSizes = [curFileSizes ; [varStats(iObj,1) varStats(iObj,3) 1]];  %#ok<AGROW>
            varStats(iObj,2) = ix;
            fileChannelVec(IDindex,:) = [allCurFileIDs(iObj) ix];

            newFile = [curPath sprintf('.%03d',ix)];
            ncid = netcdf.create(newFile, 512);
            netcdf.putAtt(ncid, -1, 'hasDummyVars', 0);
            netcdf.close(ncid);
          end
        end
      end
    end

    % - Put fileChannelVec back in nc- file. Already checked that file exist.
    ncid = netcdf.open(curFile,'NC_WRITE');
    netcdf.putVar(ncid, chIndexVarid, fileChannelVec);
    netcdf.close(ncid);

    % - Iterate over all subfiles and save data
    uniqueSubFiles = unique(fileChannelVec(:,2));
    uniqueSubFiles = uniqueSubFiles(uniqueSubFiles > 0);
    for iSubFile = 1: length(uniqueSubFiles)
      curSubFile = uniqueSubFiles(iSubFile);
      curObjIDs = fileChannelVec(fileChannelVec(:,2) == curSubFile,1);

      % Get all indeces that should be saved, empty if file is deleted
      idx = ismembc(allCurFileIDs, uint32(sort(curObjIDs)));
      if ~isempty(idx)

        CurSubFileIDs  = allCurFileIDs(idx);
        CurSubReposIdx = allCurReposIdx(idx);

        % Open curSubFile
        if curSubFile == 1 
          sName = [curPath '.nc'];
        else
          sName = [curPath sprintf('.%03d', curSubFile)];
        end

        % Open 'data' file, should have been created before.
        try
          ncid = netcdf.open(sName,'NC_WRITE');
        catch ME
          error('HDS:SAVE','SAVE: Unable to open the ''data''-file. This should never happen.');
        end

        netcdf.reDef(ncid);

        % Get Dimension Names and sizes in curFile
        [ndims, nvars, ~, ~] = netcdf.inq(ncid);
        dims     = zeros(1, length(ndims));
        dimNames = cell(1, ndims);
        for i = 1: ndims
          [dimNames{i}, dims(i)] = netcdf.inqDim(ncid, i-1);
        end

        names   = cell(nvars, 1);
        varDims = cell(nvars, 1);
        for i = 1: nvars
          [names{i}, ~, varDims{i}, ~] = netcdf.inqVar(ncid,i-1); 
        end

        % Get object Dimensions and name from objects that need saving. 
        ix  = 0;
        si = cell(length(CurSubReposIdx)*length(datProps), 5);
        for i = 1: length(CurSubReposIdx)
          for j = 1: length(datProps)
            classStr = HDSManagedData(treeId).classes{classId};
            cObj = HDSManagedData(treeId).(classStr)(CurSubReposIdx(i));
            sizeP = sizeprop(cObj, datProps{j});
            if cObj.dPropSize(j,1) > uint32(0) && all(sizeP>0)
              ix = ix+1;
              si{ix,1} = sizeP;
              si{ix,2} = sprintf('%s_%i',datProps{j}, CurSubFileIDs(i));
              si{ix,3} = [CurSubReposIdx(i),j];
              si{ix,4} = double(cObj.dPropSize(j,1));
            end
          end
        end
        si = si(1:ix,:);

        % Write new dimension definitions
        di      = unique([si{:,1}]);

        % Remove 0 dimension as this is interpreted as NC_UNLIMITED
        di(di==0) = []; 

        newDims = find(~ismembc(di, sort(dims)));
        newDimLength = length(newDims);

        dims = [dims zeros(1,newDimLength)]; %#ok<AGROW>

        aux = regexp(dimNames,'_','split')';
        aux = aux(cellfun('length',aux')>1);
        maxDimId = max([0 ;(cellfun(@(x) str2double(x{2}),aux))]);

        dimNames = [dimNames cell(1,newDimLength)]; %#ok<AGROW>
        addDim = 1;
        for i = 1 : newDimLength
          dName = sprintf('dim_%i',maxDimId+addDim);
          netcdf.defDim(ncid, dName, di(newDims(i)));
          ndims = ndims +1;
          addDim = addDim +1;
          dims(ndims) =  di(newDims(i));
          dimNames{ndims} = dName; 
        end

        [sortDims, sortDimsIx] = sort(dims);

        % Check whether changed files already existed in file and if so, whether
        % the dimensions are the same. If not, then we rename the previous variable
        % to 'dummyX', set the 'NeedCleanup' global attribute and create new
        % variable.  
        if ~isempty(names)
          for i = 1: size(si,1)

            sameDim = true;
            loc = find(strcmp(si{i,2}, names),1);
            if ~isempty(loc)
              if length(si{i,1}) == length(varDims{loc})
                for j = 1: length(si{i,1})
                  if si{i,1}(j) ~= dims(varDims{loc}(j)+1)
                    % Dimensions not equal.
                    sameDim = false;
                    break;
                  end
                end
              else
                % Dimensions not equal.
                sameDim = false;
              end
            end

            % If the dimensions differ, rename old variable to
            % dummy and save new variable.
            if ~sameDim

              % find new dummy index
              dumIdx = sum(cellfun(@(x) any(strfind(x,'dummy')),names)) + 1;

              % Rename the variable to dummyX
              dummyName = sprintf('dummy%i', dumIdx);
              netcdf.renameVar(ncid, loc-1, dummyName);
              names{loc} = dummyName; 

              %set flag to display message to user.
              createdDummy    = true;

              % Create attribute that tracks for dummy variables.
              netcdf.putAtt(ncid, -1, 'hasDummyVars', 1); 
            end
          end
        end


        % Write new variable definitions
        for i = 1: ix
          chk = strcmp(si{i,2}, names);
          if ~any(chk)
            % create variable.
            loc = ismembc2(si{i,1}, sortDims);

            if all(loc)
              dimIds = sortDimsIx(loc);
              si{i,5} = netcdf.defVar(ncid, si{i,2}, si{i,4}, dimIds-1 ); 
            else
              % Most likely that user set property to 0xn variable. If so then no
              % problem. However, if none of the indeces is zero something strange
              % happened
              assert( all(si{i,1} > 0), ...
                'SAVE: Something strange happened. This should never happen.');
            end
          else
              si{i,5} = find(chk, 1)-1;
          end
        end

        % Close the def Part
        netcdf.endDef(ncid);

        % Put variable in f
        for i = 1: ix
          if ~any(si{i,1}==0)
            curobj = HDSManagedData(treeId).(HDSManagedData(treeId).classes{classId})(si{i,3}(1));
            data = curobj.(datProps{si{i,3}(2)});
            netcdf.putVar(ncid, si{i,5}, data);
            netcdf.sync(ncid);
            curobj.saveStatus = uint32(0);
            curobj.dataInMem(si{i,3}(2),1) = uint32(2);
          end
        end

        % Close the file.
        netcdf.close(ncid);
      end

    end

    toBeSaved(allCurFileId) = false;

    % Set the changeId flags to false for the saved objects.
    HDSManagedData(treeId).objBools(2, allCurFileId) = false;
  end

  % -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
  % -- -- -- Remove objects after REMOBJ   -- -- -- -- -- --
  
  % Iterate over unique FileLoc vectors that contain objects that should be deleted.
  uniqueRemFileIds = unique(HDSManagedData(treeId).remIds(1,:));
  for i = 1: length(uniqueRemFileIds)
    curFileId     = uniqueRemFileIds(i);
    locId         = HDSManagedData(treeId).locArray(:, curFileId);
    parentID      = locId(2); 
    
    % Find the Object IDs that need removed from current FileLoc
    indeces       = HDSManagedData(treeId).remIds(1,:) == curFileId;
    allCurObjIds  = HDSManagedData(treeId).remIds(2, indeces);

    % Get the pathstring to the current location.
    curLoc        = locId(end: -1: 1);
    curLoc        = curLoc(find(curLoc > 0, 1): end);
    curPath       = HDS.getPathFromLoc(curLoc, treeId);
    
    % Delete mat-file if all objects are removed. Mat-file should exist, check all object in file.
    % If only objects are the ones that should be deleted, delete file. Also check bin file and
    % remove the object from bin file. Check that bin file has no objects.
    % -- -- --
    
    % Find Bin-File.
    curBinFile  = fullfile(fileparts(curPath), [HDSManagedData.classes{curLoc(end)} '.bin']);
    fid         = fopen(curBinFile, 'r', 'l');
    NBStruct    = HDS.bin2struct(fread(fid, '*uint32'));
    fclose(fid);
    
    parentIdx   = find(NBStruct.parentIds == curLoc(end-1),1);
    
    if all(~NBStruct.childIDs(:,parentIdx))
    
      NBStruct.nrParents = NBStruct.nrParents -1;
      NBStruct.nrChildPP(parentIdx) = [];
      NBStruct.parentIds(parentIdx) = [];
      NBStruct.updateBools(parentIdx) = [];
      NBStruct.childIDs(:,parentIdx) = [];
      
      % save Bin file
      binVector = HDS.struct2bin(NBStruct);
      fid = fopen(curBinFile, 'w', 'l');
      fwrite(fid, binVector, 'uint32'); 
      fclose(fid);

      objInMat = mex_whofile([curPath '.mat']);
      IDs = zeros(length(objInMat),1,'uint32');
      for ii = 1: length(IDs)
        IDs(ii) = uint32(str2double(objInMat{ii}(2:end)));
      end
      if all(ismembc(IDs, sort(allCurObjIds)))
        display('Empty Mat file')
        delete([curPath '.mat']);
        try delete([curPath '.nc']); catch; end  %#ok<CTCH>
      else
        warning('HDS:save',['Trying to delete mat file with undeleted objects. '...
          'This should not be possible']);
      end

    end
    % -- -- --
    
    
    % Make sure path exists, if not, no problem but continue iteration.
    % Incase of exported database it is possible folder does not exist.
    if exist(curPath, 'dir')

      % Get files/folders names
      allFiles    = dir(curPath); 
      allNames    = {allFiles.name}; 
      isDir       = [allFiles.isdir];

      IDs = cellfun(@(x) regexp(x,'_[0-9]+','match','once'), ...
        allNames, 'UniformOutput',false);
      allClasses = cellfun(@(x) regexp(x,'[A-Za-z0-9]+','match','once'),...
        allNames, 'UniformOutput',false);

      % IDs is cellarray with all parentIDS that contain files.
      for j = 1: length(IDs)
        if ~isempty(IDs{j})
          IDs{j} = str2double(IDs{j}(2:end));
        end
      end

      IDs(cellfun('isempty', IDs)) = {0};

      % MatchIdx are all indeces in allFiles that belong to a removeobject.
      % Delete all folder/files belonging to removed objects.
      matchIdx = find(cellfun(@(x) any(x == allCurObjIds), IDs));
      for ii = 1:length(matchIdx)
        if isDir(matchIdx(ii))
          % Delete folder of children of children of the removed object.
          rmdir(fullfile(curPath, allNames{matchIdx(ii)}),'s');
        else
          % Delete mat file belonging to children of removed object.
          delete(fullfile(curPath, allNames{matchIdx(ii)}));
        end
      end

      %- Edit Bin File where removed IDs are parent Ids
      uniqueClasses = unique(allClasses(matchIdx)); % unique class names that contain removed obj.
      for ii = 1:length(uniqueClasses)

        binPath = fullfile(curPath,[uniqueClasses{ii} '.bin']);
        fid = fopen(binPath, 'r', 'l');
        aux = fread(fid, '*uint32');
        fclose(fid);

        binStruct = HDS.bin2struct(aux);
        remParentIds = find(ismembc(binStruct.parentIds, sort(allCurObjIds)));

        binStruct.parentIds(remParentIds)   = [];
        binStruct.nrChildPP(remParentIds)   = [];
        binStruct.childIDs(:,remParentIds)  = [];
        binStruct.updateBools(remParentIds) = [];
        binStruct.nrParents = length(binStruct.parentIds);

        newBinVector = HDS.struct2bin(binStruct);

        fid = fopen(binPath, 'w', 'l');
        fwrite(fid, newBinVector, 'uint32','l');
        fclose(fid);

        %delete bin file if number of parents ==0
        if binStruct.nrParents == 0
          delete(binPath);
        end
      end
    end

    % Look in parent directory and update the .NC files and remove data
    % associated with the object. 

    parentPath = fileparts(curPath);
    allFiles   = dir(parentPath); 
    allNames   = {allFiles.name}; 
    allNC      = ~cellfun('isempty', strfind(allNames,'.nc'));
    allNCNames = allNames(allNC);

    IDs = cellfun(@(x) regexp(x,'_[0-9]+','match','once'), allNCNames, 'UniformOutput',false);
    for j = 1: length(IDs)
      if ~isempty(IDs{j})
        IDs{j} = str2double(IDs{j}(2:end));
      end
    end
    IDs(cellfun('isempty',IDs)) = {0};
    matchIdx = find(cellfun(@(x) any(x == parentID), IDs));

    % Iterate over all class-files associated with parent.
    for ii = 1: length(matchIdx)
      ncid = netcdf.open(fullfile(parentPath,allNCNames{matchIdx(ii)}), 'NC_NOWRITE');
      chIndexVarid = netcdf.inqVarID(ncid, 'chIndexVec');
      fileChannelVec = netcdf.getVar(ncid, chIndexVarid);
      netcdf.close(ncid);

      % Find all subFiles locations
      locs = zeros(length(allCurObjIds),1);
      for iii = 1: length(allCurObjIds)
        isLoc = find(fileChannelVec(:,1) == allCurObjIds(iii),1);
        if ~isempty(isLoc)
          locs(iii) = fileChannelVec(isLoc,2);
        end
      end

      uniqueLocs = unique(locs);
      uniqueLocs(uniqueLocs==0) = [];

      for iii = 1:length(uniqueLocs)
        IDsInLoc = allCurObjIds(locs == uniqueLocs(iii));
        if uniqueLocs(iii) == 1
          filename = allNCNames{matchIdx(ii)};
          stripFileName = regexp(filename,'\.','split');
          stripFileName = stripFileName{1};
        else
          stripFileName = regexp(allNCNames{matchIdx(ii)},'\.','split');
          stripFileName = stripFileName{1};
          filename = sprintf('%s.%03d',stripFileName,uniqueLocs(iii));
        end

        ncid = netcdf.open(fullfile(parentPath,filename), 'NC_WRITE');
        netcdf.reDef(ncid);

        % Change data associated with removed ID to dummy variable.
        [~, nvars, ~, ~] = netcdf.inq(ncid);
        varNames = cell(nvars, 2);
        for iVar = 1: nvars
           [aux, ~, ~, ~]   = netcdf.inqVar(ncid, iVar-1);
           varNames(iVar,:) = regexp(aux, '_', 'split');
        end
        varNames(strcmp(varNames,'chIndexVec')) = {''};
        nrDummies = sum(cellfun(@(x) any(strfind(x,'dummy')),varNames(:,1)));

        IDSforIndex = str2double(varNames(:,2));

        for iv = 1: length(IDsInLoc)
          % Each ID can have multiple variables.
          varIndecesForID = find(IDSforIndex == IDsInLoc(iv));
          for v=1:length(varIndecesForID)
            % Rename the varible to dummyX
            dummyName = sprintf('dummy%i',nrDummies);
            netcdf.renameVar(ncid, varIndecesForID(v)-1, dummyName );
            nrDummies = nrDummies + 1;
            createdDummy = true;
          end
        end

        netcdf.putAtt(ncid, -1, 'hasDummyVars', 1);
        netcdf.close(ncid);
      end

      % Reopen parent nc file and:
      % 1) Update the chIndexVec by removing non-existing entries
      % 2) Find empty subNCfiles and reassign fileNames.
      % 3) Rename subNCfiles and delete unused files.

      % Create Cleanup object to prevent corupted database after CTR-C.            
      ncid            = netcdf.open(fullfile(parentPath, allNCNames{matchIdx(ii)}), 'NC_WRITE');
      chIndexVarid    = netcdf.inqVarID(ncid, 'chIndexVec');
      foundIdx        = ismembc(fileChannelVec(:,1),sort(double(allCurObjIds)));
      oldFileNr       = 1:max(fileChannelVec(:,2));


      fileChannelVec(foundIdx,:) = [];
      fileChannelVec  = [fileChannelVec ; zeros(sum(foundIdx),2)]; %#ok<AGROW>

      usedFiles = double(ismembc(oldFileNr,sort(fileChannelVec(:,2))));

      for iii = 1: length(oldFileNr)
        newFileNr(iii) = usedFiles(iii) * sum(usedFiles(1:iii)); %#ok<AGROW>
        %delete unused subNC files 
        if ~usedFiles(iii) && iii > 1
          try
            delete(fullfile(parentPath, sprintf('%s.%03d',stripFileName,iii)));
          catch ME %#ok<NASGU>
            warning('HDS:save','Expected file was missing in SAVE.');
          end
        end
      end

      changeVec = [oldFileNr' newFileNr'];
      changeVec(changeVec(:,2)==0,:) = [];
      for iii = 1: size(changeVec,1)
        if changeVec(iii,1) ~= changeVec(iii,2)
          oldFileName = sprintf('%s.%03d',stripFileName,changeVec(iii,1));
          newFileName = sprintf('%s.%03d',stripFileName,changeVec(iii,2));

          %Check if newFileName does not exist
          if exist(fullfile(parentPath,newFileName), 'file')
            fprintf(2,'HDS:SAVE  Trying to overwrite an existing NC-file. (This is a bug)');
            continue
          end
          movefile(fullfile(parentPath,oldFileName), fullfile(parentPath,newFileName));
          fileChannelVec(fileChannelVec(:,2)==changeVec(iii,1),2) = changeVec(iii,2);
          netcdf.putVar(ncid, chIndexVarid, fileChannelVec);
          netcdf.sync(ncid);
        end
      end

      netcdf.close(ncid);

    end

    % Check if folder is empty and remove if so.
    if exist(curPath,'dir')
      allFiles   = dir(curPath);
      allNames   = {allFiles.name};
      allNC      = ~cellfun('isempty', strfind(allNames,'.nc'));
      allMAT     = ~cellfun('isempty', strfind(allNames,'.mat'));
      allBIN     = ~cellfun('isempty', strfind(allNames,'.bin'));
      if ~any(allNC) && ~any(allMAT) && ~any(allBIN)
        rmdir(curPath,'s')
      end
    end
  end

  % -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  % -- -- -- Unmap HDSManagedData and remove remIds -- -- --
  HDSManagedData(treeId).remIds = zeros(3,0,'uint32');
  HDSManagedData(treeId).isSaving = false;
end

function cleanupCB()
  global HDSManagedData

  aux = find(HDSManagedData.isSaving);
  if ~isempty(aux)
    fprintf(2,'HDS:SAVE  Incorrect termination of SAVE method; data might be lost.\n\n');
    HDSManagedData(aux).isSaving = false;
  end
end
