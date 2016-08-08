function getShadowed(varargin)
%getShadowed
%
%   sl.path.getShadowed(varargin)
%
%   
%
%   Status: Incomplete
%
%   Improvements
%   -----------------------------------------------------------------------
%   1) Is it possible to add methods to a class from a different folder. It
%   definitely is possible to add functions to a package. I believe this is
%   possible. This means I need to examine the contents of classes as well.
%

%in.include_current_directory %Do we need this ...
in.ignore_within_mt_toolbox_shadowing = true;
in = sl.in.processVarargin(in,varargin);


%General notes:
%--------------------------------------------------------------------------
%- We'll probably eventually need to remove some of the code from this
%    function to somewhere else for package dependency handling ...
%- http://www.mathworks.com/help/matlab/functionlist.html
%   - This is a list of built-in functions ...
%   - Jan mentions warnings that are present on shadowing built-in
%   functions, is this true????


%Questions
%--------------------------------------------------------------------------
%1) What about detecting conflicts with built-ins?
%2) How do we handle precedence????


%Notes on the function what():
%--------------------------------------------------------------------------
%- m , p, mexw64 - have extensions ...
%- mex - seems to only register relevant extension. i.e. only mexw64
%   shows up on 64bit Windows, see mexext()
%- classes that are not in @ directories are not recognized as classes
%   but instead show up as m-files


%User considerations:
%--------------------------------------------------------------------------
%1) User might intentionally shadow something in the matlab folder
%2) Certain functions, like contents.m have special meaning
%3) 




%MLINT
%--------------------------
%#ok<*AGROW>







%TO TRACK
%--------------------------------------------
%1) Full paths     - needed for what()
%       - might also want for full path resolution ...
%
%   - anchor length ... - how long the lead in path is ...
%
%2) Relative paths - needed for comparision - might pull out later ...



%Startup
%--------------------------------------------------------------------------


%TODO: Now onto the comparison
%--------------------------------------------------------------------------


output = helper__getTheInfoYo(in);

u_obj = sl.cellstr.unique(output.full_rel_paths_without_ext);

%TODO: Need stable version of counts
%Also need stable group elements
u = u_obj.o_unique;
c = u_obj.o_unique_counts;
g = u_obj.o_group_indices;

mask = c > 1;

repeated_names  = u(mask);
repeated_groups = g(mask);
fs = filesep;

%full_rel_paths_with_ext

base_paths   = output.base_paths;
names_with_ext = output.names_with_ext;

keyboard

for iName = 1:length(repeated_names)
   I = repeated_groups{iName};
   fprintf('%s  ---------------------\n',repeated_names{iName})
   for iElem = 1:length(I)
       cur_I = I(iElem);
       fprintf('%s%s%s\n',base_paths{cur_I},fs,names_with_ext{cur_I});
   end
end



end

function output = helper__getTheInfoYo(in)
%
%
%   This will obviously need to be renamed ...
%   

switch length(mexext)
    case 3
        stripMex = @helper_stripMex3;
    case 6
        stripMex = @helper_stripMex6;
    case 9
        stripMex = @helper_stripMex9;
    otherwise
        error('Unrecognized mex extension: %s',mexext);
end



%??? Is the current directory on the path ?????
%This will eventually need to be moved
%
cur_paths    = sl.path.asCellstr();
what_struct  = cellfun(@what,cur_paths);  
from_counts  = @sl.array.genFromCounts;   %Create function alias

base_paths   = {};
rel_paths    = {};
types        = [];
names        = {};

file_sep_local     = filesep;
file_sep_with_plus = [file_sep_local '+'];

%Now for the loop
%--------------------------------------------------------------------------
n_elements = length(what_struct);
cur_rel_paths = repmat({''},n_elements,1);

