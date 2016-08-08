function hdsexport(obj, option, varargin)
    %HDSEXPORT  Copies part of the database to another location.
    %   HDSEXPORT(OBJ) Copies object OBJ and all the objects linked as
    %   children in OBJ to a location specified by the user. It also
    %   exports all the parent object and all objects up to the host
    %   object.In other words, this will make a copy all objects from the
    %   host object to the OBJ object and copy all branches below the OBJ
    %   object.
    %
    %   HDSEXPORT(OBJ, 'full') The second input argument defines how the
    %   export should behave. When 'full' the method includes parents of
    %   OBJ in the exported files. This is the default value, and this will
    %   result the same as when the option is omitted.
    %
    %   HDSEXPORT(OBJ, 'add') This will add another branch to a previously
    %   exported folder structure. Adding branches can only be used with
    %   files previously exported with the 'full' option. In other words,
    %   the folder structure should include the host object of the
    %   database. You will have to specify the folder that contains the
    %   'HDSconfig.mat' file of the previously exported data set.
    %
    %   HDSEXPORT(OBJ, 'part') This will not include parent objects to the
    %   exported structure. This is the most compact way of exporting the
    %   database. In this case, the 'HDSconfig.mat' file that is normally
    %   found in the topmost folder will be saved in the folder containing
    %   OBJ.
    %
    %   HDSEXPORT(OBJ, OPTION, 'className', 'className', ...) One can
    %   specify one or more classes that further limit the number of
    %   exported objects. Only the children objects of OBJ that belong to
    %   the specified classes will be exported. OPTION should be one of the
    %   previously specified options for the method ('full' 'add' or
    %   'part').
    %
    %   HDSEXPORT(OBJ, OPTION, 'className', INDECES, 'className', ...) To
    %   even further limit the amount of exported objects, one can also
    %   specify the indeces of the children objects of class 'className'
    %   that should be included. You can specify this for multiple classes
    %   similar to the previous example. 
    %
    %
    %   Examples:
    %       HDSEXPORT(Main.exp(3).trial(5))  
    %           Exports all trial objects of the 3rd experiment and the
    %           children objects of trial 5 (including subsequent objects).
    %           It also exports the all experiment objects of Main and main
    %           itself. 
    %
    %       HDSEXPORT(Main.exp(3).trial(5), 'part') 
    %           Exports all trial objects of the 3rd experiment and all
    %           children objects (including subsequent childdren) of trial
    %           5. It does not export the parent objects of the trial
    %           objects.
    %
    %       HDSEXPORT(Main.exp(3).trial(5), 'part', 'KinData','SpikeData')
    %           Exports all trial objects of the 3rd experiment and all
    %           KinData and SpikeData objects (and subsequent children)
    %           linked in the 5th Trial object.
    %
    %       HDSEXPORT(Main.exp(3), 'full', 'Trial', [1 4 5])
    %           Exports all experiment objects of the Main object, all
    %           Trial objects of the 3rd experiment and any objects linked
    %           to the 1st, 4th and 5th Trial objects of the 3rd
    %           experiment.
    %
    %       HDSEXPORT(Main.exp(1),'add') 
    %           Adds the first experiment and all its children (including
    %           subsequent children) to a previously exported data set.    
    %   

    % Copyright (c) 2012, J.B.Wagenaar
    % This source file is subject to version 3 of the GPL license, 
    % that is bundled with this package in the file LICENSE, and is 
    % available online at http://www.gnu.org/licenses/gpl.txt
    %
    % This source file can be linked to GPL-incompatible facilities, 
    % produced or made available by MathWorks, Inc.
       
    global HDSManagedData
    
    % Check if obj is single object
    if length(obj)>1;
        throwAsCaller(MException('HDS:hdsexport','HDSEXPORT requires a single object as the input.'));
    end
    
    % Init; Check the inputs and prepare cellarray for dealing with children. 
    if nargin > 1
        
        if ~any(strcmp(option, {'full' 'add' 'part'}))
            throwAsCaller(MException('HDS:hdsexport','HDSEXPORT: Second input argument should be one of: ''full'' ''add'' or ''part''.'));
        end
        
        % Check for children input pairs. This populates childOption.
		hdspreventreg(true);
        tempObj = eval(class(obj));
		hdspreventreg(false);
        pChild = tempObj.childClasses;
        childOption = cell(length(pChild),2);
        if ~isempty(varargin)
            
            % Populate cell array with child classes and indeces. -1 is
            % reserved for all indeces.
            childOption = cell(length(varargin),2);
            ix = 1;
            while 1
                if any(strcmp(varargin{ix}, pChild))
                    childOption{ix,1} = varargin{ix};
                    
                    if ix < length(varargin)
                        if isnumeric(varargin{ix+1}) && isvector(varargin{ix+1})
                            
                            % Check indeces and populate childOption 2.
                            pForClass = propforclass(obj, varargin{ix}, false);
                            if ~isempty(pForClass)
                                if min(varargin{ix+1}) > 0 && max(varargin{ix+1}) <= length(subsref(obj,substruct('.',pForClass{1})))
                                    if length(unique(varargin{ix+1})) == length(varargin{ix+1})
                                        childOption{ix,2} = varargin{ix+1};
                                        ix = ix+2;
                                    else
                                        throwAsCaller(MException('HDS:hdsexport',sprintf('HDSEXPORT: Duplicate values in the indeces for objects of class %s.',upper(varargin{ix}))));
                                    end
                                else
                                    throwAsCaller(MException('HDS:hdsexport',sprintf('HDSEXPORT: Incorrect range for indeces for objects of class %s.',upper(varargin{ix}))));
                                end
                            else
                                throwAsCaller(MException('HDS:hdsexport',sprintf('HDSEXPORT: Object is not linked to children of type %s.', upper(varargin{ix}))));
                            end
                            
                        elseif ischar(varargin{ix+1})
                            pForClass = propforclass(obj, varargin{ix}, false);
                            if ~isempty(pForClass)
                                childOption{ix,2} = -1;
                                ix = ix+1;
                            else
                                throwAsCaller(MException('HDS:hdsexport',sprintf('HDSEXPORT: Object is not linked to children of type %s.', upper(varargin{ix}))));
                            end
                            
                        else
                            throwAsCaller(MException('HDS:hdsexport','HDSEXPORT: Incorrect input argument.'));
                        end
                    else
                        pForClass = propforclass(obj, varargin{ix}, false);
                        if ~isempty(pForClass)
                            childOption{ix,2} = -1;
                            ix = ix+1;
                        else
                            throwAsCaller(MException('HDS:hdsexport',sprintf('HDSEXPORT: Object is not linked to children of type %s.', upper(varargin{ix}))));
                        end
                    end
                else
                    throwAsCaller(MException('HDS:hdsexport',sprintf('%s is not a valid linked class for objects of type %s.', upper(varargin{ix}), class(tempObj))));
                end
                
                if ix> length(varargin)
                    break
                end
                
            end
        else
            ix = 1;
            for i = 1: length(pChild)
                pForClass = propforclass(obj, pChild{i}, false);
                if ~isempty(pForClass)
                    childOption(ix,:) = {pChild{i} -1};
                    ix = ix+1;
                end
            end
        end
        childOption = childOption(~cellfun('isempty', childOption(:,1)),:);

    else
        option = 'full';
		hdspreventreg(true);
        tempObj = eval(class(obj));
		hdspreventreg(false);
        pChild = tempObj.childClasses;
        childOption = cell(length(pChild),2);
        ix = 1;
        for i = 1: length(pChild)
            pForClass = propforclass(obj, pChild{i}, false);
            if ~isempty(pForClass)
                childOption(ix,:)= {pChild{i} -1};
                ix = ix+1;
            end
        end
        childOption = childOption(~cellfun('isempty', childOption(:,1)),:);
    end
    
    % Register obj if not previously registered.
    treeId = obj.treeNr;
    if ~treeId
        [obj, treeId] = registerObjs(obj, [], [], [],false); 
    end
    
    % Check:
    % 1) The database is completely saved to disk.
    % 2) The Database has no host offset.
    if any(HDSManagedData(treeId).objBools(1,:))
        throwAsCaller(MException('HDS:hdsexport','HDSEXPORT: Please save the database before trying to export the data.'));
    elseif HDSManagedData(treeId).treeConst(4) >0
        throwAsCaller(MException('HDS:hdsexport','HDSEXPORT: cannot export data from a previously exported or partial data set.'));
    end
    
    % Start message
    HDS.displaymessage('-- -- -- -- -- --',2,'\n','');
    
    % Get the Location of the new folder, or specify the HDSconfig.mat file.
    switch option
        case {'full' 'part'}
            fprintf('* Select an empty folder.\n');
            n = 1;
            while 1
                newPath = uigetdir('','Select an empty directory.');
                if newPath
                    list     = dir(newPath);
                    visfiles   = cellfun(@(x) x(1), {list.name}) ~= '.';
                    if ~any(visfiles)
                        break;
                    elseif n == 3
                        throwAsCaller(MException('HDS:hdsexport','Unable to export data, specified folder must be empty.'));
                    else
                        display('The selected folder must be empty.');
                    end
                    n = n + 1;
                else
                    fprintf('HDSEXPORT cancelled.\n');
                    HDS.displaymessage('-- -- -- -- -- --',2,'','\n');
                    return;
                end
            end
        case 'add'          
            fprintf('* Select the folder that contains the HDSconfig.mat file of the previously exported data.\n');
            n = 1;
            while 1
                newPath = uigetdir('','Select the folder containing the previously exported data.');
                fileName = 'HDSconfig.mat';
                if newPath
                    if exist(fullfile(newPath, fileName),'file')
                        cStruct1 = load(fullfile(HDSManagedData(treeId).basePath, fileName));
                        cStruct2 = load(fullfile(newPath, fileName));
                        
                        % Check if the saveIds are the same.
                        if cStruct1.saveId ~= cStruct2.saveId
                            if cStruct1.hostId == cStruct2.hostId
                                throwAsCaller(MException('HDS:hdsexport',['HDSEXPORT: The database has been changed on disk since exporting the selected data,'...
                                    ' adding data to an exported database is not possible when the original data has been changed.']));
                            else
                                throwAsCaller(MException('HDS:hdsexport','HDSEXPORT: The data in the selected folder does not belong to the same database as OBJ.'))
                            end
                        elseif n==3
                            throwAsCaller(MException('HDS:hdsexport','HDSEXPORT: Unable to export data, user did not specify correct ''HDSconfig.mat'' file.'));
                        end
                        
                        if cStruct1.isExport
                            throwAsCaller(MException('HDS:hdsexport','HDSEXPORT: It is not possible to export data from a previously exported dataset.'));
                        elseif ~cStruct2.isExport
                            throwAsCaller(MException('HDS:hdsexport','HDSEXPORT: The selected dataset is not a previously exported dataset but the source dataset itself.'));
                        end
                        
                        break
                    end
                    n = n + 1;
                else
                    fprintf('HDSEXPORT cancelled.\n');
                    HDS.displaymessage('-- -- -- -- -- --',2,'','\n');
                    return;
                end
            end
    end

    % Get object Path and index.
    [objPath, objIndex] = getpath(obj);
    
    basePath = HDSManagedData(treeId).basePath;
    stripPath = fileparts(objPath);
    pPart = cell(50, 1);
    ix=1;
    while ~strcmp(stripPath, basePath)
        [stripPath, pPart{ix}, ~] = fileparts(stripPath);
        ix = ix+1;
        if isempty(stripPath)
            throwAsCaller(MException('HDS:hdsexport','HDSEXPORT: Object path not a child folder of basePath, this should never happen.'));
        end
    end
    pPart = pPart(~cellfun('isempty',pPart));
       
  % -- Copy all parent objects and folders to new location.
    % In case of 'add' this will overwrite some of the files that are
    % currenly already there, this is okay because nothing changed in those
    % files anyways.
    if any(strcmp(option, {'full' 'add'}))
        newStripPath = newPath;
        for i = length(pPart): -1:1
            binfile = regexp(pPart{i},'[A-Za-z0-9]+','match','once');
            try 
                if ~exist(fullfile(newStripPath, [binfile '.bin']), 'file')
                    copyfile(fullfile(stripPath, [binfile '.bin']), newStripPath);
                end
                
                if ~exist(fullfile(newStripPath, [pPart{i} '.mat']), 'file')
                    copyfile(fullfile(stripPath,[pPart{i} '.mat']), newStripPath);
                end
                
            catch ME
                throwAsCaller(MException('HDS:hdsexport','HDSEXPORT: Cannot find the correct .bin or .mat file.'));
            end
            
            if ~exist(fullfile(newStripPath, [pPart{i} '.nc']), 'file')
                if exist(fullfile(stripPath,[pPart{i} '.nc']), 'file')
                    copyfile(fullfile(stripPath,[pPart{i} '.nc']), newStripPath); 
                end
            end

            if ~exist(fullfile(newStripPath, pPart{i}),'dir')
                mkdir(newStripPath, pPart{i});
            end
            
            newStripPath = fullfile(newStripPath, pPart{i});
            stripPath = fullfile(stripPath,pPart{i});
        end
        
        % Copy HDSconfig.mat to new path
        if ~exist(fullfile(newPath,'HDSconfig.mat'),'file')
            cStruct = load(fullfile(basePath,'HDSconfig.mat'));
            cStruct.isExport = true;
            save(fullfile(newPath,'HDSconfig.mat'),'-struct','cStruct');
        end
        
    else
        newStripPath = newPath;
    end  
    
  % -- Copy requested object files
    % copy mat and nc file
    copyfile([objPath '.mat'], newStripPath);
    try copyfile([objPath '.nc'], newStripPath); catch; end; %#ok<CTCH>
    
    % copy binary file
    [pPath, pFile, ~]  = fileparts(objPath);
    bFile = fullfile(pPath, [regexp(pFile,'[A-Za-z0-9]+','match','once') '.bin']);
    copyfile(bFile, newStripPath);
    
    
  % -- Copy children of OBJ
    
    if ~isempty(childOption)
        % Add folder of obj.
        [folder, file,~] = fileparts(objPath);
        
        if ~exist(fullfile(newStripPath, file),'dir')
            mkdir(newStripPath, file);
        end
        newStripPath = fullfile(newStripPath,file);

        % Get possible children filenames
        indexStr = sprintf('_%i', objIndex);
        for i = 1: size(childOption,1)
            
            % copy mat file
            copyfile(fullfile(folder,file,[childOption{i,1} indexStr '.mat']), newStripPath);
            
            % copy nc file
            if ~exist(fullfile(newStripPath, [childOption{i,1} indexStr '.nc']),'file')
                if exist(fullfile(folder,file,[childOption{i,1} indexStr '.nc']),'file')
                    copyfile(fullfile(folder,file,[childOption{i,1} indexStr '.nc']), newStripPath);
                end
            end
            
            % copy bin file
            copyfile(fullfile(folder, file, [childOption{i,1} '.bin']), newStripPath);
            
            % Add children of children
            if childOption{i,2} == -1
                % Add folder for children of children
                oFile = fullfile(folder, file, [childOption{i,1} indexStr]);
                nFile = fullfile(newStripPath, [childOption{i,1} indexStr]);
                if exist(oFile,'dir')
                    copyfile(oFile, nFile);
                end
                
            else
                % Add bin file for children of children
                if ~exist(fullfile(newStripPath, [childOption{i,1} indexStr]),'dir')
                    mkdir(newStripPath, [childOption{i,1} indexStr]);
                end
                
                % Find files of children of children
				hdspreventreg(true);
                tempObjChild = eval(childOption{i,1});
				hdspreventreg(false);
                pChildChild = tempObjChild.childClasses;
                
                % Add mat and nc file for children of children.
                for k = 1: length(pChildChild)
                    % Copy the bin file of children of children.
                    childFolder = fullfile(folder, file, [childOption{i,1} indexStr]);
                    newchildFolder = fullfile(newStripPath, [childOption{i,1} indexStr]);
                    
                    oFile = fullfile(childFolder, [pChildChild{k}  '.bin']);
                    nFile = fullfile(newchildFolder, [pChildChild{k}  '.bin']);
                    if exist(oFile,'file')
                        copyfile(oFile, nFile); 
                    end

                    
                    for j = 1: length(childOption{i,2})
                        childIndexStr = sprintf('_%i', childOption{i,2}(j));
                        
                        % Copy children of children
                        newchildFolder = fullfile(newStripPath, [childOption{i,1} indexStr]);
                        
                        oFile = fullfile(childFolder, [pChildChild{k} childIndexStr '.mat']);
                        nFile = fullfile(newchildFolder, [pChildChild{k} childIndexStr '.mat']);
                        if exist(oFile,'file')
                            copyfile(oFile, nFile); 
                        end
                        
                        oFile = fullfile(childFolder, [pChildChild{k} childIndexStr '.nc']);
                        nFile = fullfile(newchildFolder, [pChildChild{k} childIndexStr '.nc']);
                        if ~exist(nFile,'file')
                            if exist(oFile,'file')
                                copyfile(oFile, nFile);
                            end
                        end
                        
                        % Copy folder with children of children of children.
                        if exist(fullfile(childFolder, [pChildChild{k} childIndexStr]) ,'dir')
                            
                            if ~exist(fullfile(newchildFolder, [pChildChild{k} childIndexStr]),'dir')
                                mkdir(newchildFolder, [pChildChild{k} childIndexStr]);
                            end
                            
                            copyfile(fullfile(childFolder, [pChildChild{k} childIndexStr],'*'), fullfile(newchildFolder, [pChildChild{k} childIndexStr]) )
                        end

                    end
                end
                
                
            end
            
        end
    end
    
    fprintf('The data was succesfully exported.\n');
    HDS.displaymessage('-- -- -- -- -- --',2,'','\n');
    
end