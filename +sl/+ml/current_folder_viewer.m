classdef current_folder_viewer
    %
    %   Class:
    %   sl.ml.current_folder_viewer
    
    %{
        v = sl.ml.current_folder_viewer();
        v.expandTo('D:\repos\matlab_git\bladder_analysis\+dba\+user_analysis\+jah\+pudendal_stim\+p180802_state_dependent_paper');
    %}
    
    %{
    root = cd;
    mkdir(cd,'test_root')
    cd test_root
    for i = 1:50
        root2 = cd;
        name = sprintf('test%d',i);
        mkdir(cd,name);
        cd(name)
        for j = 1:20
            root3 = cd;
            name = sprintf('test%d',j);
            mkdir(cd,name);
            cd(name)
            for k = 1:5
                root4 = cd;
                name = sprintf('test%d',k);
                mkdir(cd,name);
            end
            cd(root3)
        end
        cd(root2)
    end
    cd(root)
    cd test_root
    
    h = com.mathworks.mde.explorer.Explorer.getInstance;
    table = h.getTable;
    
    r = table.getRowAt(0);
    n1 = r.getChildrenCount;
    r.setExpanded(true);
    %This says true, even though r2
    %will be null
    x = r.isExpanded;
    %Setting this longer allows the expansion to occur
    %and for r2 to be valid
    %pause(0.01);
    r2 = r.getChildAt(1);
    
    %}
    properties
        h
        table
    end
    
    methods
        function obj = current_folder_viewer()
            %
            %   obj = sl.ml.current_folder_viewer()
            
            
            obj.h = com.mathworks.mde.explorer.Explorer.getInstance;
            obj.table = sl.ml.current_folder_viewer.table(obj.h);
            
            
            %toolbar
            %table
            %t = obj.h.getTable
            %t.expandFirstLevel - expands all folders at current level
            %t.collapseFirstLevel
            
            %How to tell what is what???
            %t.expandableRowAtPoint
            
            %t2 = t.getRowAt(0)
            %=> get's first row ...
            
            
            %row - t2.isExpandable
            %t2.setExpanded(true)
            
            
            %Methods I need:
            %---------------
            %1) Get entry - file or folder by name
        end
        function expandTo(obj,target_path)
            
            is_file = exist(target_path,'file') && ~exist(target_path,'dir');
            
            input_path = target_path;
            
            if is_file
                target_path = fileparts(target_path);
            end
            
            %TODO: This might be better with enumerators as we might
            %be able to get all parts and expand them and just wait
            %
            %   => although ideally we would have an option to allow
            %   blocking, as the above would be non-blocking
            
            d = cd();
            if ~strncmp(d,target_path,length(d))
                error('Unable to expand to path when path is not a sub-path of the current directory')
            end
            
            %This is ugly, ideally this would be some nice function
            all_parts = cell(1,50);
            temp_d = target_path;
            i = 0;
            while ~strcmp(temp_d,d)
                i = i + 1;
                [temp_d,last_bit] = fileparts(temp_d);
                all_parts{i} = last_bit;
            end
            
            %reverse order
            next_names = all_parts(i:-1:1);
            
            %Going from:
            %a  to a/b/c/d/e
            %need to find b then c then d
            %next_names holds these names
            
            
            
            cur_path = d;
            for i = 1:length(next_names)
                cur_name = next_names{i};
                if i == 1
                    root = obj.table;
                    count = root.row_count;
                    getChild = @(x)root.getRowByIndex(x);
                else
                    root = r2;
                    count = root.n_visible_children;
                    getChild = @(x)root.getChildByIndex(x);
                end
                is_good = false;
                for j = 1:count
                    r2 = getChild(j);
                    if strcmp(r2.name,cur_name)
                        if ~r2.expanded
                            r2.expanded = true;
                        end
                        if ~r2.expanded
                           error('wtf matlab') 
                        end
                        is_good = true;
                        cur_path = fullfile(cur_path,cur_name);
                        break
                    end
                end
                if ~is_good
                    error('Unable to find match at %s for %s',cur_path,cur_name)
                end
            end
        end
    end
end

