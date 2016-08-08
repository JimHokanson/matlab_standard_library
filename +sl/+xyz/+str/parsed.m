classdef parsed < sl.obj.handle_light
    %
    %   Class:
    %   sl.xyz.str.parsed
    %
    %
    
    properties
        raw_string %Input string
        
        d1 = '----  By Input Order ----'
        i_signs
        i_dims
        i_chars
        d2 = '---- By XYZ ----'
        xyz_signs = [0 0 0]
        xyz_order = [0 0 0]
        
        %NOTE: This could be a dependent variable ...
        missing_mask
        n_missing 
        
        %EXAMPLE:
        %       raw_string: '-zx'
        %               d1: '----  By Input Order ----'
        %          i_signs: [1 1]
        %           i_dims: [3 1]
        %               d2: '---- By XYZ ----'
        %        xyz_signs: [1 0 1]
        %        xyz_order: [2 0 1]
        %     missing_mask: [0 1 0]
        %        n_missing: 1
    end
    
    methods
        function obj = parsed(raw_string)
            %
            %
            %   obj = sl.xyz.str.parsed(raw_string)
            %
            %   Example:
            %   obj = sl.xyz.str.parsed('-zx')
            %
            %   IMPROVEMENTS
            
            obj.raw_string = raw_string;
            
            %NOTE: This parsing could probably be improved significantly
            %...
            
            letters = 'xyz';
            indices = zeros(1,3);
            for iLetter = 1:3
                I = find(raw_string == letters(iLetter));
                if length(I) > 1
                    error('Multiple instances of %s found',letters(iLetter));
                end
                if ~isempty(I)
                    indices(iLetter) = I;
                    if I ~= 1 && letters(I-1) == '-'
                        obj.xyz_signs(iLetter) = -1;
                    else
                        obj.xyz_signs(iLetter) = 1;
                    end
                end
            end
            obj.missing_mask = indices == 0;
            obj.n_missing = sum(obj.missing_mask);
            
            is_present_I = find(~obj.missing_mask);
            
            [~,Is] = sort(indices(indices ~= 0));
            
            obj.xyz_order(~obj.missing_mask) = Is;
            
            obj.i_dims  = is_present_I(Is);
            obj.i_signs = obj.xyz_signs(obj.i_dims);
            obj.i_chars = letters(obj.i_dims);
        end
    end
    
end

