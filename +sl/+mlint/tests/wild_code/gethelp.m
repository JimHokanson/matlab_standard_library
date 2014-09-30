function [mainText, firstLine, commentTokens, CommentLines, mFileText, filePath] = gethelp(classStr, varargin)
    

%GETHELP  Returns the help lines for a given Class or Method.
    %   mFileText = GETHELP('inputStr') returns the help-lines for a method or
    %   class specified by the 'inputStr' string.
    %
    %   [mFileText, FL] = GETHELP('inputStr') separates the output of the help
    %   lines in the main help lines (mFileText) and the FirstLine (FL). The FL
    %   line is the first line of the help mFileText minus the capitalized
    %   method or class name.
    %
    %   [mFileText, FL, LINES] = GETHELP('inputStr') alse returns an 2xn array
    %   with the start and stop indeces for each line of mFileText in the
    %   .m-file.
    %
    %   The FL is determined by matching the 'inputStr' with the first word
    %   on the first line of the help mFileText. If there is a match, the first
    %   line is defined as FL, otherwise, the firstline will be part of
    %   mFileText.
    %
    %   NOTE: GETHELP does not work with built-in methods for Matlab.
    
    %   need commentTokens: [commentStart commentEnd commentOffset]
    %   CommentStart should be first % symbol of commend. CommentEnd should
    %   be last \n of comment. CommenOffset should be from \n to first
    %   comment.
    
    %  Known issues: 
    %  edit does not work correctly
    %  cannot find help for global methods that are in HDS.m
    %  
    
    % Copyright (c) 2012, J.B.Wagenaar
    % This source file is subject to version 3 of the GPL license, 
    % that is bundled with this package in the file LICENSE, and is 
    % available online at http://www.gnu.org/licenses/gpl.txt
    %
    % This source file can be linked to GPL-incompatible facilities, 
    % produced or made available by MathWorks, Inc.
    
    if nargin == 1
        type = 'class';
    elseif nargin == 2
        type = 'method';
        methodStr = varargin{1};
    elseif nargin == 3
        type = 'prop';
        propertyStr = varargin{2};
    else
        throwAsCaller(MException('GETHELP:INPUTS','GETHELP: Incorrect number of inputs.'));
    end
    
    mainText = '';
    firstLine = '';
    commentTokens = [0 0 0]; % commentTokens = [commentStart commentEnd commentOffset]
    
    % Method offset is first character on line where method is declared.
    methodOffset = 1;
    
    % Get the methodOffset and the mFileText for both methods and Class
    % type.
    switch type
        case 'class'  
            % Open class m-file
            whichFile = which(classStr);
            [path, file,~] = fileparts(whichFile);
            if strcmp(file,'built-in')
                throwAsCaller(MException('GETHELP:NOBUILTIN', 'The GETHELP method does not work with built-in methods for Matlab.'));
            end
            file = [file '.m'];
            filePath = fullfile(path,file);

            h = fopen(filePath);
            if h <=0
                throwAsCaller(MException('GETHELP:NOSUCHFILE', sprintf('The %s file was not found.',upper(file))));
            end    
            mFileText = fscanf(h,'%c');
            fclose(h);
            
            classDefLine = regexp(mFileText,'(?<=\n*)[ \t]*classdef','once'); 
            lastCHbeforeComment = regexp(mFileText,'\n(?=[\t ]*\%)','once') - 1;
            
            eoClassDefLine = regexp(mFileText(classDefLine:end),'\n','once');
            eoClassDefLine = eoClassDefLine + classDefLine -1;
            
            firstCHafterClassDef = regexp(mFileText(eoClassDefLine+1:end),'\S','once');
            firstCHafterClassDef = firstCHafterClassDef + eoClassDefLine;
            if strcmp(mFileText(firstCHafterClassDef),'%')
                commentStartLine = regexp(mFileText(eoClassDefLine:firstCHafterClassDef),'\n(?=[ \t]*\%)');
                commentStartLine = commentStartLine+ eoClassDefLine-1;
                firstNonCommentLine = regexp(mFileText(commentStartLine+1:end),'\n(?![ \t]*\%)','once');
                firstNonCommentLine = firstNonCommentLine + commentStartLine; 
            else
                commentStartLine = eoClassDefLine+1;
                firstNonCommentLine = regexp(mFileText(commentStartLine+1:end),'\n(?![ \t]*\%)','once');
                firstNonCommentLine = firstNonCommentLine + commentStartLine; 
            end
            
            
           
            if lastCHbeforeComment > firstNonCommentLine
                display('No help mFileText found.');
            elseif classDefLine > lastCHbeforeComment
                display('Incorrect layout class definition file (Comments before definition).');
            end
            
            text2 = mFileText(commentStartLine:firstNonCommentLine);
            CommentLines = regexp(text2,'\%(.*)','tokenExtents','dotexceptnewline');
            CommentLines = reshape([CommentLines{:}],2,length(CommentLines));
            
            if ~isempty(CommentLines)
                commentTokens(3) = CommentLines(1,1); %First offset to % is commentOffset.
                
                expr = ['(?<=[ \t]*\%[ \t]*)' upper(classStr)];
                FL = regexp(text2,expr,'once');
                
                if FL < CommentLines(2,1)
                    firstLine = text2(CommentLines(1,1):CommentLines(2,1));
                    expr = ['(?<=(^\s*' upper(classStr) '\s+))\w'];
                    flWithoutClass = regexp(firstLine,expr);
                    firstLine = strtrim(firstLine(flWithoutClass:end));
                    if size(CommentLines,2)>1
                        mainText = strtrim(text2(CommentLines(1,2):CommentLines(2,2)));
                        for i =3:size(CommentLines,2)
                            Tline = strtrim(text2(CommentLines(1,i):CommentLines(2,i)));
                            mainText = sprintf('%s\n%s',mainText,Tline );
                        end
                    else
                        mainText = '';
                    end
                       
                else
                    firstLine = '';
                    mainText = strtrim(text2(CommentLines(1,1):CommentLines(2,1)));
                    for i =2:size(CommentLines,2)
                        Tline = strtrim(text2(CommentLines(1,i):CommentLines(2,i)));
                        mainText = sprintf('%s\n%s',mainText,Tline );
                    end
                end
                    
                commentTokens = [lastCHbeforeComment CommentLines(2,end)+lastCHbeforeComment commentTokens(3)];
            else
                commentTokens = [eoClassDefLine-1 eoClassDefLine 4];
            end    
        case 'method' 
            % First find class folder
            if ~isempty(classStr)
                
                fileStr = [classStr '.m'];
                classPath = which(fileStr);
                if isempty(classPath)
                    msgbox('Unable to find method help.','File Warning','warn');
                    return
                end
                methodFileStr = fullfile(fileparts(classPath),[methodStr '.m']);
                
            else
                methodFileStr = which([methodStr '.m']);
            end
            % Now try to find method file in class folder
            
            isMethodFile = exist(methodFileStr, 'file');

            if ~isMethodFile
                % Check if method is defined in Class def.
                h = fopen(classPath,'r');
                mFileText = fscanf(h,'%c');
                fclose(h);

                allFunctionLines = regexp(mFileText,'\n(?=[ \t]*function)');
                sString          = ['(?!<\n.*)' methodStr '('];
                for i =1: length(allFunctionLines)
                    eol = regexp(mFileText(allFunctionLines(i)+1:end),'\n','once') + allFunctionLines(i);
                    methodCol = regexp(mFileText(allFunctionLines(i):eol), sString,'dotexceptnewline','ignorecase','once');
                    if methodCol
                        methodOffset = allFunctionLines(i) + 1;                        
                        break
                    end
                end
                if methodOffset <=1
                    fprintf(2,'GETHELP: Unable to find method.\n');
                    filePath = '';
                    return
                else
                    filePath = classPath;
                end
                
            else
                h = fopen(methodFileStr,'r');
                mFileText = fscanf(h,'%c');
                fclose(h);
                methodOffset = 1;
                filePath = methodFileStr;
            end
            
            mFileText2 = mFileText(methodOffset:end);
            
            lastCHbeforeComment = regexp(mFileText2,'\n(?=[\t ]*\%)','once') - 1;
            
            eoClassDefLine = regexp(mFileText2(1:end),'\n','once');
            
            firstCHafterClassDef = regexp(mFileText2(eoClassDefLine+1:end),'\S','once');
            firstCHafterClassDef = firstCHafterClassDef + eoClassDefLine;
            if strcmp(mFileText2(firstCHafterClassDef),'%')
                commentStartLine = regexp(mFileText2(eoClassDefLine:firstCHafterClassDef),'\n(?=[ \t]*\%)');
                commentStartLine = commentStartLine+ eoClassDefLine-1;
                firstNonCommentLine = regexp(mFileText2(commentStartLine+1:end),'\n(?![ \t]*\%)','once');
                firstNonCommentLine = firstNonCommentLine + commentStartLine; 
            else
                commentStartLine = eoClassDefLine+1;
                firstNonCommentLine = lastCHbeforeComment+1;
            end
            
            if lastCHbeforeComment > firstNonCommentLine
                display('No help mFileText found.');
            end
            
            text2 = mFileText2(commentStartLine:firstNonCommentLine);
            CommentLines = regexp(text2,'\%(.*)','tokenExtents','dotexceptnewline');
            CommentLines = reshape([CommentLines{:}],2,length(CommentLines));
            
            
            if ~isempty(CommentLines)
                commentTokens(3) = CommentLines(1,1)-3; %First offset to % is commentOffset.
                
                expr = ['(?<=[ \t]*\%[ \t]*)' upper(methodStr)];
                FL = regexp(text2,expr,'once');
                
                if FL < CommentLines(2,1)
                    firstLine = text2(CommentLines(1,1):CommentLines(2,1));
                    expr = ['(?<=(^\s*' upper(methodStr) '\s+))\w'];
                    flWithoutClass = regexp(firstLine,expr);
                    firstLine = strtrim(firstLine(flWithoutClass:end));
                    
                    mainText = strtrim(text2(CommentLines(1,2):CommentLines(2,2)));
                    for i =3:size(CommentLines,2)
                        Tline = strtrim(text2(CommentLines(1,i):CommentLines(2,i)));
                        mainText = sprintf('%s\n%s',mainText,Tline );
                    end
                else
                    firstLine = '';
                    mainText = strtrim(text2(CommentLines(1,1):CommentLines(2,1)));
                    for i =2:size(CommentLines,2)
                        Tline = strtrim(text2(CommentLines(1,i):CommentLines(2,i)));
                        mainText = sprintf('%s\n%s',mainText,Tline );
                    end
                end
                    
                commentTokens = [(lastCHbeforeComment + methodOffset-1) (CommentLines(2,end)+lastCHbeforeComment +methodOffset-1) commentTokens(3)];
            else
                commentTokens = [eoClassDefLine-1+ methodOffset-1 eoClassDefLine+ methodOffset-1 4];
            end    
        case 'prop'   
            % Open class m-file
            whichFile = which(classStr);
            [path, file,~] = fileparts(whichFile);
            if strcmp(file,'built-in')
                throwAsCaller(MException('GETHELP:NOBUILTIN', 'The GETHELP method does not work with built-in methods for Matlab.'));
            end
            file = [file '.m'];
            filePath = fullfile(path,file);

            h = fopen(filePath);
            if h <=0
                throwAsCaller(MException('GETHELP:NOSUCHFILE', sprintf('The %s file was not found.',upper(file))));
            end    
            mFileText = fscanf(h,'%c');
            fclose(h);
            
            % Find Properties
            allPropertiesStart = regexp(mFileText,'\n(?=[ \t]*properties)');
            for i = 1:length(allPropertiesStart)
                % Find end for current properties definitions
                curEnd = regexp(mFileText(allPropertiesStart(i)+1:end),'(?<=\n[ \t]*)end','once');
                curEnd = curEnd + allPropertiesStart(i);
                propertyLine = regexp(mFileText(allPropertiesStart(i)+1:curEnd),sprintf('\\n(?=[ \\t]*%s)',propertyStr),'once');
                propertyLine = propertyLine + allPropertiesStart(i)+1;
                if ~isempty(propertyLine)
                    [~,propHelpSt,propHelpE] = regexp(mFileText(propertyLine:curEnd),'\%.*','tokenExtents','dotexceptnewline','once');
                    propHelpSt = propHelpSt + propertyLine - 1;
                    propHelpE = propertyLine + propHelpE - 1;
                    
                    endOfLine = regexp(mFileText(propertyLine:curEnd),'\n','once');
                    endOfLine = endOfLine + propertyLine-1;
                    
                    if propHelpSt > endOfLine
                        mainText = '';
                        lastChLine = regexp(mFileText(propertyLine:endOfLine),'[A-Za-z0-9[]()''](?=[ \t]*\n)','once');
                        lastChLine = lastChLine + propertyLine -1;
                        commentTokens =  [lastChLine+1 endOfLine 4]; %lastCHLine can be same as endOfLine
                    else
                        lastChLine = regexp(mFileText(propertyLine:endOfLine),'[A-Za-z0-9[]()''](?=[ \t]*\%)','once');
                        lastChLine = lastChLine + propertyLine -1;
                        mainText = strtrim(mFileText(propHelpSt+1 : propHelpE));
                        commentTokens = [lastChLine+1 propHelpE+1 propHelpSt-lastChLine-1];
                    end
                    firstLine = '';
                    CommentLines = [];
                    return
                    
                end
            end
            
            fprintf(2,'GETHELP: Unable to find property.\n');
            filePath = '';
            mainText = '';     
            CommentLines = [];
    end
  
end