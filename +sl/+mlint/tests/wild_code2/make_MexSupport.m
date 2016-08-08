function make_MexSupport

mex_support_root = fileparts(mfilename('fullpath'));
output_dir       = fullfile(mex_support_root,mexext);
createFolderIfNoExist(output_dir);
% MAKE MEXSUPPORT  ========================================================
params.include_path = {};
params.lib_path     = {};
params.libs         = {};
params.objs         = {};
params.src          = {};
params.target       = fullfile(mex_support_root,'MexSupport.cpp');
params.flags        = {};
params.compile_only = true;
params.output_dir   = output_dir;
[~,tmp] = fileparts(params.target);
output  = [tmp,'.',objext];
try
    make(params)
catch ME
    simpleExceptionDisplay(ME);
    formattedWarning('Compile Failed')
    return
end
% MAKE MEXSTRINGSUPPORT  ========================================================
params = [];
params.include_path = {};
params.lib_path     = {};
params.libs         = {};
params.objs         = {};
params.src          = {};
params.target       = fullfile(mex_support_root,'MexStringSupport.cpp');
params.flags        = {};
params.compile_only = true;
params.output_dir   = output_dir;
[~,tmp] = fileparts(params.target);
output  = [tmp,'.',objext];
try
    make(params)
catch ME
    simpleExceptionDisplay(ME);
    formattedWarning('Compile Failed')
    return
end
% MAKE MEX_TIMING_SUPPORT  ========================================================
params = [];
params.include_path = {};
params.lib_path     = {};
params.libs         = {};
params.objs         = {};
params.src          = {};
params.target       = fullfile(mex_support_root,'MexTimingSupport.cpp');
params.flags        = {};
params.compile_only = true;
params.output_dir   = output_dir;
[~,tmp] = fileparts(params.target);
output  = [tmp,'.',objext];
try
    make(params)
catch ME
    simpleExceptionDisplay(ME);
    formattedWarning('Compile Failed')
    return
end

% MAKE MEX_ALGORITM_SUPPORT ===============================================
params = [];
params.include_path = {};
params.lib_path     = {};
params.libs         = {};
params.objs         = {};
params.src          = {};
params.target       = fullfile(mex_support_root,'MexAlgorithmSupport.cpp');
params.flags        = {};
params.compile_only = true;
params.output_dir   = output_dir;
[~,tmp] = fileparts(params.target);
output  = [tmp,'.',objext];
try
    make(params)
catch ME
    simpleExceptionDisplay(ME);
    formattedWarning('Compile Failed')
    return
end

% MAKE SIZEOFTYPES ========================================================
params = [];
params.include_path = {mex_support_root};
params.lib_path     = {mex_support_root};
params.libs         = {};
params.objs         = {fullfile(mex_support_root,mexext,['MexSupport.',objext])};
params.src          = {};
params.target       = fullfile(mex_support_root,'mex_typesizes.cpp');
params.flags        = {};
params.compile_only = false;
[~,tmp]           = fileparts(params.target);
output            = [tmp,'.',mexext];
params.output_dir = fullfile(mex_support_root,tmp);
try
    make(params)
catch ME
    simpleExceptionDisplay(ME);
    formattedWarning('Compile Failed')
end
