function [varargout] = addRecursively(strStartDir, caStrsIgnoreDirs, strXorIntAddpathMode, blnRemDirs, blnDebug)
% ADDPATH_RECURSE  Adds (or removes) the specified directory and its subfolders
%
%
%
%
% [paths] = addRecursively(strStartDir, caStrsIgnoreDirs, strXorIntAddpathMode, blnRemDirs, blnDebug)
%
% By default, all hidden directories (preceded by '.'), overloaded method
% directories and packages (preceded by '@' and '+'), mac indexing
% directories (preceded by '__') and directories named 'private' or 'CVS' are ignored.
%
% Input Variables
% ===============
% strStartDir::
%   Starting directory full path name.  All subdirectories (except ignore list) will be added to the path.
%   By default, uses current directory.
% caStrsIgnoreDirs::
%   Cell array of strings specifying directories to ignore.
%   Will also ignore all subdirectories beneath these directories.
%   By default, empty list. i.e. {''}.
% strXorIntAddpathMode::
%   Addpath mode, either 0/1, or 'begin','end'.
%   By default, prepends.
% blnRemDirs::
%   Boolean, when true will run function "in reverse", and
%   recursively removes directories from starting path.
%   By default, false.
% blnDebug::
%   Boolean, when true prints debug info.
%   By default, false.
%
% Output Variables
% ================
%  paths = list of folder added/removed to path
%
% Example(s)
% ==========
% (1) addpath_recurse();                                      %Take all defaults.
% (2) addpath_recurse('strStartDir');                         %Start at 'strStartDir', take other defaults. i.e. Do addpath().
% (3) addpath_recurse('strStartDir', '', 0, true);            %Start at 'strStartDir', and undo example (2). i.e. Do rmpath().
% (4) addpath_recurse('strStartDir', '', 'end', false, true); %Do example (2) again, append to path, and display debug info.
% (5) addpath_recurse('strStartDir', '', 1, true, true);      %Undo example (4), and display debug info.
%
% See Also
% ========
% addpath()
%
%   

%JAH TODO: Rewrite using getDirectoryTree.m
%JAH TODO: Rewrite using getDirectoryTree.m
%JAH TODO: Rewrite using getDirectoryTree.m
%JAH TODO: Rewrite using getDirectoryTree.m


in.dirs_ignore = {}; %caStrsIgnoreDirs
in = sl.in.proc






%--------------------------------------------------------------------------
% Error messages.
strErrStartDirNoExist      = 'Start directory does not exist ???';
strErrIgnoreDirsType       = 'Ignore directories must be a string or cell array. See HELP ???';
strErrIllAddpathMode       = 'Illegal value for addpath() mode.  See HELP ???';
strErrIllRevRecurseRemType = 'Illegal value for reverse recurse remove, must be a logical/boolean.  See HELP ??';

strErrWrongNumArg          = 'Wrong number of input arguments.  See HELP ???';
strAddpathErrMessage = strErrIllAddpathMode;

% Set input args defaults and/or check them.
intNumInArgs = nargin();
assert(intNumInArgs <= 5, strErrWrongNumArg);

% check if we received starting directory
if intNumInArgs < 1
    % we did not get the starting firectory
    % using current folder
    strStartDir = pwd();
end

% check if we got the list of dirs to ignore
if intNumInArgs < 2
    % no dirs to be ignored
    caStrsIgnoreDirs = {''};
end
if intNumInArgs >= 2 && ischar(caStrsIgnoreDirs)
    % convert dirs to be ignored in cell array if needed
    caStrsIgnoreDirs = { caStrsIgnoreDirs };
end

% check if we need to add paths at the beginning or at the end
if intNumInArgs < 3 || (intNumInArgs >= 3 && isempty(strXorIntAddpathMode))
    % default to beginning
    strXorIntAddpathMode = 0;
end
% verify and validate where to add path
if intNumInArgs >= 3 && ischar(strXorIntAddpathMode)  %Use 0/1 internally.
    strAddpathErrMessage = sprintf('Input arg addpath() mode "%s" ???\n%s', strXorIntAddpathMode, strErrIllAddpathMode);
    assert(any(strcmpi(strXorIntAddpathMode, {'begin', 'end'})), strAddpathErrMessage);
    strXorIntAddpathMode = strcmpi(strXorIntAddpathMode, 'end'); %When 'end' 0 sets prepend, otherwise 1 sets append.
end
% transpose ignore dir list
if size(caStrsIgnoreDirs, 1) > 1
    caStrsIgnoreDirs = caStrsIgnoreDirs'; %Transpose from column to row vector, in theory.
end

% set default for remove flag
if intNumInArgs < 4
    blnRemDirs = false;
end

% set default for debug flag
if intNumInArgs < 5
    blnDebug = false;
end

% Check input args OK, before we do the thing.
strErrStartDirNoExist = sprintf('Input arg start directory "%s" ???\n%s', strStartDir, strErrStartDirNoExist);
assert(exist(strStartDir, 'dir') > 0, strErrStartDirNoExist);
assert(iscell(caStrsIgnoreDirs), strErrIgnoreDirsType);
assert(strXorIntAddpathMode == 0 || strXorIntAddpathMode == 1, strAddpathErrMessage);
assert(islogical(blnRemDirs), strErrIllRevRecurseRemType);
assert(islogical(blnDebug), 'Debug must be logical/boolean.  See HELP.');

