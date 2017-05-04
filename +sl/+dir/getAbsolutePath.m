function absolute_path = getAbsolutePath(file_path,starting_path)
%x  Converts relative paths to absolute paths if necessary ...
%
%   absolute_path = sl.dir.getAbsolutePath(file_path,starting_path)
%
%   Supported special characters
%   -----------------------------
%   './' and '.\' - add on the file_path to the starting path
%   '../' and '..\' - move up a directory and add on file_path to the
%   starting path
%
%   Rules
%   ---------------------
%   1) The '..' directive can follow itself or the '.' directive. 
%   2) All directives must precede non-directives, in other words
%      this is not supported since the '..' directive is preceeded
%      by the 'test' directory
%
%           ./test/../my_file.txt    %NOT SUPPORTED
%   3) The input file_path may be absolute, in which case the starting_path
%      is not used.
%
%   Inputs
%   ------
%   file_path : string
%   starting_path : string
%
%   Examples
%   --------
%   file_path = './../a/b.txt';
%   starting_path = '/usr/home/';
%   absolute_path = sl.dir.getAbsolutePath(file_path,starting_path)
%   absolute_path => /usr/a/b.txt
%
%   Improvements
%   ------------
%   1) Implement support for ~/

if length(file_path) < 2
    %If we ever see this happen, we can decide what this means ...
    error('Unsupported case, input file path is too small');
end

%Handling of initial characters
%--------------------------------------------------------------------------
%For this code, we want to know if we can exit early, or if we need to
%parse out parts of the relative path
cur_start_char_I = 3;
switch file_path(1:2)
    case './'
        n_up = 0;
    case '.\'
        n_up = 0;
    case '..'
        cur_start_char_I = 4;
        n_up = 1;
        if length(file_path) == 2 || ~(file_path(3) == '/' || '\')
           error('Assumption violated, expecting "/" or "\" following .. characters'); 
        end
    otherwise
        absolute_path = file_path;    
        return;
end

%Consume '..'
%--------------------------------------------------------------------------
done = false;
file_path_length = length(file_path);
while ~done
   if cur_start_char_I + 1 <= file_path_length ...
       && file_path(cur_start_char_I) == '.' ...
       && file_path(cur_start_char_I+1) == '.'
       n_up = n_up + 1;
       if file_path_length >= cur_start_char_I + 2
           if ~(file_path(3) == '/' || '\')
               error('Assumption violated, expecting "/" or "\" following .. characters'); 
           else
               cur_start_char_I = cur_start_char_I + 3;
           end
       else
           done = true;
       end
   else
      done = true; 
   end
end

%Finding the folder delimiters
%--------------------------------------------------------------------------
%Not sure if there is a better way of doing this, specifically if 
%we would ever have '/' and '\' interspersed
sep_type = '/';
I = strfind(starting_path,sep_type);
if isempty(I)
    sep_type = '\';
    I = strfind(starting_path,sep_type);
    if isempty(I)
        error('Unable to find folder delimiters to move up directories')
    end
end

%Construction of the output path
%--------------------------------------------------------------------------
%C:\test\cheese\ => with ..\..\path.txt => moving up 2 points to C:\ not C:\test
%Discard the extra delimier at the end by adjusting n_up
end_has_fs = false;
if length(starting_path) == I(end)
    end_has_fs = true;
    n_up = n_up + 1;
end

if length(I) < n_up
    error('Number of identified directory delimiters on the starting path is insufficient')
end

%n_up = 0
if n_up == 0
    %TODO: If we are adding nothing, do we want to add the file separator?
    %sl.dir.getAbsolutePath('./',cd)  - expected behavior?
    if end_has_fs
        char_add = '';
    else
        char_add = filesep;
    end
    absolute_path = [starting_path char_add file_path(cur_start_char_I:end)];
else
    %/this/is/a/test
    last_char_keep_I = I(length(I) - n_up + 1);
    absolute_path = [starting_path(1:last_char_keep_I) file_path(cur_start_char_I:end)];

end


end

function h_testing()

start_path = 'G:\repos\matlab_git';
file_path = 'G:\repos\matlab_git';
output = sl.dir.getAbsolutePath(file_path,start_path)

start_path = 'G:\repos\matlab_git';
file_path = '..\..\cheese.txt';
output = sl.dir.getAbsolutePath(file_path,start_path)


end