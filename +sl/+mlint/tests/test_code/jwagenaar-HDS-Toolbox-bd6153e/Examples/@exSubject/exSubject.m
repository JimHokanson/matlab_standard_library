classdef exSubject < HDS
   %EXSUBJECT  Contains information about the subjects.
   %  This class is a child of the 'exMain' class (see constants) and can contain multiple
   %  'exExperiment' objects. Each exSubject has a name, an age and a gender.
   
   
   %   All properties used in the template are optional..
    properties
        name = ''           % The name of the subject.
        age  = 0            % The age of the subject.
        gender = 'm'        % Gender of subject 'm' / 'f'
    end
        
    
    % All constants used in the template are mandatory.
    properties ( Constant, Hidden )                 
        listAs         = 'subj'
        classVersion   = 1              
        childClasses   = {'exExperiment' 'exDiet'}                  
        parentClasses  = {'exMain'}                   
        metaProps      = {'name' 'age' 'gender'}   
        dataProps      = {}
        propsWithUnits = {}
        propUnits      = {}
        propDims       = {}
        strIndexProp   = 'name'
        maskDisp       = {}
    end
    
    
    
    % Class methods can be defined in the class definition file or as
    % separate files in the class definition folder.
    methods
    end
end
