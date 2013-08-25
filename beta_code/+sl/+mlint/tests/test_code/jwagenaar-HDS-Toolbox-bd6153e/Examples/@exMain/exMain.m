classdef exMain < HDS
   %EXMAIN  First class in the data hierarchy.
   %  This class does not have any parent classes (see constants) and is therefore the topmost class
   %  of the data structure. It contains a single property to identify the name of the database and
   %  can contain multiple 'exSubject' children.
   
   
   %   All properties used in the template are optional..
    properties
        dbName = ''           % This line is showed in the PROPERTIES method
    end
        
    
    % All constants used in the template are mandatory.
    properties ( Constant )                 
        listAs         = 'main'
        classVersion   = 1              
        childClasses   = {'exSubject'}                  
        parentClasses  = {}                   
        metaProps      = {'dbName'}   
        dataProps      = {}
        propsWithUnits = {}
        propUnits      = {}
        propDims       = {}
        strIndexProp   = 'dbName'
        maskDisp       = {}
    end
    
    
    
    % Class methods can be defined in the class definition file or as
    % separate files in the class definition folder.
    methods
    end
end
