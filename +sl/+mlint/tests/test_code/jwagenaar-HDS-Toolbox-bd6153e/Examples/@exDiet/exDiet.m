classdef exDiet < HDS
   %EXDIET  Contains information about the diet over a period.
   %
   
   
   %   All properties used in the template are optional..
    properties
        startDate = ''      % Starting date of diet ('mm/dd/yyyy')
        endDate = ''        % End-date of diet ('mm/dd/yyyy')
        foodIntake = ''     % Summary of foodintake over Diet period. 
    end
        
    
    % All constants used in the template are mandatory.
    properties ( Constant )                 
        listAs         = 'diet'
        classVersion   = 1              
        childClasses   = {}                  
        parentClasses  = {'exSubject'}                   
        metaProps      = {'startDate' 'endDate'}   
        dataProps      = {}
        propsWithUnits = {}
        propUnits      = {}
        propDims       = {}
        strIndexProp   = ''
        maskDisp       = {}
    end
    
    
    
    % Class methods can be defined in the class definition file or as
    % separate files in the class definition folder.
    methods
    end
end
