function result = nearestPoint(x,y,mode)
%x Find the nearest value in another vector
%
%   result = sl.array.nearestPoint(x,y,m)
%
%   Inputs
%   ------
%   x : sorted array 
%       Reference array
%   y : sorted array
%       The array to which x is being compared   
%   mode : string
%       - 'p'  : For each x, find the cloeset previous y
%               x = 2 8 9
%               y = 4 5 6 10
%               result.by_x = [0 3 3] 
%               Interpretation:
%               - no values come before x(1)
%               - y(3) is the closest previous value in y to x(2) and x(3)
% 
%       - 'p1' : For each x, find the cloesest previous y, but ONLY
%                   assign if it is the closest for all x
%
%
%   Outputs
%   -------
%   result : Type depends on mode
%       


%Paths
%-----
%1) Closest:
%   - x to y
%   - x to y and y to x
%2) Previous:
%   - which y proceeds each x
%3) Next:
%   - x to y
%4) Prev x to y and Next y to x
%

%TODO: This needs to now return a different result based on the mode ...
if isempty(x) || isempty(y)
    result = [];
    return
end

switch mode
    case 'p'
        result = h__previous(x,y);
    case 'p1'
        result = h__previous_with_single_y(x,y);
end


%Next
%-----------------------------------------

end

function temp = h__previous(x,y)
nx = length(x);
ny = length(y);

temp = zeros(1,ny);

%Previous
%---------------------------------------
YI = 1;
XI = 1;
cur_x = x(XI);
done = false;
while ~done
    if y(YI) < cur_x
        if YI < ny
            YI = YI+1;
        else
            done = true;
        end
    else
        %Grab last value
        %What if not present
        %TODO: We can move this out of the loop
        temp(XI) = YI-1;
        if XI < nx
            XI = XI + 1;
            cur_x = x(XI);
        else
            done = true;
        end
    end
end

end

function output = h__previous_with_single_y(x,y)
nx = length(x);
ny = length(y);

temp = zeros(1,ny);

%Previous
%---------------------------------------
YI = 1;
XI = 1;
cur_x = x(XI);
done = false;
while ~done
    if y(YI) < cur_x
        if YI < ny
            YI = YI+1;
        else
            done = true;
        end
    else
        %Grab last value
        %What if not present

            %TODO: We can move this out of the loop
        if YI - 1 ~= 0
            temp(YI-1) = XI;
        end
        
        if XI < nx
            XI = XI + 1;
            cur_x = x(XI);
        else
            done = true;
        end
    end
end

output = sl.array.nearestPoint.previous_single_result(temp,nx,ny);


end

function test_previous

%1st test
x = 1:5:100;
y = 0:11:100;

out = sl.array.nearestPoint(x,y,'p');

%Start y after x
x = 1:5:100;
y = 5:11:90;

out = sl.array.nearestPoint(x,y,'p');

%Terminate y on x
x = 1:5:100;
y = 5:11:100;
out = sl.array.nearestPoint(x,y,'p');

%
x = 1:5:100;
y = 0:11:100;

out = sl.array.nearestPoint(x,y,'p1');

x = 1:5:100;
y = 0:2:100;

out = sl.array.nearestPoint(x,y,'p1');

end