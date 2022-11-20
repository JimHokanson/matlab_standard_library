function s = getSubplotAxesHandles(figure_handle)
%
%   s = sl.figure.getSubplotAxesHandles(figure_handle)
%
%   Output:
%   -------
%   s : struct - ideally this would be a class
%                   sl.figure.results.subplot_handles_info
%   .grid_handles :
%       A matrix of handles. How are empties handled?
%              empty => GraphicsPlaceholder with no properties.
%       Shape represents the subplot shape.
%   .is_valid : logical mask
%           Not yet implemented, should identify non-GraphicsPlaceholders

%{
%Testing code
subplot(2,2,1)
plot(1:10)
xlabel('testing')
subplot(2,2,2)
plot(1:20)
subplot(2,2,3)
plot(1:30)
subplot(2,2,4)
plot(1:40)
xlabel('testing')
s = sl.hg.figure.getSubplotAxesHandles(gcf)


%In prerelease for 2015a this doesn't work, returns null for one of the
handles ...
%WTF ...
subplot(2,1,1)
plot(1:10)
xlabel('testing')
subplot(2,1,2)
plot(2:20)
xlabel('testing')
s = sl.hg.figure.getSubplotAxesHandles(gcf)


%}


%TODO: It looks like this doesn't return things in grid order ...
%wtf matlab ;asdfalsdfklaslkdfla;sdlkfals;dflk;

s = struct;

%This should work in 2014b, not sure if it works earlier ...
%Works in 2014a
%There is a bug in 2015a

%This also fails after any manipulations ...
%I found this to be wrong in some cases
%s.grid_handles = flipud(getappdata(figure_handle, 'SubplotGrid'));

% - close should be determined by the magnitude of spacing between
%   axes
% - TODO: We can also try assuming a full grid and factor
%       e.g. 8 should be either 2 x 4 or 4 x 2
%       - this however assumes no extra axes ...

%if isempty(s.grid_handles)

%TODO: This will fail if we have extra axes ...
%Can we make it more robust????

handles=findobj(figure_handle,'Type','axes','Visible','on');

positions = vertcat(handles.Position);

%left bottom height width

%The idea here is that if we fail with a tight tolerance, we 

is_good = false;
for tolerance = [0.0001 0.05 0.1 0.2]
    try
        
        unique_col_positions = uniquetol(positions(:,1),tolerance); %lefts
        unique_row_positions = uniquetol(positions(:,2),tolerance); %bottoms
        
        n_rows = length(unique_row_positions);
        n_cols = length(unique_col_positions);
        
        [~,r_I] = ismembertol(positions(:,2),unique_row_positions,tolerance);
        [~,c_I] = ismembertol(positions(:,1),unique_col_positions,tolerance);
        
        temp = cell(n_rows,n_cols);
        
        for i = 1:length(handles)
            cur_h = handles(i);
            temp{r_I(i),c_I(i)} = cur_h;
        end
        
        temp1 = [temp{:}];
        %This is where the error comes in ...
        temp2 = reshape(temp1,n_rows,n_cols);
        
        s.grid_handles = flipud(temp2);
        s.tolerance = tolerance;
        s.unique_col_positions = unique_col_positions;
        s.unique_row_positions = unique_row_positions;
		is_good = true;
        break
    catch ME
    end
end

if ~is_good
	error('Unable to find appropriate organization for handles')
end

%end
