classdef exTrial < HDS
   %EXTRIAL  
   
   
   %   All properties used in the template are optional..
    properties
      name = ''     % The name of the trial
      id = 0        % The trialID
        
    end
    
    properties (Transient)
      data
    end
    
    % All constants used in the template are mandatory.
    properties ( Constant )                 
        listAs         = 'trial'
        classVersion   = 1              
        childClasses   = {}                  
        parentClasses  = {'exExperiment'}                   
        metaProps      = {'id'}   
        dataProps      = {'data'}
        propsWithUnits = {'data'}
        propUnits      = {'Volt'}
        propDims       = {{'Time' 'Channel'}}
        strIndexProp   = ''
        maskDisp       = {}
    end
    
    
    
    % Class methods can be defined in the class definition file or as
    % separate files in the class definition folder.
    methods
    end
end
