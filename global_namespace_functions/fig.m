function fig(h)
%
%   TODO: Document

if nargin == 0
    figure();
else
    figure(h);
end

%Not sure what the best option is here but we need
%to wait until some point when Matlab has switched focus to the 
%figure before switching back to the command window otherwise due to the
%asynchronous nature we'll "switch" to the command window and then Matlab
%will switch to the figure
drawnow nocallbacks

commandwindow
end