% check if we need to debug
if blnDebug
    
    intPrintWidth = 34;
    rvAddpathModes = {'prepend', 'append'};
    strAddpathMode = char(rvAddpathModes{ fix(strXorIntAddpathMode) + 1});
    strRevRecurseDirModes = { 'false', 'true' };
    strRevRecurseDirs = char(strRevRecurseDirModes{ fix(blnRemDirs) + 1 });
    strIgnoreDirs = '';
    for intD = 1 : length(caStrsIgnoreDirs)
        if ~isempty(strIgnoreDirs)
            strIgnoreDirs = sprintf('%s, ', strIgnoreDirs);
        end
        strIgnoreDirs = sprintf('%s%s', strIgnoreDirs, char(caStrsIgnoreDirs{intD}));
    end
    strTestModeResults = sprintf('... Debug mode, start recurse addpath arguments ...');
    strTestModeResults = sprintf('%s\n%*s: "%s"', strTestModeResults, intPrintWidth, 'Start directory', strStartDir);
    strTestModeResults = sprintf('%s\n%*s: "%s"', strTestModeResults, intPrintWidth, 'Ignore directories', strIgnoreDirs);
    strTestModeResults = sprintf('%s\n%*s: "%s"', strTestModeResults, intPrintWidth, 'addpath() mode', strAddpathMode);
    strTestModeResults = sprintf('%s\n%*s: "%s"', strTestModeResults, intPrintWidth, 'Reverse recurse remove directories', strRevRecurseDirs);
    disp(strTestModeResults);
    
end

% Don't print the MATLAB warning if remove path string is not found
if blnRemDirs,
    warning('off', 'MATLAB:rmpath:DirNotFound');
end


% Force the flag option to be numeric, for later handling in an 'if' statement
if ischar(strXorIntAddpathMode)
    switch strXorIntAddpathMode
        case 'begin'
            strXorIntAddpathMode = 0;
        case 'end'
            strXorIntAddpathMode = 1;
        otherwise
            error(['Incorrect option for strXorIntAddpathMode: ' strXorIntAddpathMode])
    end
end

% prepare list of subfolders
pathsOut = addpath_recursively(strStartDir, caStrsIgnoreDirs, strXorIntAddpathMode, blnRemDirs,blnDebug,{});

if ~isempty(pathsOut)
    if blnRemDirs
        rmpath(pathsOut{:})
    else
        addpath(pathsOut{:},strXorIntAddpathMode)
    end
end

% Restore the warning state for rmpath
if blnRemDirs,
    warning('on', 'MATLAB:rmpath:DirNotFound');
end

% takes care of the output
if nargout > 0,
    varargout{1} = pathsOut;
end

end % function addpath_recurse

function pathsOut = addpath_recursively(strStartDir, caStrsIgnoreDirs, strXorIntAddpathMode, blnRemDirs, blnDebug, pathsIn)
% Note:Don't need to check input arguments, because caller already has.

% Remove or add the directory from the search path
if blnRemDirs
    % remove paths
    if blnDebug,
        % debug message
        disp(sprintf('"%s", removing from search path ...', strStartDir));
    end
    pathsIn = [pathsIn {strStartDir}];
    
else
    % add paths
    if blnDebug,
        % debug message
        disp(sprintf('"%s", adding to search path ...', strStartDir));
    end
    if strXorIntAddpathMode
        % I'm not sure if I am handling this right
        pathsIn = [{strStartDir} pathsIn];
    else
        pathsIn = [pathsIn {strStartDir}];
    end
    
end

strFileSep = filesep();
% Get list of directories beneath the specified directory
saSubDirs = dir(strStartDir);
saSubDirs = saSubDirs([saSubDirs.isdir]);

% Loop through the directory list and recursively call this function.
for intDirIndex = 1 : length(saSubDirs)
    % get dir name
    strThisDirName = saSubDirs(intDirIndex).name;
    
    % define if current folder has to be ignored
    blnIgnoreDir = any(strcmpi(strThisDirName, [{'private', 'CVS', '.', '..','__MACOSX'} caStrsIgnoreDirs ]));
    % check if current folder start with @, . or +
    blnDirBegins = any(strncmp(strThisDirName, {'@', '.', '+'}, 1));
    % import this fodler only if it is eligible
    if ~(blnIgnoreDir || blnDirBegins)
        % build full path for current folder
        strThisStartDir = sprintf('%s%s%s', strStartDir, strFileSep, strThisDirName);
        if blnDebug,
            % debug message
            disp(sprintf('"%s", recursing ...', strThisStartDir));
        end
        % recursive call to analyse all the directory structure
        pathsIn = addpath_recursively(strThisStartDir, ...
            caStrsIgnoreDirs, ...
            strXorIntAddpathMode, ...
            blnRemDirs, ...
            blnDebug, ...
            pathsIn);
    end
end % for each directory.

% transfer dir list to output
pathsOut = pathsIn;
end % function addpath_recursively

