classdef iterative_max_distance < sl.obj.handle_light
    %
    %   Class:
    %   sci.cluster.iterative_max_distance
    %
    %   This class handles the problem of iteratively finding points that
    %   are the furthest away from all previously selected points.
    %   
    %   MAIN METHOD
    %   ===================================================================
    %   sci.cluster.iterative_max_distance.solve (called by constructor)
    
    %Options ==============================================================
    properties
       K = 20 %The larger we make this, the less likely we are to need more
       %data, but the longer the initializaton takes ...
       %
       %We might adjust this to have relatively constant initialization
       %time which we can guess from the length of the input data ...
       %
       %For small data sets we could also compute the distance directly ...
    end
    
    %Inputs ===============================================================
    properties
       d1 = '----  Inputs  ----'
       previous_data    %[n x d] - might be empty
       new_data         %[n x d]
       starting_indices %[1 x m] - if not specified this will be determined 
       %by the program ...
    end
    
    %Outputs ==============================================================
    properties
       d2 = '----  Outputs  ----'
       %All of these are ordered by evaluation, not by the input indices ...
       exhaustive_search
       index_order
       max_distance
    end
    
    methods
        function obj = iterative_max_distance(new_data,varargin)
            
           in.previous_data    = [];
           in.starting_indices = [];
           in = sl.in.processVarargin(in,varargin); 
            
           obj.previous_data    = in.previous_data;
           obj.new_data         = new_data;
           obj.starting_indices = in.starting_indices;
           
           obj.solve();
        end
    end
    
end

