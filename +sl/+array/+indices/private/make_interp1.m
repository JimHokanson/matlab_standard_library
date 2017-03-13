function make_interp1
% function makefile
this_dir    = fileparts(mfilename('fullpath'));
matlab_root = MATLAB_SVN_ROOT;
mex_support_root = fullfile(matlab_root,'mexSupport');

params.include_path     = {mex_support_root};
params.lib_path = {mex_support_root};
params.libs     = {''};
params.objs     = {fullfile(mex_support_root,['MexSupport.',objext])};
params.src      = {''};
params.target   = 'mex_interp1.cpp';
params.flags    = {};

tmp    = regexp(params.target,'\.','once','split');
output = [tmp{1},'.',mexext];
try
    make(params)
    dest_path = fullfile(fileparts(this_dir),output);
    if exist(dest_path,'file')
        delete(dest_path)
    end
    movefile(output,dest_path)
catch ME
    fprintf(2,'%s\n',ME.message);
    ME.stack(1)
    fprintf(2,'Compile Failed\n')
end
