function mmake(varargin)
%MMAKE A minimal subset of GNU make, implemented in MATLAB for MATLAB.
%   GNU Make "is a tool which controls the generation of executables and 
%   other non-source files of a program from the program's source files.
%   Make gets its knowledge of how to build your program from a file called
%   the makefile, which lists each of the non-source files and how to 
%   compute it from other files." For details see: www.gnu.org/software/make
%
%   Only a minimal subset of GNU Make features are implemented. Notably:
%   - Makefile parsing (looks for MMakefile by default)
%       - Immediate assignments (var := value)
%       - Variable expansion via ${var} or $(var)
%       - The basic make 'rule' syntax (target : dependencies, followed by
%         tabbed MATLAB commands)
%       - Wildcards in targets (*.x : common.h)
%       - Pattern rules (%.x : %.y)
%       - Auto variables in rule commands:
%           - $@ = the target
%           - $< = first dependency
%           - $^ = all dependencies (with duplicates removed)
%           - $+ = all dependencies (in the exact order they are listed)
%           - $* = the pattern matched by '%' in a pattern rule
%           - $& = the directory of the target
%       - MATLAB command expansion via $(eval cmd) or ${eval cmd}. The
%           string 'cmd' is evaluated directly within MATLAB.  It must return a
%           value of type char or a cell array of chars. In the event that a
%           multidimensional array or cell array is returned, all elements are
%           concatenated together with a space in between.
%       - As a convenience, the variable ${MEX_EXT} defaults to the result
%           of ${eval mexext}.
%   - Implicit rules
%       - %.${MEX_EXT} is automatically built with 'mex' from %.c or %.cpp
%       - %.o/%.obj is automatically built with 'mex' from %.c or %.cpp
%       - %.dlm is automatically built with rtwbuild('%')
%   - KNOWN BUGS/DEFICIENCIES
%       - Needs MMakefile parsing error handling
%
%   When called without any arguments, MMAKE searches the current working
%   directory for a file named 'MMakefile' and builds the first target
%   listed. With one argument, it builds that target from any rules listed
%   in 'MMakefile' (if it exists in the current working directory) or the
%   implicit rules. The optional second argument may be used to specify a
%   MMakefile in another directory or saved as a different name.
%
%   Matt Bauman, 2010. mbauman@gmail.com.


%% Argument parsing and setup
wd = '';
if (nargin == 0)
    state = read_mmakefile('MMakefile');
    if (isempty(state))
        error('mmake: *** No targets specified and no mmakefile found.  Stop.')
    end
    target = state.rules(1).target{1};
elseif (nargin == 1)
    target = varargin{1};
    state = read_mmakefile('MMakefile');
elseif (nargin == 2)
    target = varargin{1};
    state = read_mmakefile(varargin{2});
    if (isempty(state))
        error(['mmake: MMakefile (', varargin{2},') not found']);
    end
    [mmakefile_dir,~,~] = fileparts(varargin{2});
    fprintf('Entering directory %s\n', mmakefile_dir);
    wd = cd(mmakefile_dir);
else
    error 'mmake: Wrong number of input arguments';
end

