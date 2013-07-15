function getShadowed()

%Important Notes:
%--------------------------------------------------------------------------
%1) what does not correctly identify classes that are not in @ directories.
%This is actually beneficial in our case but it might change ...
%2) 

%Built ins?
%Ordering if done in parallel?

cur_paths   = sl.path.asCellstr();

what_struct = cellfun(@what,cur_paths);

%NOTE: If we vertcat, then we need to keep track
%of what goes with what ...

n_classes  = arrayfun(@(x) length(x.classes),what_struct);
n_packages = arrayfun(@(x) length(x.packages),what_struct);
classes    = vertcat(what_struct.classes);
packages   = vertcat(what_struct.classes);
m_files    = vertcat(what_struct.m);
mex_files  = vertcat(what_struct.mex);
p_files    = vertcat(what_struct.p);



temp3 = sl.array.genFromCounts(n_classes,1:length(what_struct)); 

% mdl_files = vertcat(what_struct.mdl);
% slx_files = vertcat(what_struct.slx);


cur_start   = 1;

%For each set, get unique

 

end

function output = helper__getClass(class_names)
   
   n_classes = length(class_names);

   for iClass = 1:n_classes
      output = ['@'  class_names];
   end
end