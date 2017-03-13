function make_setdiff_tol

% function makefile
this_dir         = fileparts(mfilename('fullpath'));
matlab_root      = MATLAB_SVN_ROOT;
mex_support_root = fullfile(matlab_root,'mexSupport');

params.include_path = {mex_support_root};
params.lib_path     = {mex_support_root};
params.libs         = {};
params.objs         = {fullfile(mex_support_root,mexext,['MexSupport.',objext])};
params.src          = {};
params.target       = 'mex_ismember_tol.cpp';
params.flags        = {};

tmp    = regexp(params.target,'\.','once','split');
output = [tmp{1},'.',mexext];
params.output_dir = fullfile(fileparts(this_dir),tmp{1});
try 
    make(params)
catch ME
    simpleExceptionDisplay(ME);
    formattedWarning('Compile Failed')
end
