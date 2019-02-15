function flag = verLessThan(ver_name)
%
%   flag = sl.ml.verLessThan(ver_name)
%
%   Because this doesn't work as expected in Matlab:
%       verLessThan('matlab', '2017b')
%   
%   Examples
%   --------
%   flag1 = sl.ml.verLessThan('2016a')
%   flag2 = sl.ml.verLessThan('2016b')
%   flag3 = sl.ml.verLessThan('2017a')
%   flag4 = sl.ml.verLessThan('2017b')
%   flag5 = sl.ml.verLessThan('2018a')


%TODO: What about prerelease
if length(ver_name) ~= 5
    error('Unexpected version name length')
end

if ~(ver_name(end) == 'a' || ver_name(end) == 'b')
    if ver_name(end) == 'A'
        ver_name(end) = 'a';
    elseif ver_name(end) == 'B'
        ver_name(end) = 'b';
    else
    	error('Unexpected release ID')
    end
end

current_name = version('-release'); %e.g. 2017a

%Careful, if we have the same, then the 1st one will be first
%so we can't switch the order and check for I(1) == 1
%because we might have them be equal and the above would be true
[~,I] = sort({ver_name,current_name});

flag = I(1) == 2;

end