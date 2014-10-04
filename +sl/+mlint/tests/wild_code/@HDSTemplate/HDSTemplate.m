classdef HDSTemplate < HDS
    %HDSTemplate  This line is displayed in the methods function   
    %   This is the general help for objects of class HDSTEMPLATE...
    %
    %   -- -- --
    %
    %   This template object is specified according to the specifications
    %   required by the HDS Toolbox. There are a couple of required
    %   constants that have a specific function:
    %
    %   listas : Default property name in which objects of this class reside.
    %
    %   classVersion : Version of class definition, changing this will
    %   result in a call to the update method for the class ('UPDATEOBJ').
    %
    %   childClasses : Cell array of strings indicating the classes that
    %   can be added to objects of this class.
    %
    %   parentClasses : Cell array of strings indicating the classes to
    %   which objects of this class can be added.
    %
    %   metaProps : Unused at this time, will be used to indicate which
    %   properties should be indexed for the search function.
    %
    %   dataProps : Indicates which properties contain raw data. Data in
    %   these properties will be stored separately such that the object can
    %   be loaded without loading the rawdata. These properties should be
    %   defined as 'Transient' in the properties section.
    %
    %   propsWithUnits : Indicates which properties have associated units.
    %   The length of this vector should be the same size as that of
    %   'propUnits' and 'propDims'.
    %
    %   propUnits : Cell array with strings indicating the unit of the data
    %   in the property indicated at the same index in the 'propsWithUnits'
    %   property.
    %
    %   propsDims : Cell array with strings or cell array of strings
    %   indicating a label for each dimension of the data in the property
    %   indicated at the same index in the 'propsWithUnits' property. 
    %
    %   strIndexProp : String indicating a property that contains strings
    %   which can be used for indexing instead of the numeric index (i.e.
    %   'experiment('02-2009').trial(4)'
    %
    %   maskDisp : Cell array with strings that indicate properties that should
    %   not be evaluated when the object is displayed. This can be useful if
    %   you have dependent properties that take a while to return their content.
    %
    %   -- -- --
    %
    %   
    
    
    
    % All properties used in the template are optional.
    properties
        name = ''           % This line is showed in the PROPERTIES method
        meta1 = ''          % Help for meta1
        meta2 = []          % Help for meta2
    end
    
    properties( Transient ) % Transient status required for 'data'-properties
        rawData = []        % Help for rawData
    end
    
    
    % All constants used in the template are mandatory.
    properties ( Constant )                 
        listAs         = 'templ'
        classVersion   = 1              
        childClasses   = {'parentTemplate'}                  
        parentClasses  = {'subtemplate1' 'subtemplate2'}                   
        metaProps      = {'name' 'meta1' 'meta2'}   
        dataProps      = {'rawData'}
        propsWithUnits = {'rawData' 'meta2'}
        propUnits      = {'uV' 'Hz' }
        propDims       = { {'Channel' 'Time'} ''}
        strIndexProp   = 'name'
        maskDisp       = {}
    end
    
    
    
    % Class methods can be defined in the class definition file or as
    % separate files in the class definition folder.
    methods
        
        % UPDATEOBJ is an optional method and therefore not required.
        function obj = updateobj(obj)
            %UPDATEOBJ  Updates objects of subclass during load.   
            %   OBJ = UPDATEOBJ(OBJ) will update the object when it is
            %   loaded from disk and the version number of the object
            %   differs from the version number of the class definition.
            %   
            %   If implemented, this method can make the necessary
            %   adjustments to the object to update it to the current class
            %   version. 
            %
            %   The syntax shown below is an example for the implementation
            %   of this method and can be altered if necessary. However,
            %   the approach shown in this syntax should be a correct
            %   solution for most scenarios. 
            %
            %   See the HDS Toolbox documentation on updating objects for
            %   more information.
            %
            %   see also: SETOBJVERSION
            
            % The version of an object is stored in the hidden property
            % obj.objVersion. This property contains two values: 
            % [HDS_Toolbox_version HDS_SubClass_Version].
            version = obj.objVersion(2);
            
            while version ~= obj.classVersion
                version = obj.objVersion(2); 
                switch version
                    case 1
                        % ...
                        % ...
                        % Update from version 1 to version 2
                        setobjversion(obj,2);
                    case 2
                        % ...
                        % ...
                        % Update from version 2 to current class version
                        setobjversion(obj, obj.classVersion);
                    otherwise
                        error('Unable to correctly update object.');
                end
            end
        end
        
    end
end
