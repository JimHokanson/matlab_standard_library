function varargout = hdsdefrag(obj)                                           
  %HDSDEFRAG  Minimizes disk-space occupied by '.nc' files.
  %   HDSDEFRAG(OBJ) checks all .nc files in the data tree associated
  %   with OBJ and defragments the .nc files when previous save commands
  %   resulted in unused data in the files. This is the normal behavior
  %   for the save commands as it is programmed for speed and not for
  %   file size efficiency. The HDSDEFRAG method will optimize the saved
  %   files which will result in smaller files.
  %
  %   see also: HDS.save

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  global HDSManagedData

  % Check if obj is single object
  assert(length(obj) == 1, 'HDSDEFRAG: Method requires a single object as input.');

  % Register object if not previously registered.
  treeId = obj.treeNr;
  if ~treeId; [~, treeId] = registerObjs(obj); end

  % Check if the data belonging to OBJ is saved to disk.
  if isempty(HDSManagedData(treeId).basePath)
    display('The object does not belong to a database that has previously been saved to disk.')
    if nargout; varargout{1} = false; end
    return
  end

  % Having rotating buffer with bin files that should be checked 
  ix      = 1;    % current Idx
  ix2     = 2;    % next writeIdx
  fCheck  = cell(1000, 1);

  % Get .bin file
  bin = dir(fullfile(HDSManagedData(treeId).basePath,'*.bin'));
  assert(length(bin)==1, ['HDSDEFRAG: There are multiple ''.bin'' files at the '...
    'basePath of the database, this should not be possible']);

  % Set the first entry in the FileCheck cell array to be the base-path.
  fCheck{1} = fullfile(HDSManagedData(treeId).basePath, bin.name);
  while ix~=ix2;

    % Check current file
    curFile   = fCheck{ix};
    [curFolder, fldnam, ~] = fileparts(curFile);

    % Iterated over all '.nc' files and check if there are dummy variable in the file. 
    % If so, rewrite the file excluding the dummy variables.
    nc = dir(fullfile(curFolder, sprintf('%s*.nc', fldnam)));
    for iNc = 1: length(nc)

      baseNCname = regexp(nc(iNc).name,'\.','split');
      iName = 0;

      while 1
        iName = iName+1;
        if iName == 1
          curNCName = fullfile(curFolder, [baseNCname{1} '.nc']);
        else
          curNCName = fullfile(curFolder, [baseNCname{1} sprintf('.%03d',iName)]);
        end

        if ~exist(curNCName,'file')
          break;
        end

        ncid = netcdf.open(curNCName,'NC_NOWRITE');
        hasDummy = netcdf.getAtt(ncid, -1, 'hasDummyVars');

        % Resave the NC file if the file contains dummy variables.
        if hasDummy

          % Create dummy file which will be new file 
          ncid2 = netcdf.create(fullfile(curFolder,'HDStemp_nc.nc'), 512); % 512 is NC_64BIT_OFFSET 
          netcdf.putAtt(ncid2, -1, 'hasDummyVars', 0)

          % Get fileInfo from old file
          [ndims,nvars,~,~] = netcdf.inq(ncid);
          dims = cell(ndims,2); 
          for iDim = 1:ndims
            [dims{iDim,1}, dims{iDim,2}] = netcdf.inqDim(ncid,iDim-1);
          end
          vars = cell(nvars,4);
          for iVar = 1:nvars
            [vars{iVar,1}, vars{iVar,2}, vars{iVar,3},~] = netcdf.inqVar(ncid,iVar-1);
            vars{iVar,4} = iVar-1;
          end
          nam = vars(:,1);
          vars = vars(cellfun(@(x) isempty(strfind(x,'dummy')), nam),:);
          uniqueDims  = unique([vars{:,3}]);
          removedDims = find(~ismembc(0:(ndims-1), sort(uniqueDims)))-1;

          % Define new dimensions and variables
          for iDim = 1:length(uniqueDims)
            netcdf.defDim(ncid2, dims{uniqueDims(iDim)+1, 1}, dims{uniqueDims(iDim)+1, 2});
          end

          % Create new DIM and VAR variables in nc file.
          for iVar = 1:size(vars,1)
            newDims = vars{iVar,3};
            if ~isempty(removedDims)
              for ii = 1: length(newDims)
                newDims(ii) = newDims(ii) - sum(removedDims<newDims(ii));
              end
            end
            netcdf.defVar(ncid2, vars{iVar,1}, vars{iVar,2}, newDims);
          end
          netcdf.endDef(ncid2);

          % Copy the data to the new file.
          for iVar = 1:size(vars,1)
            data = netcdf.getVar(ncid, vars{iVar, 4});
            netcdf.putVar(ncid2, iVar-1, data)
          end
          
          %Close both nc files
          netcdf.close(ncid2);
          netcdf.close(ncid);

          % Delete old nc file and rename new nc file.
          delete(curNCName);
          movefile(fullfile(curFolder,'HDStemp_nc.nc'), curNCName);
        else
          netcdf.close(ncid); 
        end
      end

    end

    % Find folders 
    fld = dir(fullfile(curFolder, sprintf('%s*',fldnam)));
    fld = {fld([fld.isdir]).name};

    % Find possible children in fld
    for iFolder = 1: length(fld)
      bin = dir(fullfile(curFolder, fld{iFolder}, '*.bin'));
      for iBin = 1: length(bin)
        fCheck{ix2} = fullfile(curFolder,fld{iFolder},bin(iBin).name);
        ix2 = ix2+1;
      end
    end

    ix = ix+1;
  end
end
