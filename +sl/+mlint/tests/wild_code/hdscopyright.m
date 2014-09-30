function hdscopyright(varargin)
    %HDSCOPYRIGHT  Displays information about the HDS Toolbox version.
    %   HDSCOPYRIGHT displays information about the HDS Toolbox version and
    %   displays a link to the site which supports the HDS Toolbox.
  
    % Copyright (c) 2012, J.B.Wagenaar
    % This source file is subject to version 3 of the GPL license, 
    % that is bundled with this package in the file LICENSE, and is 
    % available online at http://www.gnu.org/licenses/gpl.txt
    %
    % This source file can be linked to GPL-incompatible facilities, 
    % produced or made available by MathWorks, Inc.
    
    persistent previouslyRun
    
    try 
        error(nargchk(0, 1, nargin));
    catch ME
        throwAsCaller(MException('HDS:hdscopyright', ME.message)); 
    end
    
    if isempty(previouslyRun)
        previouslyRun = false;
        mlock;
    end
    
    % Determine if the message should be shown
    showMessage = false;
    if nargin
        if strcmp(varargin{1},'init') 
            if ~previouslyRun
                showMessage = true;
            end
        else
            throwAsCaller(MException('HDS:hdscopyright','Incorrect input argument.'));
        end
    else
        showMessage = true;
    end
      
    % Get Version from HDSToolbox_README.txt 
    try
      fid = fopen('README_HDS.txt');
      str = '';
      while ischar(str);
        str = fgets(fid);
        if strfind(lower(str), 'version')
          break
        end
      end
      fclose(fid);
    catch ME %#ok<NASGU>
      str = 'Version unknown.';
    end
      
    % -- -- -- -- -- Display message to user -- -- -- -- -- --
    
    if showMessage
        
        %Currently no links, but could change in future.
        if usejava('desktop')
            HDS.displaymessage('-- -- -- -- -- --',2,'\n','');
            fprintf('HIERARCHICAL DATA STORAGE TOOLBOX\n');
            fprintf('Copyright:  2009-2012 J.B. Wagenaar\n');
            fprintf('%s',str);
            HDS.displaymessage('-- -- -- -- -- --',2,'','\n');
        else
            HDS.displaymessage('-- -- -- -- -- --',2,'\n','');
            fprintf('HIERARCHICAL DATA STORAGE TOOLBOX\n');
            fprintf('Copyright:  2009-2012 J.B. Wagenaar\n');
            fprintf('%s',str);
            HDS.displaymessage('-- -- -- -- -- --',2,'','\n');
        end

        previouslyRun = true;
    end
    
end
