function flag = contains(s1,str_to_match,varargin)
%
%   sl.str.contains(s1,str_to_match,varargin)
%

%TODO: Should check for anywhere, otherwise throw an error

%Could add case sensitivity as well ...

in.location = 'anywhere'; %
%Options:
%   - start
%   - end,
%   - anywhere
in = sl.in.processVarargin(in,varargin);

switch in.location
    case 'start'
        flag = strncmp(s1,str_to_match,length(str_to_match));
    case 'end'
        length_str = length(str_to_match);
        if length(s1) < length_str
            flag = false;
        else
            flag = strcmp(s1((end-length_str+1):end),str_to_match);
        end
    otherwise
        flag = any(strfind(s1,str_to_match));
end

end

%{

%Testing end match
sl.str.contains('testing','ing','location','end')

%String too long
sl.str.contains('testing','asdfasdfing','location','end')

%Testing start
sl.str.contains('testing','test','location','start')

%Middle match
sl.str.contains('testing','est','location','anywhere')


%}