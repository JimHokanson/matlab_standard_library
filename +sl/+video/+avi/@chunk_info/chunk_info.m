classdef (Hidden) chunk_info < handle
    %
    %   Class:
    %   sl.video.avi.chunk_info
    
    properties
        name
        depth
        is_list
        list_type
        data_start_I  %To start, we'll do this indexing in u32
        %and convert to uint8 later
        data_end_I
        next_start_index
        data_length %This will only be the valid bytes ...
        parent_index
        children_indices
        
        full_names
        
        cur_obj_count
    end
    
    methods (Static)
        function test(data)
            %sl.video.avi.chunk_info.test(data)
            sl.video.avi.chunk_info(data);
        end
    end
    
    methods
        function obj = chunk_info(data)
            %
            %   data - u32
            
            
            %LIST_VALUE = typecast(uint8('LIST'),'uint32');
            
            toU32 = [2^0 2^8 2^16 2^24]';
            
            INIT_LENGTH = 10000;
            obj.name   = zeros(4,INIT_LENGTH,'uint8');
            obj.depth  = zeros(1,INIT_LENGTH);
            obj.is_list          = false(1,INIT_LENGTH);
            obj.data_start_I     = zeros(1,INIT_LENGTH);
            obj.next_start_index       = zeros(1,INIT_LENGTH);
            obj.data_length      = zeros(1,INIT_LENGTH);
            obj.parent_index     = zeros(1,INIT_LENGTH);
            obj.children_indices = cell(1,INIT_LENGTH);
            
            %Object 1
            %-------------------------------------
            %TODO: Ensure data(1:4) = 'RIFF'
            %data(8:12) = 'AVI '
            obj.name(:,1)           = uint8('AVI ');
            obj.depth(1)            = 1;
            obj.data_start_I(1)     = 13;
            obj.is_list(1)          = true;
            
            temp_data_length        = double(typecast(data(5:8),'uint32')) - 4;
            obj.data_length(1)      = temp_data_length;
            obj.next_start_index(1) = temp_data_length + 12 + 1;
            
            %I think this would occur if the file is large and there
            %are extended AVI headers (AVIX)
            if obj.next_start_index(1) ~= length(data)+1
               error('Length mismatch, code improvements needed') 
            end
            
            obj.cur_obj_count = 1;
            depth_local       = 1;
            parent_indices    = 1;
            
            done = false;
            while ~done
                depth_local     =  depth_local + 1;
                start_obj_index = obj.cur_obj_count+1;
                
                obj.readObjectDepth(parent_indices,data,depth_local)
                
                end_obj_index   = obj.cur_obj_count;
                
                child_indices = start_obj_index:end_obj_index;
                
                parent_indices = child_indices(obj.is_list(child_indices));
                
                done = isempty(parent_indices);
            end
            
            n_objs = end_obj_index;
                        
            names = cellstr(char(obj.name(:,1:n_objs)'));
         
            full_names_local = cell(1,n_objs);
            depths = obj.depth(1:n_objs);
            
            %Could be improved ...
            full_names_local{1} = 'AVI';
            for iDepth = 2:max(depths)
               depth_mask     = iDepth == depths;
               parent_indices = obj.parent_index(depth_mask);
               parent_names   = full_names_local(parent_indices);
               I = find(depth_mask);
               for iObj = 1:length(I)
                  cur_index = I(iObj);
                  full_names_local{cur_index} = [parent_names{iObj} '.' names{cur_index}];
               end
            end
            
            obj.full_names = full_names_local;
            
            obj.name(n_objs+1:end)             = [];
            obj.depth(n_objs+1:end)            = [];
            obj.is_list(n_objs+1:end)          = [];
            obj.data_start_I(n_objs+1:end)     = [];
            obj.next_start_index(n_objs+1:end)       = [];
            obj.data_length(n_objs+1:end)      = [];
            obj.parent_index(n_objs+1:end)     = [];
            obj.children_indices(n_objs+1:end) = [];
            
            obj.data_end_I = obj.data_start_I + ceil(obj.data_length/4)*4 - 1;
            
        end
        function readObjectDepth(obj,parent_indices,data,depth_local)
            
            %LIST_VALUE = typecast(uint8('LIST'),'uint32');
            LIST_VALUE = uint32(1414744396);
                        
            coc  = obj.cur_obj_count;
            done = false;
            for iParent = 1:length(parent_indices)
                
                cur_parent_index = parent_indices(iParent);
                cur_data_index   = obj.data_start_I(cur_parent_index);
                stopping_index   = obj.next_start_index(cur_parent_index);
                
                starting_obj_index = coc+1;
                while ~done
                    coc = coc + 1;
                    
                    %NOTE: I am overgrabbing by one byte in the non-list
                    %case. This should be fine as long as the chunk is not
                    %empty and at the end of the file ...
                    u32_data  = typecast(data(cur_data_index:cur_data_index+15),'uint32');
                    
                    %name   - 1
                    %length - 2
                    %list_type - if a list - 3
                    %data - 4
                    
                    temp_name        = u32_data(1);
                    is_list_local    = temp_name == LIST_VALUE;
                    obj.is_list(coc) = is_list_local;
                    obj.name(:,coc)  = data(cur_data_index:cur_data_index+3);
                    obj.depth(coc)   = depth_local;
                    
                    temp_length        = double(u32_data(2));
                    if is_list_local
                        temp_length     = temp_length - 4;
                        obj.name(:,coc) = data(cur_data_index+8:cur_data_index+11);
                        offset = 12;
                    else
                        offset = 8;
                    end
                    
                    obj.data_start_I(coc) = cur_data_index + offset;
                    obj.data_length(coc)  = temp_length;
                    
                    cur_data_index       = obj.data_start_I(coc) + ceil(temp_length/4)*4;
                    obj.next_start_index(coc)  = cur_data_index;
                    
                    done = cur_data_index >= stopping_index;
                    %The first one is off (could be corrected)
                    %Subsequent ones are equal
                    %
                    %   TODO: Fix first one and implement check ...
                    
                    
                    
                    
% % %                     if done
% % %                        cur_data_index - stopping_index 
% % %                     end
% % %                     %??? - for the first set the lengths
% % %                     %are confusing:
% % %                     %
% % %                     %NOTE: We should be equal at this point ...
            
                    %fprintf('Name: %s\n',char(obj.name(:,coc)'))
                
                    %char(typecast(obj.name(:coc),'uint8'))
                end
                
                obj.parent_index(starting_obj_index:coc) = cur_parent_index;
                
                obj.children_indices{cur_parent_index} = starting_obj_index:coc;
            end
            obj.cur_obj_count = coc;
        end
    end
    
end