%% Implicit rules... TODO: do this better.
idx = 1;
state.implicitrules(idx).target   = {['%.' mexext]};
state.implicitrules(idx).deps     = {'%.c'};
state.implicitrules(idx).commands = {'mex ${CFLAGS} $< -output $@'};
idx = idx+1;
state.implicitrules(idx).target   = {['%.' mexext]};
state.implicitrules(idx).deps     = {'%.cpp'};
state.implicitrules(idx).commands = {'mex ${CPPFLAGS} ${CFLAGS} $< -output $@'};
idx = idx+1;
state.implicitrules(idx).target   = {'%.o'};
state.implicitrules(idx).deps     = {'%.c'};
state.implicitrules(idx).commands = {'mex -c ${CFLAGS} $< -outdir $&'};
idx = idx+1;
state.implicitrules(idx).target   = {'%.o'};
state.implicitrules(idx).deps     = {'%.cpp'};
state.implicitrules(idx).commands = {'mex -c ${CPPFLAGS} ${CFLAGS} $< -outdir $&'};
idx = idx+1;
state.implicitrules(idx).target   = {'%.obj'};
state.implicitrules(idx).deps     = {'%.c'};
state.implicitrules(idx).commands = {'mex -c ${CFLAGS} $< -outdir $&'};
idx = idx+1;
state.implicitrules(idx).target   = {'%.obj'};
state.implicitrules(idx).deps     = {'%.cpp'};
state.implicitrules(idx).commands = {'mex -c ${CPPFLAGS} ${CFLAGS} $< -outdir $&'};
idx = idx+1;
state.implicitrules(idx).target   = {'%.dlm'};
state.implicitrules(idx).deps     = {'%.mdl'};
state.implicitrules(idx).commands = {'rtwbuild(''$*'')'};

%% Make the target
result = make(target, state);
if (~isempty(wd))
    fprintf('Leaving directory %s\n',pwd);
    cd(wd);
end
switch (result)
    case -1
        error('mmake: No rule found for target %s\n', target);
    case 0
        fprintf('Nothing to be done for target %s\n', target);
    case 1
        fprintf('Target %s successfully built\n', target);
end
end %function

%% Private functions %%

% Recursively make the target, using the dependency information available
% in the state varaible.  Only runs the available commands if a dependant
% is newer than the requested target.  Returns:
%   (-1) if the target does not exist and there is no rule to build it
%   (0)  if the target exists and nothing needed to be done
%   (1)  if the target needed to be rebuilt.
function result = make(target, state)
    % see if we have a rule to make the target
    target_rules = find_matching_rules(target, state.rules);
    
    cmds = {};
    deps = {};
    
    for i=1:length(target_rules)
        if (~isempty(target_rules(i).commands))
            if (~isempty(cmds))
                warning('mmake:multiple_commands',['mmake: Overriding commands for target ',target]);
            end
            cmds = target_rules(i).commands;
        end
        % Concatenate the dependencies on the back
        deps = {deps{:}, target_rules(i).deps{:}};
    end
    
    if (isempty(cmds))
        % We didn't find any explicit commands to make this target; try
        % the implicit rules
        matching_implicit_rules = find_matching_rules(target, state.implicitrules);
        for i=1:length(matching_implicit_rules)
            deps_exist = false;
            for j = 1:length(matching_implicit_rules(i).deps)
                if(~isempty(matching_implicit_rules(i).deps{j}))
                    result = make(matching_implicit_rules(i).deps{j},state);
                    if (result == -1)
                        % The dependency didn't exist and we don't know how
                        % to make it
                        deps_exist = false;
                        break;
                    else
                        deps_exist = true;
                    end
                end
            end
            if (deps_exist)
                deps = {deps{:}, matching_implicit_rules(i).deps{:}};
                cmds = matching_implicit_rules(i).commands;
                break;
            end
        end
    end
    
    % TODO: This should be better (elsewhere?)
    if (isempty(cmds) && isempty(deps))
        % We don't know how to make it; ensure it exists:
        file = dir(target);
        if (isempty(file))
            result = -1;
        else
            result = 0;
        end
        return;
    end
    
    
    if (isempty(deps))
        newest_dependent_timestamp = inf;
    else
        newest_dependent_timestamp = 0;
        for i=1:length(deps)
            % Recursively make all the dependents
            status = make(deps{i}, state);
            if (status == -1)
                error('mmake: No rule to build %s as required by %s', deps{i}, target);
            end

            % Ensure the dependent exists and check its timestamp
            file = dir(deps{i});
            if (isempty(file))
                error('mmake: File %s not found as required by %s', deps{i}, target);
            end
            newest_dependent_timestamp = max(newest_dependent_timestamp, file.datenum);
        end
    end
    
    target_timestamp = -1;
    file = dir(target);
    if (~isempty(file))
        target_timestamp = file.datenum;
    end
    
    
    if (target_timestamp < newest_dependent_timestamp)
        for i = 1:length(cmds)
            cmd = expand_vars(cmds{i}, state.vars);
            disp(cmd);
            eval(cmd);
        end
        result = 1;
    else
        result = 0;
    end
