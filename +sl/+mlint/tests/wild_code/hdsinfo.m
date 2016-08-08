function varargout = hdsinfo()                                                 
    %HDSINFO  Provides information about the currengtly active HDS objects.
    %   HDSINFO() displays the standard information about the HDS objects,
    %   such as the number of objects in memory and the amount of memory
    %   that is used for these objects.
    %
    %   OUT = HDSINFO(...) returns the amount of memory in kB that is used
    %   for the HDS objects and ignores any input arguments.
    %
    %   see also: HDSmonitor

    % Copyright (c) 2012, J.B.Wagenaar
    % This source file is subject to version 3 of the GPL license, 
    % that is bundled with this package in the file LICENSE, and is 
    % available online at http://www.gnu.org/licenses/gpl.txt
    %
    % This source file can be linked to GPL-incompatible facilities, 
    % produced or made available by MathWorks, Inc.
    
    global HDSManagedData

    if nargin
        throwAsCaller(MException('HDS:hdsinfo','HDSINFO: Incorrect number of input arguments.'));
    end  
    
    ll = length(HDSManagedData);
    
    paths  = cell(ll,1);
    mem    = zeros(ll,1);
    nobj   = zeros(ll,1);
    nuobj  = zeros(ll,3);
    links  = cell(ll,1);

    
    for i = 1: length(HDSManagedData)
        activeIds   = HDSManagedData(i).objIds(1,:) >0;
        aux         = HDSManagedData(i).basePath;
        if isempty(aux)
            aux = '''Unsaved data structure''';
        end
        paths{i}    = aux;
        mem(i)      = sum(HDSManagedData(i).objIds(6,activeIds))/1000;
        nobj(i)     = sum(activeIds);
        nuobj(i,1)  = sum(HDSManagedData(i).objBools(1,activeIds) | HDSManagedData(i).objBools(2,activeIds));
        nuobj(i,2)  = sum(HDSManagedData(i).objBools(1,activeIds));
        nuobj(i,3)  = sum(HDSManagedData(i).objBools(2,activeIds));
        links{i}    = sprintf('<a href="matlab:HDS.assignhostinbase(%d)">%s</a>',HDSManagedData(i).treeConst(1), HDSManagedData(i).classes{1});
    end
    
    
    
    if nargout
        varargout{1} = sum(mem);        
    else
        % If no objects in memory, set option to 0
        if isempty(mem)
            HDS.displaymessage('-- HDS Info -- --',2,'\n','');
            fprintf(' - Number of data structures : %7.1d\n',length(HDSManagedData));
            HDS.displaymessage('-- -- -- -- -- --',2,'','\n');   
            
        else
            
            HDS.displaymessage('-- HDS Info -- --',2,'\n','');
                        
            for i = 1: length(HDSManagedData)
                if length(HDSManagedData)>1
                    fprintf('%d)\n',i);
                    inset = ' ';
                else
                    inset = '';
                end
                
                fprintf('%s - Session time duration     : %0.0f sec\n',inset, (60*1440)*(datenummx(clock) - HDSManagedData(i).treeInitTime));
                fprintf('%s - Memory usage              : %0.0f kB\n',inset,mem(i));
                fprintf('%s - Total number of objects   : %d\n',inset, nobj(i));
                fprintf('%s - Number of unsaved objects : %d / %1.1d / %1.1d (Total/Obj/Data)\n',inset, nuobj(i,1), nuobj(i,2),nuobj(i,3));
                fprintf('%s - Host object               : %s\n',inset,links{i});
                fprintf('%s - BasePath                  : %s\n',inset,paths{i});
            end
            
            HDS.displaymessage('-- -- -- -- -- --',2,'','\n');   
            
        end

    end
    
end


