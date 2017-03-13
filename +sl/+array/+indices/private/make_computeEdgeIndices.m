function make_computeEdgeIndices

this_dir         = fileparts(mfilename('fullpath'));
matlab_root      = MATLAB_SVN_ROOT;
mex_support_root = fullfile(matlab_root,'mexSupport');

% BUILD OBJ FILE ==========================================================
params.include_path = {mex_support_root};
params.lib_path     = {mex_support_root};
params.libs         = {};
params.objs         = {fullfile(mex_support_root,mexext,['MexSupport.',objext]) };
params.src          = {};
params.target       = 'computeEdgeIndices.cpp';
params.flags        = {};
params.output_dir   = fullfile(this_dir,mexext);
params.compile_only = true;

[~,tmp] = fileparts(params.target);
output  = [tmp,'.',objext];
try
    make(params)
catch ME
    simpleExceptionDisplay(ME);
    formattedWarning('Compile Failed')
end
% BUILD MEX FILE ==========================================================
params  = [];
params.include_path = {mex_support_root};
params.lib_path     = {mex_support_root};
params.libs         = {};
params.objs         = { ...
    fullfile(mex_support_root,mexext,['MexSupport.',objext]) ....
    fullfile(this_dir,mexext,['computeEdgeIndices.',objext])};
params.src          = {};
params.target       = 'mex_computeEdgeIndices.cpp';
params.flags        = {};
[~,tmp] = fileparts(params.target);
output  = [tmp,'.',mexext];
params.output_dir   = fullfile(fileparts(this_dir),tmp);
try
    make(params)
catch ME
    formattedWarning(ME.message);
    ME.stack(1)
    formattedWarning('Compile Failed')
end
