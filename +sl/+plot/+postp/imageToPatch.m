function new_handles = imageToPatch(handles_in,varargin)
%imageToPatch
%
%   new_handles = sl.plot.postp.imageToPatch(image_handles,varargin)
%
%   new_handles = sl.plot.postp.imageToPatch(figure_handle,varargin)
%
%
%
%   This function is a work in progress ...
%
%
%
%   NOTES: This code needs to be cleaned up a bit ...
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Optionally maintain z-order ...

in.delete_original  = true;
in.ignore_colorbars = true; %Applicable only for figure handles
in.fix_bad_patches  = true; %See code for explanation
in = sl.in.processVarargin(in,varargin);

image_handles = helper__resolveHandles(handles_in,in);

n_handles   = length(image_handles);
new_handles = cell(1,n_handles);

for iHandle = 1:n_handles
    new_handles{iHandle} = helper__Processor(image_handles(iHandle),in);
end

end

function image_handles = helper__resolveHandles(handles_in,in)

if length(handles_in) == 1 && strcmp(get(handles_in,'type'),'figure')
    if in.ignore_colorbars
        image_handles = findobj('type','image','-not','tag','TMW_COLORBAR');
    else
        image_handles = findobj('type','image');
    end
elseif ~all(strcmp(get(handles_in,'type'),'image'))
    error('All input handles must be of the image type')
else
    image_handles = handles_in;
end

end


function h = helper__Processor(image_handle,in)

s      = get(image_handle);
parent = s.Parent;

% if ~strcmp('scaled',s.CDataMapping)
%     error('I haven''t done setup this code for non-scaled data')
% end

[xData,yData] = helper__getWidthInfo(s);

sz = size(s.CData);

%TODO: Need to expand s.CData

new_cdata = zeros(sz(1)+1,sz(2)+1);
new_cdata(1:end-1,1:end-1) = s.CData;
%Expand to the lower right ...
new_cdata(:,end) = new_cdata(:,end-1);
new_cdata(end,:) = new_cdata(end-1,:);

%TODO: Document what this code is doing ...
h = patch(surf2patch(xData,yData,zeros(size(new_cdata)),new_cdata),'parent',parent,'CDataMapping',s.CDataMapping);

%Abnoxious warning:
%FaceVertexCData length (0) must equal Vertices length (1)
%Submitted bug report, gave answer at:
%http://www.mathworks.com/matlabcentral/answers/6051

if in.fix_bad_patches
   h_bad_all = findobj(parent,'FaceVertexCData',[],'-not','Vertices',[]);
   for iH = 1:length(h_bad_all)
      cur_h_bad = h_bad_all(iH);
      p = get(cur_h_bad,'Parent');
      set(cur_h_bad,'FaceVertexCData',get(p,'CData'));
   end
end

shading flat

%??? - do this for everything ????
if strcmp(s.Tag,'TMW_COLORBAR')
   %Not sure if this should just be for direct or scaled ...
   set(h,'FaceColor','Flat')
   set(h,'EdgeColor','none')
end

if in.delete_original
    delete(image_handle)
end


end

function [xData,yData] = helper__getWidthInfo(s)

%
%   See:
%   http://www.mathworks.com/help/matlab/ref/image_props.html
%
%3 cases
%-------------------------------
%1) 2 elements and size is > 1
%2) 1 element - step size is 1
%3) 2 elements but size is only 1 - then the width
%   seems to be the difference between the two added to either side
%
%   For example, in the colorbar:
%   CData: 64 x 1
%   XData: [0 1] -> somehow the image goes from [-1 to 2]
%   difference is 1, so we go from (0-1) to (1+1)
%

%Yikes, look away ... :/

all_data = {s.XData s.YData};
new_data = cell(1,2);
dim_use  = [2 1];

for iDim = 1:2
    cur_data = all_data{iDim};
    cur_dim  = dim_use(iDim);
    
    %TODO: rename these ...
    sz       = size(s.CData,cur_dim);
    len      = length(cur_data);
    
    %TODO: Also implement new_data here
    if len == 1
        half_width = 0.5;
        if sz == 1
            %Single point
            new_data{iDim} = [cur_data - half_width cur_data + half_width];
        else
            new_data{iDim} = (cur_data - half_width):(cur_data + sz - 1 + half_width);
        end
    elseif len == 2 && sz == 1
        %Implement weird width
        %Provide link to answers ...
        half_width     = (cur_data(2) - cur_data(1))*1.5; % really x 3 (center, left, right) / 2 (half width)
        new_data{iDim} = [cur_data(1)-half_width cur_data(2)+half_width];
    else
       %Then half 
       half_width     = 0.5*(cur_data(end)-cur_data(1))/(sz-1);
       new_data{iDim} = linspace(cur_data(1)-half_width,cur_data(end) + half_width, sz + 1);
    end
end

xData = new_data{1};
yData = new_data{2};



