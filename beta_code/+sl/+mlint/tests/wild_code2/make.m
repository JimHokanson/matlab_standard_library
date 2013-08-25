function make(make_params)
% MAKE Compile and Link a mexfile to spec
%
% make(make_params)
%
% PREPROCESSOR SYMBOLS
% =========================================================================
% Several Preprocessor symbols are provided automatically by this function
% Default:
%   RNEL_IS_MEX   - signals code is being compiled for mex
%
% One of the following is defined for the architecture
%   RNEL_IS_PC
%   RNEL_IS_MAC
%   RNEL_IS_UNIX
%
% Debug:
%   RNEL_MEX_DEBUG - signals that the '-g' flag is being used
%
% DEBUG MODE
% =========================================================================
%   If the user defines 'MEX_DEBUG' in their constants file all subsequent
%   calls to this function will produce code that has debug symbols ('-g')
%   and optimization ('-O') off.  This permits coordinate debugging across
%   multiple libraries without having to change every single make file (
%   and then accidentally commiting them)
%
% INPUTS
% =========================================================================
%   make_params - (struct)
%       include_path - (cell) paths to search for header files
%       lib_path     - (cell) paths to search for library files
%       lib          - (cell) library files to link against
%       obj          - (cell) object files to link against
%       src          - (cell) additional src to compile (other than target)
%       target       - (cell) compile target, must implement mex gateway function
%       compile_only - (logical) Optional. force compile only, output will
%           be an object not a mexfile. default: false
%       optim_flags  - (logical) Optional. specify '-g' to turn on debug symbols
%           and '-O'  for optimization. default: '-O'
%       output_dir   - (char) Optional. Destination of output. Defaults to
%           directory of calling function
%
% see also: mex, make_all
% tags: mex support

INCLUDE_PATH = make_params.include_path;
LIB_PATH     = make_params.lib_path;
LIBS         = make_params.libs;
OBJS         = make_params.objs;
SRC          = make_params.src;
TARGET       = make_params.target;
FLAGS        = make_params.flags;


C = getUserConstants;
if isfield(C,'MEX_DEBUG') && C.MEX_DEBUG
    % force debug mode
    OPTIM_FLAGS = '-g';
else
    OPTIM_FLAGS  = '-O';
    if isfield(make_params,'optim_flags')
        OPTIM_FLAGS    = make_params.optim_flags ;
    end
end
compile_only = false;
ext          = mexext;
if isfield(make_params,'compile_only') && make_params.compile_only
    compile_only = make_params.compile_only;
    ext          = objext;
end

tmp    = regexp(TARGET,'\.','once','split');
% Handle Output Directory
if ~isfield(make_params,'output_dir') ...
        || ( isfield(make_params,'output_dir') && isempty(make_params.output_dir))
    [~, calling_file, ~] = getCallingFunction;
    out_dir = fileparts(calling_file);
else 
    out_dir = make_params.output_dir;
end

OUTPUT   = [tmp{1},'.',ext];
out_path = fullfile(out_dir,OUTPUT);
createFolderIfNoExist(out_dir);

% remove any preexisting instances of the compiled file
if exist(OUTPUT ,'file') && ~isempty(which(OUTPUT))
    delete(which(OUTPUT ))
end

if exist(out_path ,'file') && ~isempty(which(out_path))
    delete(which(out_path ))
end

lib_str  = '';
if ~isempty(LIB_PATH)
    lib_str  = sprintf('-L"%s" ',LIB_PATH{:});
end

if ~isempty(LIBS)
    lib_str = [lib_str sprintf('-l%s ',LIBS{:})];
end

incl_str = '';
if ~isempty(INCLUDE_PATH)
    incl_str  = sprintf('-I"%s" ',INCLUDE_PATH{:});
end

obj_str = '';
if ~isempty(OBJS)
    obj_str  = sprintf('"%s" ',OBJS{:});
end

src_str = '';
if ~isempty(SRC)
    src_str  = sprintf('"%s" ',SRC{:});
end


% Add default flags for architecture. Similar flags no doubt exist for any given
% compiler, but we support like a million different ones so I'd rather
% just define my own

DEFAULT_FLAGS = {'RNEL_IS_MEX'};
if strcmp(OPTIM_FLAGS,'-g')
    DEFAULT_FLAGS = [DEFAULT_FLAGS 'RNEL_MEX_DEBUG'];
end

if  ispc
    DEFAULT_FLAGS = [DEFAULT_FLAGS 'RNEL_IS_PC'];
elseif ismac
    DEFAULT_FLAGS = [DEFAULT_FLAGS 'RNEL_IS_MAC'];
elseif isunix
    DEFAULT_FLAGS = [DEFAULT_FLAGS 'RNEL_IS_UNIX'];
end

FLAGS = [DEFAULT_FLAGS FLAGS];
if ~isempty(FLAGS)
    flags_str  = sprintf('-D%s ',FLAGS{:});
end

mex_cmd = 'mex';
if compile_only
    mex_cmd = 'mex -c';
end


mex_str = sprintf('%s %s "%s" -outdir ./ %s %s %s %s %s', ...
    mex_cmd, OPTIM_FLAGS,TARGET, lib_str, incl_str, obj_str, src_str, flags_str );
fprintf('Mex Cmd:\n');
fprintf('%s\n',forceWordWrap(mex_str));
fprintf('\n');
eval(mex_str)

% Note: For some reason the '-outdir' optional is utterly incapable of
% handling directories with spaces, even when guarded with quotes (")
% therefore I always output to pwd (./) and then move it
if ~strcmp(out_dir,pwd) && ~strcmp(out_dir,'./')
    [~,filename,ext] = fileparts(OUTPUT);
    movefile([filename,ext],out_dir)
end