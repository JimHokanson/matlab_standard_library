function makeFigureAlwaysOnTop(h)
%
%   sl.hg.figure.makeFigureAlwaysOnTop

%I think this could be expanded to a dependent property
%with read and set capabilities

warnStruct=warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe = get(handle(h),'JavaFrame');
warning(warnStruct.state,'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

keyboard

jframe_hg_client = jframe.fHG2Client;

jframe_hg_client.getWindow.setAlwaysOnTop(true);

end

