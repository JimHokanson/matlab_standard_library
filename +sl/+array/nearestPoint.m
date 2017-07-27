function result = nearestPoint(x,y,mode,varargin)
%x Find the nearest value in another vector
%
%   result = sl.array.nearestPoint(x,y,mode)
%
%   Inputs
%   ------
%   x : sorted array 
%       Reference array
%   y : sorted array
%       The array to which x is being compared   
%   mode : string
%       - 'p'  : For each x, find the index of y which has the closest
%                value less than x
%       - 'p1' : Same as 'p', but only one x gets to claim a given y index
%
%       TODO: Implement 'n' and 'n1'
%
%
%   Outputs
%   -------
%   result : Type depends on mode
%       'p' - array, indices correspond to x, values are indices of y
%             that just preceeded the given x index
%       'p1' - sl.array.nearestPoint.previous_single_result
%       'n'  - NYI
%       'n1' - NYI
%
%   Optional Inputs
%   ---------------
%   verify : (default false)
%       Meant largely for internal testing, this uses a slower approach to
%       verify that the algorithm is working corretly on the input data.
%       
%
%   Examples
%   --------------------------------
%   x = [2,8,9,11,13,15];
%   y = [4 5 6 10];
%   result = sl.array.nearestPoint(x,y,'p','verify',true)
%   => [0 3 3 4 4 4]
%   
%   x = [2,8,9,11,13,15];
%   y = [4 5 6 13];
%   result = sl.array.nearestPoint(x,y,'p','verify',true)
%   =>  [0 3 3 3 3 4]
%
%   x = [2,8,9,11,13,15];
%   y = [4 5 6 13];
%   result = sl.array.nearestPoint(x,y,'p1')
%   result.raw =>  [0 0 0 0 3 4]

in.verify = false;
in = sl.in.processVarargin(in,varargin);




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
    %TODO: Switch on expected result type ...
    result = [];
    return
end

switch mode
    case 'p'
        result = h__previous(x,y);
        if in.verify
            h__verifyP(result,x,y)
        end
    case 'p1'
        result = h__previous_with_single_y(x,y);
end


%Next
%-----------------------------------------

end

function temp = h__previous(x,y)
%
%   Mode == 'p'

nx = length(x);
ny = length(y);

temp = zeros(1,nx);

%Previous
%---------------------------------------
YI = 1;
XI = 1;
cur_x = x(XI);
done = false;
while ~done
    %We advance until false, then grab the previous y value
    %
    %   <= means that x must be greater than y
    %   If we had <, then x must be greater than or equal to y
    %
    %   TODO: We could expose this as an option ...
    if y(YI) <= cur_x
        if YI < ny
            YI = YI+1;
        else
            done = true;
        end
    else
        %Grabbing the index of the previous y value
        %Note if all y are greater than x(1), then YI-1 points
        %to 0, which is the defined behavior
        temp(XI) = YI-1;
        if XI < nx
            XI = XI + 1;
            cur_x = x(XI);
        else
            done = true;
        end
    end
end

last_y = y(end);
for i = XI:nx
    %We might end with a value being equal to the last value
    %in which case that value (and any following) hasn't been
    %assigned to the previous value
    if last_y == x(i) 
        temp(i) = ny-1;
    elseif last_y < x(i)
        %once we show that we are greater than the last value
        %we can take everything
        temp(i:end) = ny;
        break;
    end
end

end

function output = h__previous_with_single_y(x,y)

temp = h__previous(x,y);

for i = 2:length(temp)
    if (temp(i) == temp(i-1))
        temp(i-1) = 0;
    end
end
    
nx = length(x);
ny = length(y);

output = sl.array.nearestPoint.previous_single_result(temp,nx,ny);


end

function test_previous


%TODO: Write the slow version of this code that verifies





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

function h__verifyP(result,x,y)

    for i = 1:length(x)
        I = find(y < x(i),1,'last');
        if isempty(I) && result(i) == 0
            %all good
        elseif result(i) == I
            %all good
        else
           error('Mismatch of sl.array.nearestPoint - mode "p" at index: %d, normal_method: %d, slow_method: %d',i,result(i),I); 
        end
    end

end