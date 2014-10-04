classdef exExperiment < HDS
   %EXEXPERIMENT  
   
   
  %   All properties used in the template are optional..
  properties
    name = ''           % Name of the experiment
    date = ''           % The date of the experiment ('mm/dd/yyyy')
    protocolNr = ''     % Protocol ID 
  end
        
    
  % All constants used in the template are mandatory.
  properties ( Constant )                 
      listAs         = 'exp'
      classVersion   = 1              
      childClasses   = {'exTrial'}                  
      parentClasses  = {'exSubject'}                   
      metaProps      = {'date' 'protocolNr'}   
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
