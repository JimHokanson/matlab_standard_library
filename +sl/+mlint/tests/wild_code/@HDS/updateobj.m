function obj = updateobj(obj)
    %UPDATEOBJ  Method that is called to update objects during load.
    %
    %   OBJ = UPDATEOBJ(OBJ) updates the object version number to
    %   correspond to the class version number as defined in the class
    %   definition. The current version of the object is stored in the
    %   'objVersion' property which contains two numbers indicating the
    %   version of the HDS-class and the version of the Object-Class
    %   respectively.
    %
    %   !! An overloaded version of this method should be placed in the
    %   class definition folder of the class that is being updated. This
    %   method can be used to make changes to objects of the specific class
    %   to conform with the new version number. !!
    %
    %   The SETOBJVERSION method should be used to update the version
    %   number of the object and should be called during this method.
    %
    %   As objects are only updated when they are loaded into memory, it is
    %   possible that objects of older versions remain on disk for a long
    %   time before being updated. For maximum backward compatibility, it
    %   is suggested to format this method in the following way:
    %   
    %   - - - - - -
    %   if obj.objVersion(2) == x
    %       do this...
    %       setobjversion(obj, x+1)
    %   end
    %   
    %           .
    %           .
    %           .
    %
    %   if obj.objVersion(2) == x+n
    %       do this...
    %       setobjversion(obj, obj.classVersion)
    %   end
    %   - - - - - -
    %
    %   This approach ensures that objects of all previous versions will be
    %   updated correctly to the latest version. 
    %
    %   see also: HDS.SETOBJVERSION HDSCAST

    % Copyright (c) 2012, J.B.Wagenaar
    % This source file is subject to version 3 of the GPL license, 
    % that is bundled with this package in the file LICENSE, and is 
    % available online at http://www.gnu.org/licenses/gpl.txt
    %
    % This source file can be linked to GPL-incompatible facilities, 
    % produced or made available by MathWorks, Inc.    
    
    % Delete the following message in the overloaded method:
    fprintf(2,'The object version changed but no overloaded UPDATEOBJ method was found.');
    
end