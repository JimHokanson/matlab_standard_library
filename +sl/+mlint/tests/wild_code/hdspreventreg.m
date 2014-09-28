function out = hdspreventreg(setValue)
	%HDSPREVENTREG  Used by HDS-Toolbox to prevent object registration.

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.

    persistent value
    
    if nargin > 1
        throwAsCaller(MException('HDS:activeHDStree','Incorrect number of arguments.'));
    elseif nargin
        if islogical(setValue)
            value = setValue;
        else
            throwAsCaller(MException('HDS:activeHDStree','Input argument should be of class BOOLEAN.'));
        end
    end
    if isempty(value)
        value = false;
    end
    out = value;
end
        