done = false;
while ~done
    %Add on results to previous
    %----------------------------------------------------------------------

    %NOTE: We know paths because of our request
    %might remove this line ...
    paths      = {what_struct.path};
    
    n_elements    = length(what_struct);
    indices_input = 1:n_elements;
    
    classes    = vertcat(what_struct.classes);
    packages   = vertcat(what_struct.packages);
    
    m_files    = vertcat(what_struct.m);
    mex_files  = vertcat(what_struct.mex);
    p_files    = vertcat(what_struct.p);
    
    %This should ideally be a function ...
    %----------------------------------------------------------------------
    if ~isempty(m_files)
        n_m_total  = length(m_files);
        n_m        = arrayfun(@helper_getMLength,what_struct);
        m_indices  = from_counts(n_m, indices_input);
        
        
        base_paths = [base_paths    paths(m_indices)];
        rel_paths  = [rel_paths;    cur_rel_paths(m_indices)];
        types      = [types         ones(1,n_m_total)];
        names      = [names;        m_files];
    end
    
    if ~isempty(mex_files)
        n_mex_total  = length(mex_files);
        n_mex        = arrayfun(@helper_getMexLength,what_struct);
        mex_indices  = from_counts(n_mex, indices_input);
        
        base_paths = [base_paths    paths(mex_indices)];
        rel_paths  = [rel_paths;    cur_rel_paths(mex_indices)];
        types      = [types         2*ones(1,n_mex_total)];
        names      = [names;        mex_files];
    end
    
    if ~isempty(p_files)
       n_p_total   = length(p_files);
       n_p         = arrayfun(@helper_getPLength,what_struct);
       p_indices   = from_counts(n_p, indices_input);
       
       base_paths = [base_paths    paths(p_indices)];
       rel_paths  = [rel_paths;    cur_rel_paths(p_indices)];
       types      = [types         3*ones(1,n_p_total)];
       names      = [names;        p_files];
    end
    
%     if ~isempty(classes)
%         class_indices   = from_counts(n_classes,    indices_input);
%     end

    %Get results of next
    %----------------------------------------------------------------------
    if ~isempty(packages)
        %Extend package names ...
        n_packages_total = length(packages);
        n_packages       = arrayfun(@helper_getPackagesLength,what_struct);
        package_indices  = from_counts(n_packages, indices_input);
        
        cur_package_base_paths = paths(package_indices);
        cur_rel_paths          = cur_rel_paths(package_indices);
        
        %NOTE: Since package_indices are redundant,
        %we can remove some concatentation here ...
        
        %Get next set of request paths ...
        paths = cell(1,n_packages_total);
        for iPackage = 1:n_packages_total
           temp = [file_sep_with_plus packages{iPackage}];
           paths{iPackage} = [cur_package_base_paths{iPackage} temp];
           cur_rel_paths{iPackage}     = [cur_rel_paths{iPackage} temp];
        end
        
        what_struct  = cellfun(@what,paths);
    else
        done = true;
    end
end

%NOTE: This will be moved to a class with lazy evaluation ...
%--------------------------------------------------------------------------

%1   2   3
%m, mex, p 
names_without_ext = names;
names_without_ext(types == 1) = cellfun(@helper_stripM,names_without_ext(types == 1),'un',0);
names_without_ext(types == 2) = cellfun(stripMex,names_without_ext(types == 2),'un',0);
names_without_ext(types == 3) = cellfun(@helper_stripP,names_without_ext(types == 3),'un',0);
output.names_without_ext = names_without_ext;


full_rel_paths_with_ext    = rel_paths;
full_rel_paths_without_ext = rel_paths;
mask = cellfun('isempty',full_rel_paths_with_ext);
full_rel_paths_with_ext(mask) = names(mask);
full_rel_paths_without_ext(mask) = names_without_ext(mask);

for iPath = find(~mask)'
   full_rel_paths_with_ext{iPath} = [rel_paths{iPath} file_sep_local names{iPath}];
   full_rel_paths_without_ext{iPath} = [rel_paths{iPath} file_sep_local names_without_ext{iPath}];
end

output.full_rel_paths_with_ext = full_rel_paths_with_ext;
output.full_rel_paths_without_ext = full_rel_paths_without_ext;
output.base_paths     = base_paths';
output.types          = types;
output.names_with_ext = names;



end


% function output = helper__getClass(class_names)
%
% n_classes = length(class_names);
%
% for iClass = 1:n_classes
%     output = ['@'  class_names];
% end
% end

function len = helper_getClassesLength(w)
len = length(w.classes);
end
function len = helper_getPackagesLength(w)
len = length(w.packages);
end
function len = helper_getPLength(w)
len = length(w.p);
end
function len = helper_getMexLength(w)
len = length(w.mex);
end
function len = helper_getMLength(w)
len = length(w.m);
end
function name = helper_stripM(name)
   name(end-1:end) = [];
end
function name = helper_stripP(name)
   name(end-1:end) = [];
end
function name = helper_stripMex3(name)
   name(end-4:end) = [];
end
function name = helper_stripMex6(name)
   name(end-7:end) = [];
end
function name = helper_stripMex9(name)
   name(end-9:end) = [];
end




