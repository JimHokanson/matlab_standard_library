function figToClipboardForPPT(varargin)
%
%   sl.plot.figToClipboardForPPT
%
%   Issue: https://github.com/JimHokanson/matlab_standard_library/issues/24
%
%   Optional Inputs
%   ---------------
%   ratio : numeric
%       Value to use when resizing the figure
%   enlarge : 
%   
%   Examples
%   --------
%   

%Steps:
%0) Determine viewing size we're working with
%1) Resize figure to appropriate ratio
%   => can we auto expand the 

in.enlarge = true;
in.ratio = 4/3;
in = sl.in.processVarargin(in,varargin);

end