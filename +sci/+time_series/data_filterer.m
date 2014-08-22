classdef data_filterer < handle
    %
    %   Class:
    %   sci.time_series.data_filterer
    %
    %   This class was written to go with the data class.
    %   It can either be called directly or via the filter() method of the
    %   data class.
    %
    %   TODO: Add usage example ...
    %
    %   TODO: Allow a shallow copy ...
    %
    %   See Also:
    %   sci.time_series.data
    %   sci.time_series.filter.butter
    %
    %
    %
    
    properties
    end
    
    properties (Hidden)
        data_filters = {} % (cell)
    end
    
    methods
        function set.data_filters(obj,value)
           %TODO: Should check for object type ...
           if ~iscell(value)
               obj.data_filters = {value};
           else
               obj.data_filters = value;
           end
        end
    end
    
    methods
        function obj = data_filterer(varargin)
            %
            %
            %   sci.time_series.data_filterer(varargin)
            
            in.filters = {};
            in = sl.in.processVarargin(in,varargin);
            obj.data_filters = in.filters;
            
        end

        function clearFilters(obj)
            obj.data_filters = {};
        end
        function addFilter(obj,filter)
            obj.data_filters = {obj.data_filters{:} filter}; %#ok<CCAT>
        end
        function data_out = filter(obj,data_objs,varargin)
            %
            %
            %   Inputs:
            %   -------
            %   data_objs : sci.time_series.data
            
            %TODO: Support data objects ...
            
            %TODO: Add history support ...
            
            %TODO: Allow merging filters ...
            
            %TODO: Allow a shallow copy
            in.additional_filters = [];
            in = sl.in.processVarargin(in,varargin);
            
            all_filters = obj.data_filters;
            
            if ~isempty(in.additional_filters)
                all_filters = [all_filters in.additional_filters];
            end
            
            
            if isempty(all_filters)
                error('There are no filters present')
            end
            
            
            
            for iObject = 1:length(data_objs)
                raw_data = data_objs(iObject).d;
                fs = data_objs(iObject).time.fs;
                %The actual filtering
                %-----------------------------
                for iFilter = 1:length(all_filters)
                    cur_filter_obj = all_filters{iFilter};

                    %TODO: Figure out how to make this generic ...

                    raw_data = cur_filter_obj.filter(raw_data,fs);


                end
                data_objs(iObject).d = raw_data;
            end
            
            
            
        end
    end
    
    methods (Static)
        function listAvailableFilters(obj)
           %TODO: Provide links
           fprintf('List of implemented filters\n');
           fprintf('------------------------------\n');
           fprintf('Butterworth: sci.time_series.filter.butter\n');
        end 
    end
    
    methods
        %         function disp()
        %             TODO: List filters in this object
        %             This should really call the display method of filters
        %         end
    end
    
end

