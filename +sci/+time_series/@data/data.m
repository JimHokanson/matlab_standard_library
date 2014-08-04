classdef data < handle
    %
    %   Class:
    %   sci.time_series.data
    %
    %
    %   Methods to implement:
    %   - allow merging of multiple objects (input as an array or cell
    %       array) into a single object - must have same length and time
    %       and maybe units
    %   - allow plotting of channels as stacked or as subplots
    %   - averaging to a stimulus
    
    properties
        d    %numeric array
        time     %sci.time_series.time
        units
        n_channels
    end
    
    %Optional properties -------------------------------------------------
    properties
        
    end
    
    methods
        function obj = data(data_in,time_object_or_dt,varargin)
            %
            %    How to handle multiple channels?
            %
            %    obj = sci.time_series.data(data_in,time_object,varargin)
            %
            %    obj = sci.time_series.data(data_in,dt,varargin)
            %
            %
            %    data_in must be with samples going down the rows
            
            in.units = 'Unknown';
            in.channel_labels = ''; %TODO: If numeric, change to string ...
            in = sl.in.processVarargin(in,varargin);
            
            obj.n_channels = size(data_in,1);
            
            obj.d = data_in;
            
            if isobject(time_object_or_dt)
                obj.time = time_object_or_dt;
            else
                obj.time = sci.time_series.time(time_object_or_dt,obj.n_channels);
            end
            
            obj.units = in.units;
        end
        function plot(obj,channels)
            if ~exist('channels','var')
                temp = sl.plot.big_data.LinePlotReducer(obj.time,obj.d);
            else
                temp = sl.plot.big_data.LinePlotReducer(obj.time,obj.d(:,channels));
            end
            temp.renderData();
        end
    end
    
end

