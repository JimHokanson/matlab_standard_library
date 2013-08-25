function val = getprop(obj, propName)                                 
    %GETPROP  Returns the contents of a property of the object.
    %
    %   VAL = GETPROP(OBJ, 'propname') returns the contents of the property
    %   'propname' in the current object. If OBJ is an array of objects, VAL
    %   will return a cell-array with the contents of each property.
    %
    %   This method mimics the SUBSREF method and should be used in
    %   methods of an HDS class to get the contents of properties that are
    %   defined as 'data properties' in the class definition.
    %   Alternatively, you can use the 'subsref' method directly. See
    %   MATLAB help for additional information.
    %
    %   see also: SETPROP, SUBSREF

    % Copyright (c) 2012, J.B.Wagenaar
    % This source file is subject to version 3 of the GPL license, 
    % that is bundled with this package in the file LICENSE, and is 
    % available online at http://www.gnu.org/licenses/gpl.txt
    %
    % This source file can be linked to GPL-incompatible facilities, 
    % produced or made available by MathWorks, Inc.
    
    try
        val = subsref(obj,substruct('.',propName));
    catch ME
        throwAsCaller(ME)
    end
end