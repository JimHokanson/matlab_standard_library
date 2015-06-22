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
            %   output = sl.cell.getStructureField(cell_input,field_name,varargin)
            %
            %   Optional Inputs:
            %   ----------------
            %   un : logical (default true)
            %       false - output is a cell array
            %       true - output is an array. If the output can not be 
            %           placed in an array an error will be thrown.
            
            in.un = true; %Uniform, default true (for cellfun)
            in = sl.in.processVarargin(in,varargin);
            
            output = cellfun(@(x) x.(field_name),cell_input,'un',in.un);
            
        end
    end
    
end

