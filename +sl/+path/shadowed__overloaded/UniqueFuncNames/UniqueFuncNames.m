function Ok = UniqueFuncNames()
% Check uniqueness of function names
% If you install a large 3rd party toolbox, the file names may interfere with
% other installed toolboxes. This funtion compares the names of all M-, P- and
% Mex-files found in the Matlab path and displays non-unique names.
%
% P- and Mex-files with the same name as a corresponding M-file are accepted, if
% they are found in the same folder.
% Local subfunctions inside the M- or P-file and nested functions are not taken
% into account, because it is assumed, that a potential shadowing is wanted.
% Class paths as "\@cell" and package paths as "\+mypackage" are not considered
% in this version.
%
% INPUT:  None.
% OUTPUT: Logical flag, TRUE if the names are unique considering some
%   exceptions:
%   1. Files which are intentionally not unique:
%      "Contents.m" exists in each folder.
%      "prefspanel.m" exists in some folder to register control panels.
%      "messageProductNameKey" returns the product key for toolboxes.
%   2. Some user defined folders might contain functions, which are wanted to
%      shadow function of Matlab's or user define toolbox functions, e.g. to
%      improve them. Such folders must be inserted in a leading position in the
%      Matlab path. A further example is a folder, which contains Mex functions,
%      which are compiled for a specific Matlab version, e.g. if you run Matlab
%      6.5 (DLL) and 7 (MEXW32) simulataneously.
%   3. Further exceptions occur e.g. in Matlab 2009a:
%      \R2009a\toolbox\matlab\lang\function.m
%      \R2009a\toolbox\compiler\function.m
%      Exclude one of them using the full file name including the path.
%   The exceptions depend on your installed toolboxes and have to be adjusted to
%   your machine. The corresponding lines are marked by '###' in the source.
%
% NOTE: Modern Matlab versions display warnings, if a folder is added to the
%   path contains naming conflicts with built-in functions.
%   This function does not find all conflicts, e.g. for class paths. I'd
%   appreciate all comments and ideas for improvements and additions.
%
% Tested: Matlab 6.5, 7.7, 7.8
% Author: Jan Simon, Heidelberg, (C) 2010 matlab.THISYEAR(a)nMINUSsimon.de

% $JRev: R0e V:004 Sum:m3HI0r7m+VoH Date:10-Jun-2010 10:44:11 $
% $License: BSD - use, copy, modify, on own risk, mention the author $
% $File: Tools\GLSource\UniqueFuncNames.m $
% History:
% 001: 08-May-2010 17:29, Initial version.

% Initialize: ==================================================================
% Global Interface: ------------------------------------------------------------
% Matlab version considering the number 7.10, which is not 7.1:
MatlabV = round(sscanf(version, '%f', 1) * 100);

% Folders containing functions, which replace other functions intentionally:
% Examples:
% - Folder containing improved versions of Matlab's toolbox functions. Here this
%   is the folder inside the "Patch" folder.
% - Folders containing Mex functions compiled for different Matlab versions,
%   e.g. to avoid confusions between DLL and MEXW32 files.
%
% [ExcludeFolder] must be a {1 x N} cell string, absolute or relative path names,
% no trailing file separator: e.g. 'D:\MFiles\Tools\PatchMatlab76' or
% '\PatchMatlab76'.
% ### PATHS WITH INTENTIONAL SHADOWING -- PLEASE ADJUSTED TO YOUR MACHINE ###
if MatlabV > 706
   ExcludeFolder = {'Patch\Matlab7.8_PCWIN', 'Tools\Mex\WinXP_M76'};
elseif MatlabV == 650
   ExcludeFolder = {'Patch\Matlab6.5_PCWIN', 'Mex\WinXP_M65'};
else
   ExcludeFolder = {};
end
% ###

% Contents.m exists in each folder and some function names are intentionally not
% unique. [ExcludeFile] must be a {1 x N} cell string of function names without
% file extension.
% ### FILENAME EXCEPTIONS ###
ExcludeFile = {'Contents', 'prefspanel', 'messageProductNameKey'};
% ###

% There are some strange exceptions - define them as {N x 2} cell string with
% the path in the 1st column and the function name with extension in the 2nd.
% ### EXCEPTIONS FOR SPECIFIC FILES ###
ExcludeSpecial = {fullfile(matlabroot, 'toolbox', 'compiler'), 'function.m'};
% ###

% Initial values: --------------------------------------------------------------
MexExtension = ['.', mexext];
MExtension   = '.m';
PExtension   = '.p';

% Program Interface: -----------------------------------------------------------
% User Interface: --------------------------------------------------------------
% Do the work: =================================================================
% Get folders of the Matlab path as cell string:
PathC = dataread('string', path, '%s', 'delimiter', pathsep);

% Look for M, P and Mex files in these folders - but not in \private or \@class
% folders:
NameList    = {};
SpecialPath = ExcludeSpecial(:, 1);
for iP = 1:length(PathC)
   aPath = PathC{iP};
   if ~AnyRightCompare(ExcludeFolder, aPath)
      % Get file names:
      aDir  = dir(PathC{iP});
      aName = {aDir(~[aDir.isdir]).name};
      
      % Exclude some strange exceptions:
      excludeIndex = strcmpi(aPath, SpecialPath);
      if any(excludeIndex)
         aName(strcmpi(aName, ExcludeSpecial(excludeIndex, 2))) = [];
      end
      
      % Split file names to names and extensions:
      aExt = cell(1, length(aName));
      for iName = 1:length(aName)
         [aName{iName}, aExt{iName}] = strtok(aName{iName}, '.');
      end
      
      % Append M-, P- and Mex-functions of this folder to the list [MFiles]. The
      % M-scripts inside a folder can have equal names, but not if they are in
      % different folders!
      isMPMex = (strcmpi(aExt, MExtension) | ...
                 strcmpi(aExt, PExtension) | ...
                 strcmpi(aExt, MexExtension));
      if any(isMPMex)
         NameList = cat(2, NameList, unique(aName(isMPMex)));
      end
   end
end  % for iP

% Exclude files, which are intentionally not unique:
toDelete = false(size(NameList));
for iFile = 1:length(ExcludeFile)
   toDelete = or(toDelete, strcmpi(ExcludeFile{iFile}, NameList));
end
NameList(toDelete) = [];

% Check if the list is unique:
[uniqueNameList, uniqueInd] = unique(NameList);
if length(uniqueNameList) == length(NameList)  % Function names are unique:
   if nargout == 0
      fprintf('ok: %d functions checked to be unique.\n', length(NameList));
   else
      Ok = true;
   end
   
else  % Some function names are not unique:
   ambigNameList            = NameList;
   ambigNameList(uniqueInd) = [];
   fprintf('Conflicting files:\n');
   for iAmbig = 1:length(ambigNameList)
      aAmbig    = ambigNameList{iAmbig};
      whichFile = which(aAmbig, '-all');
      fprintf('-- %s:\n', aAmbig);
      fprintf('  %s\n', whichFile{:});
   end
   
   if nargout == 0
      fprintf('failed: %d functions checked, some are not unique.\n', ...
         length(NameList));
   else
      Ok = false;
   end
end

return;

% ******************************************************************************
function Found = AnyRightCompare(CStr, Str)
% Any string of CStr contains Str as trailing part.
% See also the Mex function STRNCMPIR published on the FEX.

flipStr = Str(length(Str):-1:1);
for iC = 1:length(CStr)
   Str2 = CStr{iC};
   if strncmpi(flipStr, Str2(length(Str2):-1:1), length(Str2))
      Found = true;
      return;
   end
end

Found = false;

return;

