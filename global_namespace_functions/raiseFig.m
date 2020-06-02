function raiseFig()
%x Brings current figure into focus
%
%   raiseFig()
%
%   I type this at the command window to bring a figure to the forefront.
%
%   Note, there is no reason to type this anywhere besides the command
%   window. The code currently assumes you type it in the command window.
%
%   The actual command is only:
%   figure(gcf)
%
%   But instead I type:
%   rais<tab> and then I get what I want ..


%   Note that I also keep the focus in the command window

%TODO: Only do this if Matlab main window is not overlapping with the
%figure otherwise we'll just hide the figure again when we switch
%to the command window
%keep focus on command window
%fig(gcf)

figure(gcf)

end