classdef (Hidden) simple_prompt_data < dynamicprops
    %
    %   Class:
    %   sl.gui.simple_prompt_data
    %
    %   This class holds the user data for the gui interface. It also
    %   allows implementation of get methods
    %
    %   See Also:
    %   simple_prompt
    
    %{
        TEST_CODE
        ===================================================================
        %TODO: Create sample gui that shows this as an example ...
        wtf = sl.gui.simple_prompt_data('',{'prop1','cheese','prop2',1:10});
    
    %}
    
    properties (Access = private,Hidden)
        spd__p  %spd => simple_prompt_data
        spd__names
        spd__h
    end
    
    methods
        function obj = simple_prompt_data(h,prop_value_pairs)
            %TODO: Should check to make sure we are not setting the
            %user specific props
            
            obj.spd__h     = h;
            obj.spd__names = prop_value_pairs(1:2:end);
            
            for iPair = 1:2:length(prop_value_pairs)
                cur_field_name = prop_value_pairs{iPair};
                
                %TODO: Clean this up
                if iPair == 1
                    obj.spd__p        = obj.addprop(cur_field_name);
                else
                    obj.spd__p(end+1) = obj.addprop(cur_field_name);
                end
                
                obj.(cur_field_name) = prop_value_pairs{iPair+1};
            end
        end
        
        %NOTE: For we could add another method which retrieves based on
        %having access to data and the function handles ...
        function setGetMethodSimple(obj,variable_name,tag_name,type)
            %
            %    TODO: Finish documentation
            %
            if ~exist('type','var')
                type = 'String';
            end
            
            %findprop
            
            I = strcmp(obj.spd__names,variable_name);
            
            obj.spd__p(I).GetMethod = (@(x) get(x.spd__h.(tag_name),type));
        end
    end
%     
%     methods (Hidden)
%         function getGeneric(obj)
%         
%     end
    
end

