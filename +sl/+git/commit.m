classdef commit < handle
    %
    %   Class:
    %   sl.git.commit
    %
    
    
    %{
abbreviate         copyTo             getClass           getFullMessage     getRawBuffer       hasAny             parse              wait
add                equals             getCommitTime      getId              getShortMessage    hashCode           remove             zeroId
carry              fromRaw            getCommitterIdent  getName            getTree            isId               reset
compareTo          fromString         getEncoding        getParent          getType            name               startsWith
copy               getAuthorIdent     getFirstByte       getParentCount     has                notify             toObjectId
copyRawTo          getByte            getFooterLines     getParents         hasAll             notifyAll          toString
    
    %}
    
    
    
    
    properties
        summary
        description %????? - how to get this?? Subtract summary????
    end
    properties
        author_name
        author_email
        time_zone %ex. GMT-04:00
    end
    
    properties (Hidden)
        h %org.eclipse.jgit.revwalk.RevCommit
    end
    
    methods
        function obj = commit(j_commit)
            %
            %   Inputs:
            %   -------
            %   j_rev_walker: org.eclipse.jgit.revwalk.RevWalk
            %       http://download.eclipse.org/jgit/docs/latest/apidocs/org/eclipse/jgit/revwalk/RevWalk.html
            
            %TODO: We could make all of these lazy properties ...
            
            obj.h = j_commit;
            
            obj.summary = char(j_commit.getShortMessage);
            temp = char(j_commit.getFullMessage);
            if length(obj.summary) + 1 == length(temp)
                obj.description = ''; %This avoids a [1x0 char]
            else
                obj.description = temp(length(obj.summary)+2:end);
            end
            
            j_person_ident   = j_commit.getAuthorIdent();
            obj.author_name  = char(j_person_ident.getName);
            obj.author_email = char(j_person_ident.getEmailAddress);
            
            j_zone_info   = j_person_ident.getTimeZone;
            obj.time_zone = char(j_zone_info.getID);
        end
    end
    methods (Static)
        function commit_objs = create(j_rev_walker,varargin)
            %
            %   sl.git.commit.create(j_rev_walker,varargin)
            %
            in.max_count = 1000;
            in = sl.in.processVarargin(in,varagin);
            %Can we get a count????
            %We could probably pass it in optionally
            temp = cell(1,in.max_count); %TODO: We can increase this if we overflow
            iObj = 0;
            j_commit = j_rev_walker.next;
            while ~isempty(j_commit)
                iObj = iObj + 1;
                temp{iObj} = sl.git.commit(j_commit);
            end
            
            commit_objs = temp(1:iObj);
            
        end
    end
    
end

