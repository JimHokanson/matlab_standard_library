classdef struct < dynamicprops
    %
    %   Class:
    %   sl.obj.struct
    %
    %   Purpose
    %   -------------------------------------------------------------------
    %   The goal of this class is to perform struct like behavior with the
    %   handle behavior of an object. Most of the cases in which people
    %   seem to have mentioned this is in the context of memory management,
    %   which could be relevant, although for the most part I trust that
    %   Matlab and copy-on-write take care of this for me.
    %
    %   Instead, this is basically meant to act as a struct but with the
    %   added benefit of all changes to the structure propogating to anyone
    %   that has a reference to the structure. See 'Benefits' for more
    %   info.
    %
    %   Benefits
    %   -------------------------------------------------------------------
    %   1) From structs, lazy property instantiation:
    %   s = sl.obj.struct;
    %   s.data = 1:10
    %
    %   2) From handle classes, change propogation:
    %   s = sl.obj.struct;
    %   s.test = 1;
    %   b = s;
    %   b.test = 3; %new value
    %   s.test:
    %       => 3  %Value updated since b == s
    %
    %   Current Differences
    %   -------------------------------------------------------------------
    %   1) Multiple level indexing not supported (it is possible to do,
    %   just more work!)
    %
    %       s.a.b.c = d
    %
    %   2) Differences in definitions between objects is currently allowed.
    %      In other words this is ok.
    %
    %     s1.a = 1
    %     s2.b = 2
    %     s = [s1 s2];
    %
    %
    %   Note on subasgn implementations:
    %   -------------------------------------------------------------------
    %   I have yet to see an implementation of subsasgn and subsref that I
    %   thought was really simple, clean, and worked. It is likely
    %   that subsasgn will need to be updated as new corner cases arise.
    %   Ideally these are well documented and explained since I think the
    %   whole thing is really complicated. Ideally a better testing
    %   framework than what I am currently using will be introduced to
    %   handle this.
    %
    %   Questions:
    %   -------------------------------------------------------------------
    %   1) What about deal?
    %
    %
    %   Surprises:
    %   -------------------------------------------------------------------
    %   1) Like structs, insantation via indexing is supported since
    %   subsasgn calls this class if the variable is not yet defined.
    %
    %   i.e., this is fine:
    %       s(30) = sl.obj.struct;
    %
    %   this however is not:
    %   s = []
    %   s(30) = sl.obj.struct;
    
    
    %TODO: The display is broken ...
    %no properties are displayed ...
    
    properties
    end
    
    methods (Static)
        function objs = fromMatlabStruct(s)
            %
            %   This is meant to be a quick way of instantiating
            %   this class from a normal structure.
            %
            %   NOTE: TMW decided not to call the class's subsasgn
            %   method in class methods so these calls skip subsasgn
            %   and are a lot quicker.
            %
            %   sl.obj.struct.fromMatlabStruct
            
            n_structs       = length(s);
            objs(n_structs) = sl.obj.struct;
            fn   = fieldnames(s);
            n_fn = length(fn);
            
            if n_structs == 1
                
                      %s:
                %    .type = '.'
                %    .subs = 'test'
                
                %cellfun(@(x) addprop(objs,x),fn);
                
                for iFn = 1:n_fn
                    cur_fn = fn{iFn};
                    addprop(objs,cur_fn);
                    objs.(cur_fn) = s.(cur_fn);
                end
            else
                for iFn = 1:n_fn
                    cur_fn = fn{iFn};
                    
                    %aaaaaaahhhhhh
                    %http://www.mathworks.com/matlabcentral/answers/31625-addprop-function-error
                    for iObj = 1:n_structs
                        addprop(objs(iObj),cur_fn);
                        objs(iObj).(cur_fn) = s(iObj).(cur_fn);
                    end
                    
                    %deal doesn't work either :/
                    %[objs.(cur_fn)] = deal(s.(cur_fn));
                    %       message: 'No public field a exists for class sl.obj.struct.'
                    %     identifier: 'MATLAB:noPublicFieldForClass'
                    %          stack: [1x1 struct]
                    %
                    %
                    %           addprop(objs,cur_fn)
                    %        message: [1x194 char]
                    %     identifier: 'MATLAB:class:RequireScalar'
                    %          stack: [0x1 struct]addPropsLocal(objs,cur_fn)

                end
            end
        end
    end
    
    methods (Hidden)
        %         function addAndAssign(objs,name)
        %             for iObj = 1:length(objs)
        %                 addprop(objs(iObj),name)
        %                 objs(iObj).(
        %             end
        %         end
    end
    
    methods
        function objs = subsasgn(objs, s, value)
            %
            %
            %   Current Differences
            %   -------------------------------------------
            %   1) It is not possible to create an object
            %   from subsasgn, unlike a struct
            %
            %   i.e.
            %   s.a = 1; %Creates struct s with property a
            %
            %   Handled Cases:
            %   -------------------------------------------
            %   1) obj.(prop_name) = value
            %
            %       ?? - need to check
            %      objs.(prop_name) = value
            %
            %      For structures this would not be good
            %
            %   2) obj(indices)    = objs
            %   3) obj(indices).(prop_name) = value
            
            
            if length(s) == 1 && strcmp(s.type,'.')
                %Case 1
                %-----------------------------------------------------------
                %wtf.('test') = 1
                %
                %s:
                %    .type = '.'
                %    .subs = 'test'
                
                prop_name = s.subs;
                %TODO: What happens for multiple objects ...
                %objs.test = 1 ?????
                if ~isprop(objs,prop_name)
                    addprop(objs,prop_name);
                end
                objs.(prop_name) = value;
            elseif length(s) == 1 && strcmp(s.type,'()')
                %Case 2
                %-----------------------------------------------------------
                %wtf(3) = sl.obj.struct
                %
                %s:
                %    .type: '()'
                %    .subs: {[3]}
                %
                %??? - why is subs a cell array?
                %
                %    Could be {1:2, ':'} for something like:
                %    wtf(1:2,:)
                
                indices = s(1).subs{1};
                objs = helper__expandObjects(objs,indices);
                objs(indices) = value;
                
                %    possible violtations:
                %    -------------------------------------------
                %    1) assignment of non-object value
                %    2) multiple,dimensions not supported ...
                %    3) colon operator not yet supported
                %
                %	 possible improvements (besides fixing violations)
                %    ---------------------------------------------------
                %    1) don't allow object growth
                %    2) enforce property similarity on merger
                %    - this could get messy ...
                %    - for example, the following is an error
                %    as a struct but allowable with dynamicprops:
                %
                %    s1.a = 1
                %    s2.b = 2
                %    s1(2) = s2;
                %
                %
                %       message: 'Subscripted assignment between dissimilar structures.'
                %    identifier: 'MATLAB:heterogeneousStrucAssignment'
                %         stack: [0x1 struct]
                
            elseif length(s) == 2 && strcmp(s(1).type,'()') && strcmp(s(2).type,'.')
                %Case 3
                %----------------------------------------------------------
                %                wtf(2).a = 15
                %                 s(1)
                %                     type: '()'
                %                     subs: {[2]}
                %                 s(2)
                %                     type: '.'
                %                     subs: 'a'
                %
                
                indices   = s(1).subs{1};
                prop_name = s(2).subs;
                
                %This supports object expansion based on indexing
                objs = helper__expandObjects(objs,indices);
                
                mask = ~isprop(objs(indices),prop_name);
                if any(mask)
                    addprop(objs(indices(mask)),prop_name);
                end
                
                objs(indices).(prop_name) = value;
                
            else
                for i = 1:length(s)
                    fprintf('i = %d\n',i)
                    disp(s(i))
                end
                error('Unhandled subsasgn case, pleae update code if request is valid')
            end
            
            
        end
    end
end

function objs = helper__expandObjects(objs,indices)
mx_index = max(indices);
if mx_index > length(objs)
    if isempty(objs)
        clear('objs'); %Yikes ...
    end
    objs(mx_index) = sl.obj.struct;
end
end

function helper__testCode()
%
%
%   TODO: Make explicit checks ...
%{


wtf = sl.obj.struct;
wtf.test = 3;
wtf2 = sl.obj.struct;
wtf2.a = 10
wtf(2) = wtf2;
wtf(2).a = 15;
wtf2

%}
end

