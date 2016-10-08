classdef keyboard_logger < handle
    %
    %   Class:
    %   sl.os.keyboard_logger
    
    %{
    
    https://www.mathworks.com/help/matlab/matlab_oop/events-and-listeners--syntax-and-techniques.html
    
    
    Test Code
    ---------
    
    %}
    
%     properties
%         %https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
%         vk_code_mask
%     end
    
    events
       keyboard_up
       keyboard_down
       keyboard_event
    end
    
    methods (Access = private)
        function obj = keyboard_logger()
            sl.os.log_keyboard();
            %obj.vk_code_mask = false(1,256);
        end
    end
    
    methods (Static)
        %This can be run as an example 
        function lh = keyboardListerExample()
            %
            %   lh = sl.os.keyboard_logger.keyboardListerExample();
            
            lh = sl.os.keyboard_logger.addKeyboardUpListener(@h__demo);
        end
    end
    
    methods (Static)
        function lh = addKeyboardUpListener(callback_fh)
            %
            %   sl.os.keyboard_logger.addKeyboardUpListener
            
            obj = sl.os.keyboard_logger.getInstance();
            lh = obj.addlistener('keyboard_up',callback_fh);
        end
        function lh = addKeyboardDownListener()
            %
            %   sl.os.keyboard_logger.addKeyboardDownListener
            obj = sl.os.keyboard_logger.getInstance();
            lh = obj.addlistener('keyboard_down',callback_fh);
        end
        function addKeyboardListener()
            %
            %   sl.os.keyboard_logger.addKeyboardListener
        end
        function obj = getInstance()
           persistent local_object
           if isempty(local_object)
               disp('New object created')
               local_object = sl.os.keyboard_logger();
           end;
           
           obj = local_object;
        end
        function keyboardEvent(input_string)
            
            s1 = regexp(input_string,':','split');
            obj = sl.os.keyboard_logger.getInstance();
            event_data = sl.os.keyboard_event_data();
            
            s = struct;
            s.raw = input_string;
            s.key_pressed = strcmp(s1{1},'0');
            s.vk_code = str2double(s1{2});
            s.hw_code = str2double(s1{3});
            s.time = str2double(s1{4});
            s.shift = strcmp(s1{5},'1');
            s.ctrl  = strcmp(s1{6},'1');
            s.caps  = ~strcmp(s1{7},'0');
            
            %Debugging code
%             if ~s.key_pressed
%                 fprintf('VK_CODE: %d, SHIFT: %d\n',s.vk_code,s.shift);
%                 return
%             end


            event_data.s = s;
            
            notify(obj,'keyboard_event',event_data);
            
            if s.key_pressed
                notify(obj,'keyboard_down',event_data);
            else
                notify(obj,'keyboard_up',event_data);
            end
            
        end
    end
    
end

function h__demo(obj,event_data)

%Virtual keys
%------------
%37 - left
%38 - up
%39 - right
%40 - down

s = event_data.s;
vk_code = s.vk_code;

%We're only going to show releases
% if s.key_pressed
%     return
% end

%TODO: These could be extended methods of data ...
if vk_code >= 37 && vk_code <= 40
    disp('Arrow key pressed')
elseif vk_code >= 48 && vk_code <= 57 && ~s.shift && ~s.ctrl
    %Or this could be a specical character, depends on 
    disp('Numeric value pressed')
elseif vk_code >= 65 && vk_code <= 90  && ~s.ctrl
    capitalized = xor(s.shift,s.caps);
    char_to_display = char(vk_code);
    if ~capitalized
        char_to_display = lower(char_to_display);
    end
    fprintf('Pressed the letter: %s\n',char_to_display);
end
        

% % % %            s.raw = input_string;
% % %             s.key_pressed = strcmp(s1{1},'0');
% % %             s.vk_code = str2double(s1{2});
% % %             s.hw_code = str2double(s1{3});
% % %             s.time = str2double(s1{4});
% % %             s.shift = strcmp(s1{5}(1),'-');
% % %             s.ctrl  = strcmp(s1{6}(1),'-');
% % %             s.caps  = ~strcmp(s1{7},'0');

end
