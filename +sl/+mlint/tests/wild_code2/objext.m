function ext = objext(arch)
%OBJEXT returns the object extension for your platform
%ext = objext(*arch)
%
%
% INPUTS
% =========================================================================
%   arch - (char) optional argument to specify a specific architecture
%   'win'
%   'unix'
%   'mac'
%
% tags: mex support, architecture
% see also: mexext, make
if nargin
    switch lower(arch)
        case 'win'
            ext = 'obj';
        case 'unix'
            ext = 'o';
        case 'mac'
            ext = 'o';
    end
else
    if ismac || isunix
        ext = 'o';
    else
        ext = 'obj';
    end
end
end