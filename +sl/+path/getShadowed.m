function getShadowed(varargin)
%
%
%   sl.path.getShadowed(varargin)

in.ignore_mt_toolbox_shadowing = true;
in = sl.in.processVarargin(in,varargin);


%General notes:
%--------------------------------------------------------------------------
%- We'll probably eventually need to remove some of the code from this
%    function to somewhere else for package dependency handling ...
%- http://www.mathworks.com/help/matlab/functionlist.html
%   - This is a list of built-in functions ...
%   - Jan mentions warnings that are present on shadowing built-in
%   functions, is this true????
%   - 

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


%Function Precedence Order
%--------------------------------------------------------------------------
%http://www.mathworks.com/help/matlab/matlab_prog/function-precedence-order.html
%1 - built-in function
%2 - mex
%3 - p file
%4 - m file
%
%   class over package ...

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
cur_paths    = sl.path.asCellstr();
what_struct  = cellfun(@what,cur_paths);
from_counts  = @sl.array.genFromCounts;
is_first_run = true;

base_paths   = {};
rel_paths    = {};
types        = [];
names        = {};

file_sep_local    = filesep;
filesep_with_plus = [file_sep_local '+'];

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
    
    if ~isempty(m_files)
        n_m_total  = length(m_files);
        n_m        = arrayfun(@helper_getMLength,what_struct);
        m_indices  = from_counts(n_m, indices_input);
        
        base_paths = [base_paths    paths(m_indices)];
        rel_paths  = [rel_paths;     cur_rel_paths(m_indices)];
        types      = [types         ones(1,n_m_total)];
        names      = [names;         m_files];
    end
    
    if ~isempty(mex_files)
        n_mex_total  = length(mex_files);
        n_mex        = arrayfun(@helper_getMexLength,what_struct);
        mex_indices  = from_counts(n_mex, indices_input);
        
        base_paths = [base_paths    paths(mex_indices)];
        rel_paths  = [rel_paths;     cur_rel_paths(mex_indices)];
        types      = [types         2*ones(1,n_mex_total)];
        names      = [names;         mex_files];
    end
    
    if ~isempty(p_files)
       n_p_total   = length(p_files);
       n_p         = arrayfun(@helper_getPLength,what_struct);
       p_indices   = from_counts(n_p, indices_input);
       
       base_paths = [base_paths    paths(p_indices)];
       rel_paths  = [rel_paths;     cur_rel_paths(p_indices)];
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
           temp = [filesep_with_plus packages{iPackage}];
           paths{iPackage} = [cur_package_base_paths{iPackage} temp];
           cur_rel_paths{iPackage}     = [cur_rel_paths{iPackage} temp];
        end
        
        what_struct  = cellfun(@what,paths);
    else
        done = true;
    end
end

full_rel_paths = rel_paths;
mask = cellfun('isempty',full_rel_paths);
full_rel_paths(mask) = names(mask);

for iPath = find(~mask)'
   full_rel_paths{iPath} = [rel_paths{iPath} file_sep_local names{iPath}]; 
end



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



