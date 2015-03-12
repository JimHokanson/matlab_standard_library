classdef filter < handle
    %
    %   Class:
    %   sci.time_series.filter
    %
    %   This was meant to be a base class from which filters inherited
    %   but I haven't gotten their yet. There are also some slight
    %   differences between filters that might make generic inheritance
    %   more difficult (e.g. linear vs non-linear filters)
    %
    %   TODO: Require certain methods ...
    
    properties 
       needs_fs = true; %Override if necessary
    end
    
    methods
    end
    
end

