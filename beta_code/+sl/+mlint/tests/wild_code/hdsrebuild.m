function hdsrebuild(varargin)
  %HDSREBUILD  Checks and rebuilds config files for database.
  %   HDSREBUILD() Asks the user to specify the path using a file dialog
  %   window. It will rebuild the 'HDSconfig.mat' file if it does not
  %   exist and will check the number of objects in each .mat file in the
  %   data tree. It will generate an error report: 'HDSrebuildLog.txt' in
  %   which discrepancies are indicated. This file will be saved at the
  %   same location as the 'HDSconfig.mat' file at the base of the
  %   database
  %
  %   HDSREBUILD(PATH) The PATH can also be specified as an input
  %   variable of the method.
  %
  %   HDSREBUILD(..., '-full') will perform a more thorough check of all
  %   files comprising the database. In addition to checking the
  %   'hdsconfig.mat' file, it also checks the integrety of the
  %   'mat-files' and the 'bin-files'. This can take a long time to
  %   complete and errors are documented in the 'HDSrebuildLog.txt' file.
  %
  %   The method checks that the database:
  %
  %   1) contains classes with a unique class ID number.
  %   2) has a HDSconfig.mat file that is consistent with the data.
  %   3) does not specify classes that are unknown in the Matlab root.
  %
  %   When using the '-full' option, the function also checks that the:
  %
  %   1) BIN files exist for each class.
  %   2) MAT files contain all variables that are expected.
  %   3) Name of variables in MAT file corresponds with object ID.
  %   4) Objects in MAT files are represented in corresponding BIN file.
  %   5) Children objects are represented in BIN file in subfolder.
  %   6) Orphan Objects that are no longer linked in parent.
  %   7) Unexpected BIN and MAT files.

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.

  newConfig = struct('classes', '','hostId', nan, 'isExport', false, 'saveId', 1, 'idsNr',0);
  fid =[];
  cl1 = onCleanup(@()cleanup(fid));
  nrObjsChecked = 0;

  option = '-simple';
  switch nargin
    case 0
      PathName = uigetdir(pwd, 'Select the base folder of the database.');
    case 1
      assert(ischar(varargin{1}), 'HDSREBUILD: First input variable must be of type ''char''');
      if strcmp(varargin{1}, '-full')
        PathName = uigetdir(pwd, 'Select the base folder of the database.');
        option = '-full';
      else
        assert(exist(varargin{1}, 'dir') == 7, 'HDSREBUILD: Path does not exist.');
        PathName = varargin{1};
      end
    case 2
      assert(exist(varargin{1}, 'dir') == 7, 'HDSREBUILD: Path does not exist.');
      assert(strcmp(varargin{2},'-full'), 'HDSREBUILD:  Incorrect option for method.');
      PathName = varargin{1};
      option = varargin{2};
    otherwise
      error('Too many input arguments for HDSREBUILD method.');
  end
    
  % If HDSconfig does not exist, need to run in '-full' mode to find IDSnr.
  assert(exist(fullfile(PathName,'HDSconfig.mat'), 'file') || strcmp(option,'-full'), ...
    'HDSREBUILD: HDSconfig does not exist, run HDSRREBUILD using ''-full'' option.');
    
  % Maintain a running buffer of 100 elements for folders. If necessary,
  % the buffer is increased during the operation.
  folders     = cell(20,3);
  classes     = {};

  folders(1,1)  = {PathName};
  ix          = 1;    % active row.
  ix2         = 2;    % first available row
  firstRun    = true; % Used to init newConfig file

  % Open errorlog file 
  errorfid = fopen(fullfile(PathName, 'HDSrebuildLog.txt'),'w');

  % Write current date to errorlog.
  fprintf(errorfid, [datestr(clock) '\n']);

  % Set the message timer, this will show a message every two seconds
  % incidicating that the algorithm is still working.
  timer1 = clock;

  % Create boolean which indicates whether errors have been found and
  % message should be shown.
  foundErrors = false;
    
  dIx = 0;
  try
    while 1
      
      % -- Display progress every 2 seconds
      timer2 = clock;
      if etime(timer2, timer1) > 2
        d = '.';
        display(['Still working.' d(ones(1, abs(2*mod(dIx,5) - mod(dIx,10)))) ]);
        dIx = dIx+1;
        timer1 = timer2;
      end

      % -- Get Bin and Folder Names and Update Buffer --

      % Get all files in current folder
      allFiles    = dir(folders{ix,1}); 
      allNames    = {allFiles.name}; 

      % Remove HDSsearch folder and HDSconfig.mat.           
      allFiles(strcmp(allNames, 'HDSconfig.mat')) = [];
      allNames    = {allFiles.name}; 
      allFiles(strcmp(allNames, 'HDSsearch')) = [];
      allNames    = {allFiles.name}; 

      allDir      = find(cellfun(@(x) x(1),{allFiles.name}) ~= '.' & [allFiles.isdir] == true);
      allBin      = ~cellfun('isempty', strfind(allNames,'.bin'));

      % Check all binary filenames 
      binFiles    = allNames(allBin);
      folders{ix,2} = cellfun(@(x) regexp(x,'[A-Za-z0-9]+','match','once'), ...
        binFiles, 'UniformOutput',false);

      newIndeces = ix2 : (ix2 + length(allDir)-1);
      
      % Six possible scenarios for rotating buffer 
      % * is current loc,  # is first available free space.
      % ... is occupied indeces, _ free indeces, --- to be filled.
      %
      % ____*....#---->___  No problem   
      % ...#---->___*.....  No problem
      % --->____*......#--  Need to wrap new indeces
      % .....#----*-->....  Need to expand buffer
      % ---*->........#---  Need to expand and wrap
      % -------*------#->-  Need to expand and wrap
      
      tempwrap    = find(newIndeces > size(folders,1), 1);
      tempIndeces = newIndeces;
      if ~isempty(tempwrap)
        tempIndeces(tempwrap:end) = newIndeces(tempwrap:end) - size(folders,1);
      end
      
      % Expand rotating buffer if newindeces overlap current index.
      if any(newIndeces == ix) || any(tempIndeces == ix)
        nrAddRows = 5 + length(newIndeces);

        % Increase length folders buffer
        folders = [folders(1:(ix-1), :) ;cell(nrAddRows, 3); folders(ix:end,:)];
        if ix2 > ix
          newIndeces = newIndeces + nrAddRows;
        end
        ix  = ix + nrAddRows;
      end

      wrapIdx = find(newIndeces > size(folders,1), 1);
      if ~isempty(wrapIdx)
        newIndeces(wrapIdx:end) = newIndeces(wrapIdx:end) - size(folders,1);
      end
      
      folders(newIndeces, 1) = cellfun(@(x) fullfile(folders{ix,1}, x), ...
        allNames(allDir),'UniformOutput',false);
      
      % Update ix2; rotate if necessary.
      if ~isempty(newIndeces)
        ix2 = newIndeces(end) + 1;
        if ix2 > size(folders, 1)
          ix2 = 1;
        end
      end

      % -- Analyze Current Folder --

      % Check isExport and hostId during first iteration
      if firstRun
        % Find 1st mat file
        try
          allMatNames = allNames(~cellfun('isempty', strfind(allNames,'.mat')));
          matFile     = find(~cellfun('isempty', strfind(allMatNames, folders{ix,2}{1})),1);

          if ~isempty(matFile)
            aux = load(fullfile(folders{1,1}, allMatNames{matFile}));

            varNames = fieldnames(aux);
            for i = 1:length(varNames)
              if isa(aux.(varNames{i}),'HDS')
                newConfig.hostId = aux.(varNames{i}).objIds(4);
                if aux.(varNames{i}).objIds(1) ~= uint32(1)
                  newConfig.isExport = true;
                else
                  newConfig.isExport = false;
                end 

                % Add expected IDS in folders{:,3}--> per
                % child class: [classId Ids...]
                curObj = aux.(varNames{i});
                allChildPropIds = find(curObj.linkPropIds(2,:) == uint32(1));

                for ii = 1:length(allChildPropIds)
                  chClass = curObj.linkPropIds(1,allChildPropIds(ii));
                  chIdsForClass = curObj.linkIds(1,curObj.linkIds(2,:) == allChildPropIds(ii));
                  folders{ix,3}{ii} = [chClass chIdsForClass];
                end
                break

              end
            end
          else
            newConfig.isExport = true;
          end

          firstRun = false;
        catch ME
          fprintf(errorfid, ...
            'Init Problem: Unable to find any HDS objects in the selected folder.\n');
          error('HDS:hdsrebuild',['HDSREBUILD was unable to initiate rebuilding algorithm, '...
            'make sure that you select a folder on that generated with the HDS Toolbox.']);
        end
      end

      % Classes is cell array with classes that are generated from
      % disk to find the class-ids. 
      inClasses  = cellfun(@(x) any(strcmp(x, classes)), folders{ix,2});
      
      for i = 1:length(inClasses) 
        if ~inClasses(i)

          % Check if class definition exists
          try
            hdspreventreg(true);
            tempObj = eval(folders{ix,2}{i});
            hdspreventreg(false);
            if ~isa(tempObj, 'HDS')
              foundErrors = true;
              fprintf(errorfid,['Unknown Class: The filestructure suggest that ''%s'' '...
                'is a HDS class but this class is not defined in MATLAB.\n'],folders{ix,2}{i});
            end
          catch %#ok<CTCH>
            hdspreventreg(false);
            foundErrors = true;
            fprintf(errorfid, ['Unknown Class: The file-structure suggest that ''%s'' '...
              'is a HDS class but this class is not defined.\n'], folders{ix,2}{i});
          end

          % Check id with the binary file.
          try
            fid = fopen(fullfile(folders{ix,1},[folders{ix,2}{i} '.bin']),'r', 'l');
            aux = fread(fid, 3,  '*uint32');
            fclose(fid);
          catch ME %#ok<NASGU>
            foundErrors = true;
            fprintf(errorfid, 'Unable to open BIN file: %s\n', ...
            fullfile(folders{ix,1}, [folders{ix,2}{i} '.bin']));
            continue
          end


          if aux(3) > length(classes)
            classes{aux(3)} = folders{ix,2}{i}; %#ok<AGROW>
          elseif isempty(classes{aux(3)})
            classes{aux(3)} = folders{ix,2}{i}; %#ok<AGROW>
          elseif ~strcmp(classes{aux(3)}, folders{ix,2}{i})
            foundErrors = true;
            fprintf(errorfid, ['Double ID: Two classes (%s and %s) are assigned to ' ...
              'the same Class ID number. This means the database is seriously corrupted.\n'], ...
              classes{aux(3)}, folders{ix,2}{i} );
          end
        end
      end

      % -- Check integrity of the Files when method is called using the
      % '-Full' option.
      if strcmp(option, '-full')

        % Go over all mat-files in current folder.
        allMatNames = allNames(~cellfun('isempty', strfind(allNames,'.mat')));
        missingBinFiles = {};
        for iMat = 1: length(allMatNames) 

          % Check name to see if mat file contains classses. If it does, the name
          % should be in the classes array as this is populated earlier in the script.
          if any(cellfun(@(x) max([strfind(allMatNames{iMat},x) 0]) == 1, classes))

            % Check bin file in current folder for object IDs in MatFile.
            matName = regexp(allMatNames{iMat},'\w+','match','once');
            splitName = regexp(matName,'_','split');

            % Fix for main object.
            if length(splitName)==1
              splitName{2} = '1';
            end

            binFileName = [splitName{1} '.bin'];
            parentID = str2double(splitName{2});

            binFid = fopen(fullfile(folders{ix,1}, binFileName), 'r', 'l');

            % If binary file does not exist, check the 
            if binFid == -1
              if ~any(strcmp(fullfile(folders{ix,1}, binFileName), missingBinFiles))
                missingBinFiles{end+1} = fullfile(folders{ix,1}, binFileName); %#ok<AGROW>
                foundErrors = true;
                fprintf(errorfid,'Missing BIN-File: Unable to open: ''%s''.\n', ...
                  fullfile(folders{ix,1}, binFileName));
              end
              continue
            end

            aux = fread(binFid,'*uint32');
            fclose(binFid);
            
            binstruct = HDS.bin2struct(aux);
            
            % Check if matfile is represented in Bin file.
            index = find(parentID == binstruct.parentIds,1);
            if isempty(index)
              foundErrors = true;
              fprintf(errorfid, ['Inconsistent Bin File: Parent object ID: %i not present '...
                'in Bin file %s.\n'], parentID, fullfile(folders{ix,1}, binFileName));
              continue;
            end
            
            nrchild = binstruct.nrChildPP(index);
            expectedIds = binstruct.childIDs(1:nrchild,index);

            % Load all variables in MAT-File
            objs = load(fullfile(folders{ix,1}, allMatNames{iMat}));

            % Get indeces from variable names.
            varNames   = fieldnames(objs);
            varIndeces = str2double(cellfun(@(x) x(2:end), varNames, 'uniformOutput',false));

            % Get object Ids in Mat Files
            objectIDs = zeros(length(varIndeces),1,'uint32');
            for i = 1: length(objectIDs)
              objectIDs(i) = objs.(varNames{i}).objIds(1);
              nrObjsChecked = nrObjsChecked + 1; 
            end
            
            % Check that variable name is same as object ID
            if ~all(objectIDs == uint32(varIndeces))
              foundErrors = true;
              fprintf(errorfid, ['Inconsistent Mat File: Variable name does not' ...
                'correspond with object IDs: %s.\n'], fullfile(folders{ix,1}, allMatNames{iMat}));
            end
            
            % Check variable indecs
            if ~all(ismembc(objectIDs, sort(expectedIds)))
              foundErrors = true;
              fprintf(errorfid, 'Inconsistent Mat File: Matfile contains unexpected objects: %s.\n', ...
                fullfile(folders{ix,1}, allMatNames{iMat}));
            end
            
            if ~all(ismembc(expectedIds, sort(objectIDs)))
              foundErrors = true;
              fprintf(errorfid, 'Inconsistent Mat File: Not all objects present in: %s.\n', ...
                fullfile(folders{ix,1}, allMatNames{iMat}));
            end

            % Update max ID found in DB
            newConfig.idsNr = max([newConfig.idsNr ; objectIDs]);
            
            % Check if any children for current objs. and if so, does the child folder exist.
            anyChild = false;
            for iObj =1:length(varNames)
              curObj = objs.(varNames{iObj});
              %if any(curObj.linkIds(3,:) == uint32(0))
                
                % If first time find child, check folder exists, find which binary files exist
                % in child folder, and load all bin files.
                if ~anyChild
                  anyChild = true;                
                  childDir = fullfile(folders{ix,1}, regexp(allMatNames{iMat}, ...
                    '[A-Z_a-z0-9]+','match','once'));
                  if ~exist(childDir, 'dir')
                    if any(curObj.linkIds(3,:) == uint32(0))
                      foundErrors = true;
                      fprintf(errorfid, ['Missing Child Folder: The folder: %s, does not exist '...
                        'even though Child objects are defined in the parent.\n'], childDir);
                    end
                    break
                  end
                  
                  allCFiles    = dir(childDir); 
                  allCNames    = {allCFiles.name};        
                  allCBin      = ~cellfun('isempty', strfind(allCNames,'.bin'));
                  cClassNames   = regexp(allCNames(allCBin),'\w+','match','once');
                  
                  % Load all Binary files.
                  for i = 1: length(cClassNames)
                    binFilePath = fullfile(childDir, [cClassNames{i} '.bin']);
                    
                    % Error for missing BIN file generated elsewhere in code so just skip.
                    if ~exist(binFilePath, 'file') ; continue; end
                    
                    fid = fopen(binFilePath,'r','l');
                    binstruct(i) = HDS.bin2struct(fread(fid, '*uint32'));
                    fclose(fid);
                    
                    %Check if all matfiles exist.
                    for iParent = 1: binstruct(i).nrParents
                      matFileName = sprintf('%s_%d.mat', cClassNames{i}, ...
                        binstruct(i).parentIds(iParent));
                      forMatFile = fullfile(childDir, matFileName);
                      if ~exist(forMatFile,'file')
                        foundErrors = true;
                        fprintf(errorfid, ['Missing MAT-File: A MAT-File (''%s'') that is '...
                          'referenced in a BIN-file: %s, does not exist.\n'], ...
                          matFileName, binFilePath);
                      end
                    end
                    
                  end
                                    
                end
                
                % Get all the children for curObj that are referenced in a Binary file in child
                % folder.
                allChildForCurObj = [];
                for i = 1: length(binstruct)
                  curP = find(binstruct(i).parentIds == curObj.objIds(1),1);
                  if ~isempty(curP)
                    childIds = binstruct(i).childIDs(1:binstruct(i).nrChildPP(curP), curP);
                    allChildForCurObj = [allChildForCurObj ;childIds]; %#ok<AGROW>
                  end
                end
                
                % Now check children
                if anyChild && ~isempty(allChildForCurObj)
                  childObjIds = sort(curObj.linkIds(1, double(curObj.linkIds(3,:)) == uint32(0)));
                  findChildInBin = ismembc(childObjIds, sort( allChildForCurObj));
                  if ~all(findChildInBin) 
                    foundErrors = true;
                    fprintf(errorfid, ['Unmatched Object Ids: One or more children objects '...
                      'in %s, variable %s were linked in an object but could not be found in '...
                      'the associated binary file in child folder. .\n'], ...
                      fullfile(folders{ix,1}, allMatNames{iMat}), varNames{iObj} );
                  end
                  
                  findBinInMat = ismembc(allChildForCurObj, childObjIds);
                  if ~all(findBinInMat)
                    foundErrors = true;
                    fprintf(errorfid, ['Unmatched Bin Ids: One or more children objects '...
                      'defined in the binary file were not found in associated matlab object %s, '...
                      'of file %s.\n'], ...
                      varNames{iObj} ,fullfile(folders{ix,1}, allMatNames{iMat}) );
                  end
                  
                  
                end
              %end
            end
   
          else
            foundErrors = true;
            fprintf(errorfid, ['Unexpected MAT-File: Found MAT-file which name is not a '...
              'concatenation of a class name and a parentID: %s.\n'], fullfile(folders{ix,1}, ...
              allMatNames{i}));
            continue;
          end

        end

      end

      % -- Update ix and check ix == ix2 --  
      ix = ix + 1;
      if ix > size(folders,1)
        ix = 1;
      end

      % Break if the active index == the first available index.
      if ix == ix2; break; end;
    end
    newConfig.classes = classes';
  catch ME
    % Close the errorlog file
    fclose(errorfid);
    rethrow(ME);
  end

  newConfig.idsNr = newConfig.idsNr;

  % Check if there are any missing classNames. 
  emptyClasses = cellfun('isempty',classes);
  if any(emptyClasses)
    if newConfig.isExport
      fprintf(errorfid, ['Missing Class ID: HDSREBUILD could not determine'...
        'the class ID of all classes. Because DB is exported, this might not be a problem.\n']);
    else
      fprintf(errorfid, ['Missing Class ID: HDSREBUILD could not determine the class '...
        'ID of all classes.\n']);
    end
  end


  % Close the errorlog file
  fprintf(errorfid, '--- --- ---\n');
  fclose(errorfid);

  % -- Start display message
  HDS.displaymessage('-- -- -- -- -- --',2,'\n','');
  if foundErrors        
    fprintf('HDSREBUILD found some errors/warnings and logged them to: ''HDSrebuildLog.txt''.\n');
  end


  % -- Check if HDSconfig.mat already exists or save newConfig --
  if exist(fullfile(PathName,'HDSconfig.mat'), 'file')
    % Check existing file.
    aux = load(fullfile(PathName,'HDSconfig.mat'));

    oldClasses = aux.classes(~cellfun('isempty', aux.classes));
    newClasses = newConfig.classes(~cellfun('isempty', newConfig.classes));
    if length(oldClasses) == length(newClasses)
      checkCl = strcmp(oldClasses, newClasses);
    else
      checkCl = false;
    end
    checkHost = newConfig.hostId == aux.hostId;
    checkExport = newConfig.isExport == aux.isExport;
    if any(~checkCl) || ~checkHost || ~checkExport


      % -- Display message to user. 
      HDS.displaymessage(['The HDSconfig file that already exists in the location is '...
        'different from the HDSconfig structure generated by the HDSREBUILD method. '...
        'This can happen when the database is corrupted. It is suggested to keep the old '...
        'HDSconfig file and not update to the new HDSconfig file unless you are sure that '...
        'the old HDSconfig file is incorrect.'],2,'\n','\n');

      ii = 1;
      while 1
        y = input('Do you want to replace the file with an updated version? (y/n) ','s');
        if strcmp(y,'y')
          save(fullfile(PathName,'HDSconfig.mat'), '-struct','newConfig');
          fprintf('The current HDSconfig file has been replaced by the updated version.\n');
          break
        elseif strcmp(y,'n')
          fprintf('The old file has not been replaced.\n');
          break
        else
          if ii==3
            fprintf('The old file has not been replaced.\n');
            break
          end
        end
      end
      HDS.displaymessage('-- -- -- -- -- --',2,'','\n');

    else
      % -- Display message to user. 
      fprintf('HDSREBUILD verified the contents of the ''HDSconfig.mat'' file.\n');
      fprintf('Checked %d objects.\n',nrObjsChecked)
      HDS.displaymessage('-- -- -- -- -- --',2,'','\n');
    end

  else
    save(fullfile(PathName,'HDSconfig.mat'), '-struct','newConfig'); 
    % -- Display message to user. 
    fprintf('HDSREBUILD created a new HDSconfig file and saved it to the selected folder.\n');
    fprintf('Checked %d objects.\n',nrObjsChecked)
    HDS.displaymessage('-- -- -- -- -- --',2,'','\n');
  end
  
end

% The cleanup function is used to try to close an open file in case the
% HDSREBUILD is exitted incorrectly with CTR-C.
function cleanup(fid)  
  try
      fclose(fid);
  catch %#ok<CTCH>
  end
end
