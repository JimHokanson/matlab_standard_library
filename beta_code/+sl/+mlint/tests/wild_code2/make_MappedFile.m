function make_MappedFile
C = getUserConstants;
boost_include_dir = C.BOOST_ROOT;
boost_lib_dir     = fullfile(C.BOOST_ROOT,'build',mexext);
mex_support_root  = fullfile(MATLAB_SVN_ROOT,'mexSupport');
params = [];
params.include_path = {mex_support_root, boost_include_dir};
params.lib_path     = {mex_support_root, boost_lib_dir};
params.libs         = {};
params.objs         = {};
params.src          = {};
params.target       = fullfile(mex_support_root,'MexMappedFile.cpp');
params.flags        = {};
params.compile_only = true;
params.output_dir  = fullfile(mex_support_root,mexext);

try
    make(params)
catch ME
    simpleExceptionDisplay(ME);
    formattedWarning('Compile Failed')
end
