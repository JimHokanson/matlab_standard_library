function overloaded
%overloaded  Determines functions on the path that are shadowed.
%
%   overloaded()
%
%   STEPS:
%   ========================================
%   1) examine path and reduce to directory entries
%   2) remove @ and private directories (the resolution of these is
%       limited)
%   3) get all m files in each directory and see if they are already in 
%       a previous directory
%   4) go through and remove conflicts that are within Matlab toolboxes 
%       and are the on the ignore list (see function contents)
%   5) display shadowed functions in printout to command window
%
%   See Also: startup.m


%% Get a list of all of the M-files

%NOTE: We ignore these functions as well and don't show whether or not they
%are shadowed
IGNORE_LIST = {'Contents.m' 'install.m' 'demo.m'};


%NOTE: This code allows for placing filenames in a file that can also be
%ignored, the file should be in the same directory as this function, and
%should match the wildcard 'overloadedIgnore*'  Inside can be names of
%files that should not be reported in overloaded, as perhaps we are
%intentionally overloading a function

bP = fileparts(mfilename('fullpath'));
d = dir(fullfile(bP,'overloadedIgnore*'));
if length(d) == 1
    n = d(1).name;
    fileName = fullfile(bP,n);
    moreIgnore = stringToCellArray(fileread(fileName),'\n',true);
    moreIgnore = cellfun(@strtrim,moreIgnore,'UniformOutput',false);
    IGNORE_LIST = [IGNORE_LIST moreIgnore];
end

whatContents = getAllLibraryContents(true);

%IGNORE TOOLBOX CONFLICTS
%===============================================
tBoxPath      = fullfile(matlabroot,'toolbox');
lenTBoxPath   = length(tBoxPath);
isToolboxPath = cellfun(@(x) strncmpi(x,tBoxPath,lenTBoxPath),{whatContents.path});
whatContents(isToolboxPath) = [];

%GET DUPLICATES HERE
%================================================
%.m is a field of the m files in each valid directory ...
[vals,groups] = multi_intersect2(whatContents.m);

%REMOVE VALUES TO IGNORE 
%================================================
if ~isempty(vals)
    ignoreVals = ismember(vals,IGNORE_LIST);
    vals(ignoreVals) = [];
    groups(ignoreVals) = [];
end

%% Print list of repeats
if ~isempty(vals)
    fprintf('Shadowed/Overloaded functions:\n');
    fprintf('--------------------------------------------------------------\n');
    for i=1:length(vals)
        fprintf('FUNCTION: %s\n', vals{i})
        disp(cellArrayToString({whatContents(groups{i}).path},'\n',false))
    end
    fprintf('--------------------------------------------------------------\n');
end

end

