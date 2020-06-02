function addScreenshotOption(h_fig)
%
%   sl.plot.uimenu.addScreenshotOption(*h_fig)

if nargin == 0
    h_fig = gcf;
end

m = sl.plot.uimenu.menu('Custom',h_fig);
%TODO: Flush out with more options
%1) clipboard (entire figure)
%2) select and clipboard
%3) select and save
%4) save

m2 = m.addChild('screenshot');

m3 = m2.addChild('clipboard','Callback',@(~,~)sl.os.screenCapture(h_fig));

% mitem = m.addChild('screenshot','Callback',@(~,~)sl.os.screencapture(h_fig));

% sl.os.screencapture(gcf,[],'clipboard')

%    imageData = screencapture;  % interactively select screen-capture rectangle
%    imageData = screencapture(hListbox);  % capture image of a uicontrol
%    imageData = screencapture(0,  [20,30,40,50]);  % capture a small desktop region
%    imageData = screencapture(gcf,[20,30,40,50]);  % capture a small figure region
%    imageData = screencapture(gca,[10,20,30,40]);  % capture a small axes region
%      imshow(imageData);  % display the captured image in a matlab figure
%      imwrite(imageData,'myImage.png');  % save the captured image to file
%    img = imread('cameraman.tif');
%      hImg = imshow(img);
%      screencapture(hImg,[60,35,140,80]);  % capture a region of an image
%    screencapture(gcf,[],'myFigure.jpg');  % capture the entire figure into file
%    screencapture(gcf,[],'clipboard');     % capture the entire figure into clipboard
%    screencapture(gcf,[],'printer');       % print the entire figure
%    screencapture('handle',gcf,'target','myFigure.jpg'); % same as previous, save to file
%    screencapture('handle',gcf,'target','clipboard');    % same as previous, copy to clipboard
%    screencapture('handle',gcf,'target','printer');      % same as previous, send to printer
%    screencapture('toolbar',gcf);  % adds a screen-capture button to gcf's toolbar
%    screencapture('toolbar',[],'target','sc.bmp'); % same with default output filename

end