function varargout = ismemberCharSortedSecondInput(a,b)
%
%
%   [LIA,LOCB] = sl.str.quick.ismemberCharSortedSecondInput(a,b)
%   
%   

if nargout == 1
   varargout{1} = ismembc(a,b);
else
   varargout{2} = ismembc2(a,b);
   varargout{1} = varargout{2} > 0;
end