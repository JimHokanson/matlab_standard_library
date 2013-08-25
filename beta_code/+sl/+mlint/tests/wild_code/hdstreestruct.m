function out = hdstreestruct(input)
    %HDSTREESTRUCT   Returns a structure outlying the tree stucture.
    %   OUT = HDSTREESTRUCT(OBJ) determines the structure of the tree based on the
    %   classes that are defined in it. This method is used by the hdsfind
    %   method to determine possible search paths throught the database.
    %
    %   OUT = HDSTREESTRUCT('classStr') returns the 
    
    % Out is struct with fields: 'classes' 'metaNames' and 'links' where links is a
    % sparse matrix with booleans indicating parent/children relations.
    % metaNames is a cellarray of strings with all meta property names
    % found in the database.
    
    % This function computes the mHDS structure used for search.
  
    % Copyright (c) 2012, J.B.Wagenaar
    % This source file is subject to version 3 of the GPL license, 
    % that is bundled with this package in the file LICENSE, and is 
    % available online at http://www.gnu.org/licenses/gpl.txt
    %
    % This source file can be linked to GPL-incompatible facilities, 
    % produced or made available by MathWorks, Inc.
        
    if isa(input,'HDS')   
        obj = input;
    
        if length(obj)>1
            throwAsCaller(MException('HDS:HDSTREESTRUCT','HDSTREESTRUCT  Method can only be called with a single HDS object.'));
        end

        treeId = obj.treeNr;
        if treeId==0
            [~, treeId] = registerObjs(obj);
        end
    end
        
    hdspreventreg(true);
    classes = cell(50,1); %Random length can increase if necessary.
    classes{1} = input;
    ix = 1;
    fav = 2;
    while 1
        
        try
            tobj = eval(classes{ix});
            if ~isempty(tobj.parentClasses)
                for i = 1:length(tobj.parentClasses)
                    if ~any(strcmp(tobj.parentClasses{i},classes(1:fav-1)))
                        classes{fav} = tobj.parentClasses{i};
                        fav = fav+1;
                    end
                end
            end
            if ~isempty(tobj.childClasses)
                for i = 1:length(tobj.childClasses)
                    if ~any(strcmp(tobj.childClasses{i},classes(1:fav-1)))
                        classes{fav} = tobj.childClasses{i};
                        fav = fav+1;
                    end
                end
            end
            ix = ix +1;
        catch ME
            display(ME)
            ix = ix +1;
        end
        if ix == fav
            break
        end
        
    end
    classes = classes(1:fav-1);
    hdspreventreg(false);
    
    out = struct('classes', [], 'links', [], 'metaNames', []);
    out.classes = struct('name',[],'metaIds',[]);
        
    % Define the links matrix. Colums are the parent indeces, rows are the
    % children indeces.
    out.links = sparse(false(length(classes)));
    
    for iClass = 1:length(classes)
        
        out.classes(iClass).name = classes{iClass};
        
		hdspreventreg(true);
        try
            tobj = eval(classes{iClass});
        catch ME
            throwAsCaller(MException('HDSTREESTRUCT:UNABLETOEVAL',sprintf('HDSTREESTRUCT  Unable to evaluate class %s',upper(classes{iClass}))));
        end
                
        hdspreventreg(false);
        metaP = tobj.metaProps;
        chldP = tobj.childClasses;
        
        chldPIx = zeros(length(chldP),1);
        for iCld =1 : length(chldP)
            aux = find(strcmp(chldP{iCld},classes),1);
            if ~isempty(aux)
                chldPIx(iCld) = aux;
            end
        end
        % Remove childClasses that are not used in current dataTree
        chldPIx(chldPIx==0) = [];
        out.links(chldPIx,iClass) = true;
        
        % Now put meta properties in vector if they are not previously
        % defined.
        newMeta = false(length(metaP),1);
        for Imeta = 1: length(metaP)
            newMeta(Imeta) = ~any(strcmp(metaP{Imeta}, out.metaNames));
        end
        out.metaNames = [out.metaNames metaP(newMeta)];
        
    end
    
    % Check if the tree contains a single parent and everything is linked
    % to parent.
    
    % Now find the metaIds per class
    for iClass = 1:length(classes)
		hdspreventreg(true);
        tobj = eval(classes{iClass});
		hdspreventreg(false);
        metaP = tobj.metaProps;
        
        metaId = zeros(length(metaP),1);
        for iMeta =1: length(metaId)
            metaId(iMeta) = find(strcmp(metaP{iMeta},out.metaNames),1);
        end
        out.classes(iClass).metaIds = sort(metaId);
    end    

end