% %Yikes, XData
% 
% %TODO: Where did I find this formula????
% %What if we only have one element ...
% %See: http://www.mathworks.com/help/matlab/ref/image_props.html
% %
% %   XData [1 size(CData,2) by default
% %   
% %   c = image(rand(10,1))
% %
% %   xData: 1
% %   yData: [1 10]
% %
% %   
% 
% xHWidth = 0.5*(xData(end)-xData(1))/(size(s.CData,2)-1);
% yHWidth = 0.5*(yData(end)-yData(1))/(size(s.CData,1)-1);
% 
% %What if we have two elements??????
% %[0 1]?????? - like the colorbar for xData
% 
% xData = linspace(xData(1)-xHWidth,xData(end)+xHWidth,size(s.CData,2)+1);
% yData = linspace(yData(1)-yHWidth,yData(end)+yHWidth,size(s.CData,1)+1);



end


%OLD COMMENTS
%==========================================================================
% PLOT_IMAGESCTOPATCH Transform an image into a set of patches
%
%   PLOT_imagescToPatch(imageHandle,*deleteOriginal)
%
%   This function was designed to make exporting and image to Adobe
%   Illustrator more palatable
%
%   It is assumed that the image was the lowest/deepest/bottom object on
%   the axis, so the resulting patches are placed on the bottom.  If you
%   had original occluded an object with the image it will be visible
%
% INPUTS
% =========================================================================
%   imageHandle    - (handle) graphics handle, either the image itself, or the
%       owning figure/axis.
%   deleteOriginal - (logical) Default: false. Delete source image yes/no
%
% OUTPUTS
% =========================================================================
%   CAA TODO These only support a single imagesc at a time ( only values
%   from last iteration are saved)
%   handles  - (handle) handles of created patches, returned in column major
%   order
%   value  - (handle) value of the patch
%
%
% tags: post process,imagesc,image, figure, plot
% see also: uistack

% % % % % % % % if nargin < 1
% % % % % % % %     imageHandle = findobj('type','image','-not','tag','TMW_COLORBAR');
% % % % % % % % end
% % % % % % % %
% % % % % % % %
% % % % % % % % % verify whether or not this
% % % % % % % % if all(ishandle(imageHandle))
% % % % % % % %     if all(isprop(imageHandle,'type'))
% % % % % % % %         if ~all(strcmp(get(imageHandle,'type'),'image'))
% % % % % % % %             imageHandle = findobj(imageHandle,'type','image','-not','tag','TMW_COLORBAR');
% % % % % % % %             assert(~isempty(imageHandle),'Supplied Axis did not contain an image object')
% % % % % % % %         end
% % % % % % % %     else
% % % % % % % %         error('Could not find image object children within input ''ImageHandle''')
% % % % % % % %     end
% % % % % % % % else
% % % % % % % %     error(' Input ''ImageHandle'' must be an handle object of some types')
% % % % % % % % end
% % % % % % % %
% % % % % % % % for iiImage = 1:length(imageHandle)
% % % % % % % %     this_image = imageHandle(iiImage);
% % % % % % % %     s    = get(this_image);
% % % % % % % %     parent = s.Parent;
% % % % % % % %
% % % % % % % %     if ~strcmp('scaled',s.CDataMapping)
% % % % % % % %         error('I haven''t done setup this code for non-scaled data')
% % % % % % % %     end
% % % % % % % %
% % % % % % % %     xData  = s.XData;
% % % % % % % %     yData  = s.YData;
% % % % % % % %     %Yikes, XData
% % % % % % % %
% % % % % % % %     xHWidth = 0.5*(xData(end)-xData(1))/(size(s.CData,2)-1);
% % % % % % % %     yHWidth = 0.5*(yData(end)-yData(1))/(size(s.CData,1)-1);
% % % % % % % %
% % % % % % % %     xData = linspace(xData(1)-xHWidth,xData(end)+xHWidth,size(s.CData,2)+1);
% % % % % % % %     yData = linspace(yData(1)-yHWidth,yData(end)+yHWidth,size(s.CData,1)+1);
% % % % % % % %
% % % % % % % %     sz = size(s.CData);
% % % % % % % %
% % % % % % % %     h = patch(surf2patch(xData,yData,zeros(sz(1)+1,sz(2)+1),s.CData),'parent',parent);
% % % % % % % %
% % % % % % % %     %set(h,'EdgeColor','none')
% % % % % % % %     %set(h,'FaceColor','none')
% % % % % % % %
% % % % % % % %     shading flat
% % % % % % % %
% % % % % % % %     delete(this_image)
% % % % % % % % end

% % % % % % % % if nargout >= 1
% % % % % % % %     mask = hAll ~= 0;
% % % % % % % %     varargout{1} = hAll(mask);
% % % % % % % %     if nargout >= 2
% % % % % % % %         varargout{2} = values(mask);
% % % % % % % %     end
% % % % % % % % end
% % % % % % % % end
