function obj = addprop(obj, propName, varargin)                                 
  %ADDPROP  Adds a dynamic property to the object.
  %   OBJ = ADDPROP(OBJ, 'DynamicPropName') adds a dynamic property to
  %   the HDS-object OBJ.  The added property is associated only with the
  %   current object, there is no effect on the class of OBJ.  
  %
  %   OBJ = ADDPROP(... ,'-t') Optionally, the '-t' parameter can be
  %   included as an input argument to specify that the added property
  %   should be defined as a 'Transient' property. This means that the
  %   property only exist as long as the object is in memory and will not
  %   be stored to disk. 
  %   
  %   Note that the HDSCLEANUP method will be able to remove the object
  %   from memory which can result in the loss of data in added property
  %   when it is defined as 'Transient'.   
  %
  %
  %   examples:
  %       E = Experiment; addprop(E, 'tempdata', '-t');
  %
  %   See also: hdscleanup addobj remobj addlink remlink remprop getprop

  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  setTransient = false;
  if nargin == 3
    if strcmp('-t', varargin{1})
      setTransient = true;
    end
  end

  assert(length(obj)==1, 'Method not defined for arrays of objects');

  % Check whether propName exist in obj  
  h = findprop(obj, propName);
  assert(isempty(h) && ~any(strcmp(propName,obj.linkProps)), ...
    'ADDPROP: Property ''%s'' already defined in object.',propName);

  d = addprop@dynamicprops(obj, propName);
  if setTransient
    d.Transient = true;
  end

end