end

% Parse the MMakefile.
function state = read_mmakefile(path)
    fid = fopen(path);
    
    if (fid == -1)
        state = [];
        return;
    end
    
    % Parse all the variables
    state.vars.MEX_EXT = mexext;
    line = fgetl(fid);
    while (ischar(line))
        line = strip_comments(line);
        
        % Check for an immediate := assignment
        variable = regexp(line, '^\s*([A-Za-z]\w*)\s*:=(.*)$', 'tokens', 'once');
        if (length(variable) == 2)
            state.vars.(variable{1}) = expand_vars(variable{2}, state.vars);
        end
        line = fgetl(fid);
    end
    frewind(fid);
    
    % Parse all rules
    state.rules = [];
    line = fgetl(fid);
    while (ischar(line))
        line = strip_comments(line);
        
        % Check for a : that's missing the =
        rule = regexp(line, '^\s*(\S.*):(?!=)(.*)$', 'tokens', 'once');
        if (length(rule) >= 1)
            loc = length(state.rules)+1;
            state.rules(loc).target = strread(expand_vars(rule{1}, state.vars), '%s'); %#ok<REMFF1> strread permits an empty argument,
            state.rules(loc).deps   = strread(expand_vars(rule{2}, state.vars), '%s'); %#ok<REMFF1> textscan (the replacement) does not.
            
            % And check the next line for a rule
            line = fgetl(fid);
            state.rules(loc).commands = {};
            while (ischar(line) && ~isempty(regexp(line, '^(\t|\s\s\s\s)', 'once')))
                cmdloc = length(state.rules(loc).commands)+1;
                state.rules(loc).commands{cmdloc} = strtrim(line);
                line = fgetl(fid);
            end
        else
            line = fgetl(fid);
        end
    end
    
    % cleanup
    fclose(fid);
end

function out = strip_comments(str)
    loc = strfind(str, '#');
    if(loc)
        out = str(1:loc(1)-1);
    else
        out = str;
    end
end

% Given an arbitrary string, find all locations of variables, and call
% parse_var to expand their result.
function out = expand_vars(value, vars)
    if (isempty(value))
        out = value;
        return;
    end

    if (iscell(value))
        value = value{1};
    end
    
    loc = 1;
    result = {};
    while loc < length(value)
        next_loc = find(value(loc:end)=='$');
        if (isempty(next_loc))
            result{end+1} = value(loc:end); %#ok<*AGROW>
            break;
        end;
        
        next_loc = next_loc(1)+loc-1;
        
        if (value(next_loc+1) == '(' || value(next_loc+1) == '{')
            result{end+1} = value(loc:next_loc-1);
            [result{end+1}, len] = parse_var(value(next_loc:end),vars);
            loc = next_loc + len;
        else
            result{end+1} = value(loc:next_loc);
            loc = loc + next_loc+1;
        end
    end
    
    out = [result{:}];
end

