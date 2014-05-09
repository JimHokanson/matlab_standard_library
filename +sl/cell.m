classdef cell
    %
    %   Class:
    %   sl.cell
    
    properties
    end
    
    methods (Static)
        function output = getStructureField(cell_input,field_name,varargin)
            %x Grabs a field from each structure in the cells of an array
            %
            %   varargout = sl.cell.getStructureField(cell_input,field_name,varargin)
            
            in.un = true; %Uniform, default true (for cellfun)
            in = sl.in.processVarargin(in,varargin);
            
            output = cellfun(@(x) x.(field_name),cell_input,'un',in.un);
            
        end
    end
    
end

