function I = findMatch(input_string,string_options,varargin)
%x  Tries to find a match for one string in a set of strings based on rules
%
%    I = sl.str.findMatch(input_string,string_options,varargin)
%
%   This code was originally written to find a channel based on an shorter
%   name for that channel, e.g.
%
%   With the strings {'Bladder Pressure','EUS EMG'} find the one that
%   matches a string 'Pres
%
%
%   Inputs:
%   -------
%   input_string
%   string_options
%
%    Optional Inputs:
%    ----------------
%    case_sensitive: (default false)
%    partial_match: (default true)
%       If true the input only needs to be a part of the name.
%       For example we could get the channel 'Bladder Pressure'
%       by using the <name> 'pres' since 'pres' is in the
%       string 'Bladder Pressure'
%    multiple_channel_rule: {'error','first','last',index #,'shortest'}
%       - 'error'
%       - 'first'
%       - 'last'
%       - index # (e.g. 3) - this is a bit of hack ...
%       - 'shortest'
%
%   TODO: Update documentation, not only for channels

in.case_sensitive = false;
in.partial_match  = true;
in.multiple_channel_rule = 'error';
in = sl.in.processVarargin(in,varargin);

name = input_string;
all_names = string_options;

if ~in.case_sensitive
    all_names = lower(all_names);
    name      = lower(name);
end

if in.partial_match
    I = find(cellfun(@(x) sl.str.contains(x,name),all_names));
else
    %Could also use: sl.str.findSingularMatch
    I = find(strcmp(all_names,name));
end

if isempty(I)
    error('Unable to find channel with name: %s',name)
elseif length(I) > 1
    if isnumeric(in.multiple_channel_rule)
        I = I(in.multiple_channel_rule);
    else
        switch in.multiple_channel_rule
            case 'error'
                error('Multiple matches for channel name found')
            case 'first'
                I = I(1);
            case 'last'
                I = I(end);
            case 'shortest'
                name_lengths = cellfun('length',all_names(I));
                [~,I2] = min(name_lengths);                            
                I = I(I2);
            otherwise
                error(['Multiple matches for channel name found and' ...
                    ' multiple matches option: "%s" not recognized'],...
                    in.multiple_channel_rule)
        end
    end
end


end