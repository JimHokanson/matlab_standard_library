classdef data_filterer < handle
    %
    %   Class:
    %   sci.time_series.data_filterer
    %
    %   TODO: Add usage example ...
    %
    %   TODO: Allow a shallow copy ...
    %
    %   See Also:
    %   sci.time_series.filter.butter
    
    properties
    end
    
    properties (Hidden)
        data_filters = {} % (cell)
    end
    
    methods
        function addFilter(obj,filter)
            obj.data_filters = {obj.data_filters{:} filter}; %#ok<CCAT>
        end
        function data_out = filter(obj,data,varargin)
            %
            %
            %
            
            in.dt = []; %Time between samples
            in.fs = []; %Sampling frequency
            in = sl.in.processVarargin(in,varargin);
            
            if isempty(obj.data_filters)
                error('There are no filters present')
            end
            
            %Resolving fs if necessary 
            %--------------------------------
            any_need_fs = any(sl.cell.getStructureField(obj.data_filters,'needs_fs'));
            
            if any_need_fs
                if ~isempty(in.fs) && ~isempty(in.dt)
                    error('Only fs or dt can be specified')
                elseif ~isempty(in.fs)
                    fs = in.fs;
                elseif ~isempty(in.dt)
                    fs = 1/dt;
                else
                    error('Sampling frequency is needed, please specify in input')
                end
            else
                %TODO: We might allow filters to create fs
                fs = [];
            end
            
            
            %The actual filtering
            %-----------------------------
            for iFilter = 1:length(obj.data_filters)
                cur_filter_obj = obj.data_filters{iFilter};
                if cur_filter_obj.needs_fs
                    data = cur_filter_obj.filter(data,fs);
                else
                    data = cur_filter_obj.filter(data);
                end
            end
            
            data_out = data;
            
        end
    end
    
    methods
        %         function disp()
        %             TODO: List filters
        %         end
    end
    
end

