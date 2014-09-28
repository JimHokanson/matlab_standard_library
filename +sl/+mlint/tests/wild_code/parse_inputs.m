function [A,Ar,Ac,Nrho,Ntheta,Method,Center,Shape,Class] = parse_inputs(varargin)
% Outputs:  A       the input image
%           Nrho    the desired number of rows of transformed image
%           Ntheta  the desired number of columns of transformed image
%           Method  interpolation method (nearest,bilinear,bicubic)
%           Center  origin of input image
%           Shape   output size (full,valid)
%           Class   storage class of A

error(nargchk(3,6,nargin));

A = varargin{1};

Ar = size(A,1);     % Ar = number of rows of the input image
Ac = size(A,2);     % Ac = number of columns of the input image

Nrho = varargin{2};
Ntheta = varargin{3};
Class = class(A);

if nargin < 4
    Method = '';
else
    Method = varargin{4};
end
if isempty(Method)
    Method = 'nearest';
end
Method = lower(Method);
if ~any(strcmp(Method,{'nearest','bilinear','bicubic'}))
    error('Method must be one of ''nearest'', ''bilinear'', or ''bicubic''.');
end

if nargin < 5
    Center = [];
else
    Center = varargin{5};
end
if isempty(Center)
    Center = [(Ac+1)/2 (Ar+1)/2];
end
if length(Center(:))~=2
    error('Center should be 1x2 array.');
end
if any(Center(:)>[Ac;Ar] | Center(:)<1)     % THIS LINE USED TO READ 'if any(Center(:)>[Ar;Ac] | Center(:)<1)' but Ar and Ac should be swapped round -- look at line 40 for whty this should be.  A.I.Wilmer, 12th Oct 2002
    num2str(['Center is ',num2str(Center(1)),',',num2str(Center(2)) ' with size of image = ',num2str(Ar),'x',num2str(Ac),' (rows,columns)'])
    warning('Center supplied is not within image boundaries.');
end

if nargin < 6
    Shape = '';
else
    Shape = varargin{6};
end
if isempty(Shape)
    Shape = 'valid';
end
Shape = lower(Shape);
if ~any(strcmp(Shape,{'full','valid'}))
    error('Shape must be one of ''full'' or ''valid''.');
end

if isa(A, 'uint8'),     % Convert A to Double grayscale for interpolation
   if islogical(A)
      A = double(A);
   else
      A = double(A)/255;
   end
end