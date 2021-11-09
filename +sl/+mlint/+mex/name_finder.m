function name_finder()
%
%   sl.mlint.mex.name_finder

file_path = which('sl');

temp = mlintmex(file_path,'-a','-m3');

%{
calls
db
ty
tab
cyc
msg
lex
tree
edit
text -TEXT requires one argument with text, and a second one with a .m filename
%}

%length(57) - single letter
%58 - 2
%59 - 3
%60 - 4
%length > 

test = 'a';
%width = 1;
width = 5;
nums = [97 97 97 97 97];
%nums = [117   101   120   116    97];
%for i = 1:(26^5 + 26^4 + 26^3 + 26^2+26)
for i = 367895:(26^5 + 26^4 + 26^3 + 26^2+26)
    if mod(i,10000) == 0
        fprintf('%d\n',i)
    end
    test = char(nums(1:width));
    temp = mlintmex(file_path,['-' test],'-m3');
    if length(temp) > 61
        fprintf('%s\n',test);
    end
    for j = 1:5
        if nums(j) == 122
            nums(j) = 97;
            if width == j
                width = j + 1;
                if width== 6
                    return
                end
                break
            end
        else
            nums(j) = nums(j) + 1;
            break
        end
    end
end

end