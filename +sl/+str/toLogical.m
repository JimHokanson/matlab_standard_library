function flag = toLogical(input_string)
%
%   flag = sl.str.toLogical(input_string)
%
%   This function handles various ways of representing true and false as
%   strings.
%
%   Recognized Values
%   -----------------
%   0,1,y,n,t,f,yes,no,true,false
%   
%   Examples
%   --------
%   flag = sl.str.toLogical('true')
%
%   flag = sl.str.toLogical('yes')
%
%   flag = sl.str.toLogical('0')

first_char = input_string(1);
switch lower(first_char)
    case {'1','y','t'}
        flag = true;
    case {'0','n','f'}
        flag = false;
    otherwise
        error('Unrecognized option')
end

end