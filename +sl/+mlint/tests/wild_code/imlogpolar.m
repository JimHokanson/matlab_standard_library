function [rout,g,b] = imlogpolar(varargin)
%IMLOGPOLAR Compute logarithmic polar transformation of image.
%   B = IMLOGPOLAR(A,NRHO,NTHETA,METHOD) computes the logarithmic
%   polar transformation of image A, generating a log polar image
%   of size NRHO by NTHETA.  METHOD describes the interpolation
%   method.  METHOD is a string that can have one of these values:
%
%        'nearest'  (default) nearest neighbor interpolation
%
%        'bilinear' bilinear interpolation
%
%        'bicubic'  bicubic interpolation
%
%   If you omit the METHOD argument, IMLOGPOLAR uses the default
%   method of 'nearest'. 
%
%   B = IMLOGPOLAR(A,NRHO,NTHETA,METHOD,CTR) assumes that the 2x1
%   vector CTR contains the coordinates of the origin in image A.  
%   If CTR is not supplied, the default is CTR = [(m+1)/2,(n+1)/2],
%   where A has n rows and m columns.
%
%   B = IMLOGPOLAR(A,NRHO,NTHETA,METHOD,CTR,SHAPE) where SHAPE is a
%   string that can have one of these values:
%
%        'full' - returns log polar transformation containing ALL
%                 pixels from image A (the circumscribed circle
%                 centered at CTR)
%
%        'valid' - returns log polar transformation containing only
%                 pixels from the largest inscribed circle in image A
%                 centered at CTR.
%
%   If you omit the SHAPE argument, IMLOGPOLAR uses the default shape
%   of 'valid'.  If you specify the shape 'full', invalid values on the
%   periphery of B are set to NaN.
%
%   Class Support
%   -------------
%   The input image can be of class uint8 or double. The output
%   image is of the same class as the input image.
%
%   Example
%   -------
%        I = imread('ic.tif');
%        J = imlogpolar(I,64,64,'bilinear');
%        imshow(I), figure, imshow(J)
%
%   See also IMCROP, IMRESIZE, IMROTATE.

%   Nathan D. Cahill 8-16-01, modified from:
%   Clay M. Thompson 8-4-92
%   Copyright 1993-1998 The MathWorks, Inc.  All Rights Reserved.
%   $Revision: 5.10 $  $Date: 1997/11/24 15:35:33 $

% Grandfathered:
%   Without output arguments, IMLOGPOLAR(...) displays the transformed
%   image in the current axis.  

[Image,rows,cols,Nrho,Ntheta,Method,Center,Shape,ClassIn] = parse_inputs(varargin{:});

threeD = (ndims(Image)==3); % Determine if input includes a 3-D array

if threeD,
   [r,g,b] = transformImage(Image,rows,cols,Nrho,Ntheta,Method,Center,Shape);
   if nargout==0, 
      imshow(r,g,b);
      return;
   elseif nargout==1,
      if strcmp(ClassIn,'uint8');
         rout = repmat(uint8(0),[size(r),3]);
         rout(:,:,1) = uint8(round(r*255));
         rout(:,:,2) = uint8(round(g*255));
         rout(:,:,3) = uint8(round(b*255));
      else
         rout = zeros([size(r),3]);
         rout(:,:,1) = r;
         rout(:,:,2) = g;
         rout(:,:,3) = b;
      end
   else % nargout==3
      if strcmp(ClassIn,'uint8')
         rout = uint8(round(r*255)); 
         g = uint8(round(g*255)); 
         b = uint8(round(b*255)); 
      else
         rout = r;        % g,b are already defined correctly above
      end
   end
else 
   r = transformImage(Image,rows,cols,Nrho,Ntheta,Method,Center,Shape);
   if nargout==0,
      imshow(r);
      return;
   end
   if strcmp(ClassIn,'uint8')
      if islogical(Image)
         r = im2uint8(logical(round(r)));    
      else
         r = im2uint8(r); 
      end
   end
   rout = r;
end