% Given a variable src in the form ${foo${bar}}, recursively expand all
% variables by ensuring the parentheses and braces pair properly.
function [result, len] = parse_var(src,vars)
    % First, find the endpoint
    p = 0; b = 0; % Parens/Brace nesting levels
    i = 3;
    j = 3;
    result = {};
    while i<=length(src)
        if (src(i) == '$' && ( src(i+1) == '(' || src(i+1) == '{'))
            [val,len] = parse_var(src(i:end),vars);
            result{end+1} = [src(j:i-1) val];
            i = i + len;
            j = i; % The start of the next unexpanded text
            if (i > length(src)); break; end;
        end
        
        if (src(i) == '(')
            p = p+1;
        elseif (src(i) == '{')
            b = b+1;
        elseif (src(i) == ')')
            p = p-1;
            if (p < 0 && src(2) == '(')
                result{end+1} = src(j:i-1);
                j = i;
                break;
            end
        elseif (src(i) == '}')
            b = b-1;
            if (b < 0 && src(2) == '{')
                result{end+1} = src(j:i-1);
                j = i;
                break;
            end
        end
        
        i = i+1;
    end
    if (src(2) == '{' && b >= 0)
        error(['mmake: unmatched ''{'' in MMakefile variable ', src]);
    elseif (src(2) == '(' && p >= 0)
        error(['mmake: unmatched ''('' in MMakefile variable ', src]);
    end
    result{end+1} = src(j:i-1);
    result = [result{:}];
    len = i;
    
    if (isfield(vars,result))
        result = vars.(result);
    elseif (strncmp(result,'eval ',5))
        result = concat(eval(result(6:end)));
    else
        result = '';
    end
end


function out = expand_auto_vars(cmds, ruleset)
    all_deps = concat(ruleset.deps);
    if (isempty(ruleset.deps))
        first_dep = ruleset.deps;
    else
        first_dep = ruleset.deps{1};
    end
    
    [target_dir,~,~] = fileparts(ruleset.target);
    if (isempty(target_dir))
        target_dir = '.';
    end
    
    unique_deps = concat(str_unique(ruleset.deps));
    cmds = regexprep(cmds, '(\$\@|\$\{\@\}|\$\(\@\))', regexptranslate('escape',ruleset.target));
    cmds = regexprep(cmds, '(\$\*|\$\{\*\}|\$\(\*\))', regexptranslate('escape',ruleset.pattern));
    cmds = regexprep(cmds, '(\$<|\$\{<\}|\$\(<\))',    regexptranslate('escape',first_dep));
    cmds = regexprep(cmds, '(\$\^|\$\{\^\}|\$\(\^\))', regexptranslate('escape',unique_deps));
    cmds = regexprep(cmds, '(\$\+|\$\{\+\}|\$\(\+\))', regexptranslate('escape',all_deps));
    cmds = regexprep(cmds, '(\$\&|\$\{\&\}|\$\(\&\))', regexptranslate('escape',target_dir));
    out = cmds;
end

function out = str_unique(cell_arry)
    out = char(cell_arry) + 0;
    out = cellstr(char(unique(out, 'rows')));
end

function out = concat(obj)
    if (isempty(obj))
        out = '';
    elseif (ischar(obj) && size(obj,1) == 1)
        out = obj;
    elseif (ischar(obj) && size(obj,1) > 1)
        obj(:,size(obj,2)+1) = ' ';
        out = obj(:)';
    elseif (iscell(obj) && ~isempty(obj) && ischar(obj{1}))
        out = strcat(obj, {' '});
        out = [out{:}];
    else
        % warning(['matmake: unable to convert object of type ', class(obj), ' to string']);
        out = '';
    end
end

function out = find_matching_rules(target, ruleset)
    out = [];
    target = strtrim(target);
    for i=1:length(ruleset)
        regex = cell(size(ruleset(i).target));
        for j = 1:length(regex)
            regex{j} = regexptranslate('wildcard', ruleset(i).target{j});
        end
        regex = strcat('^', regex, '$');
        match_idx = 0;
        pattern = '';
        if (strfind(regex{1}, '%'))
            % Percent matching only supported on single targets.
            regex = strrep(regex{1}, '%', '(\S+)');
            result = regexp(target, regex, 'tokens', 'once');
            if (~isempty(result))
                match_idx = 1;
                pattern = result{1};
            end
        else
            result = regexp(target, regex, 'once');
            match_idx = find(~cellfun(@isempty, result),1,'first');
        end
        if (match_idx > 0)
            loc = length(out) + 1;
            out(loc).target = target;
            out(loc).deps = strrep(ruleset(i).deps, '%', pattern);
            out(loc).pattern = pattern;
            out(loc).commands = expand_auto_vars(ruleset(i).commands, out(loc));
        end
    end
end

