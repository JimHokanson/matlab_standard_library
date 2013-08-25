function obj = setprop(obj, propname, value)
    %SETPROP  Sets the contents of a property in the object.
    %   OBJ = SETPROP(OBJ, 'propname', VALUE) sets the property 'propname'
    %   in OBJ with VALUE. OBJ should be a single object. 
    %
    %   This methods mimics the SUBSASGN method and should be used in
    %   methods of an HDS class to enforce the HDS toolbox to update the
    %   object correctly. Alternatively, you can use the SUBSASGN method in
    %   class methods directly to ensure correct behavior of the HDS
    %   Toolbox. See the MATLAB help for additional info.
    %
    %   !! If you do not use SETPROP in a class method to set the values of
    %   the properties, it is possible that the HDS Toolbox does not
    %   recognise that the object has changed and will fail to save the
    %   object. This is only a concern in class-methods, eg. when the first
    %   variable in the method call is the object itself. !!

    % Copyright (c) 2012, J.B.Wagenaar
    % This source file is subject to version 3 of the GPL license, 
    % that is bundled with this package in the file LICENSE, and is 
    % available online at http://www.gnu.org/licenses/gpl.txt
    %
    % This source file can be linked to GPL-incompatible facilities, 
    % produced or made available by MathWorks, Inc.
    
    try
        obj = subsasgn(obj, substruct('.',propname), value);
    catch ME
        throwAsCaller(ME);
    end
    
end