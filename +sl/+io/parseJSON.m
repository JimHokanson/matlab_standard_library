function data = parseJSON(string)
%
%
%   data = sl.io.parseJSON(string)
%
%   data = sl.io.parseJSON(fileread(file_path))
%
%   Inputs:
%   -------
%   string:
%       A file can
%

persistent SPECIAL_CHARS_SORTED

if isempty(SPECIAL_CHARS_SORTED)
   SPECIAL_CHARS_SORTED = sort('"",:[]{}'); 
end

[is_string,is_esc_char,is_quote] = helper__getQuotesAndEscapes(string);

[is_esc_char,string]   = helper__fixEscapes(is_esc_char,string);


str_I      = find(is_quote);
str_starts = str_I(1:2:end)+1;
str_ends   = str_I(2:2:end)-1;

n_str = length(str_starts);
all_strings = cell(1,n_str);


is_empty_string = str_starts == str_ends + 1;

has_escape = false(1,n_str);
[~,bin] = histc(find(is_esc_char),str_I);

%NOTE: If this fails, then our escape characters
%are not-between the strings ...
has_escape((bin+1)/2) = true;

all_strings(is_empty_string) = {''};

I_normal = find(~is_empty_string & ~has_escape);
I_escape = find(~is_empty_string & has_escape);

for iString = I_normal
    all_strings{iString} = string(str_starts(iString):str_ends(iString));
end

for iString = I_escape
    cur_indices = str_starts(iString):str_ends(iString);
    cur_indices(is_esc_char(cur_indices)) = [];
    all_strings{iString} = string(cur_indices);
end

%A good check ...
%any(is_esc_char & ~is_string)

%[]
%{}
%:
%""
%,

cur_string_index  = 1;
%NOTE: Second input is sorted ...
special_chars_I  = find(sl.str.quick.ismemberCharSortedSecondInput(string,SPECIAL_CHARS_SORTED) & ~is_string);

special_chars = string(special_chars_I);

cur_special_index = 1;

switch(special_chars(1))
    case '{'
        data = parse_object(string,special_chars,special_chars_I,cur_special_index,all_strings,cur_string_index);
    case '['
        data = parse_array(string,special_chars,special_chars_I,cur_special_index,all_strings,cur_string_index);
    otherwise
        error('Outer level structure must be an object or an array')
        %error_pos('Outer level structure must be an object or an array',string,pos);
end

end

function [is_esc_char,string] = helper__fixEscapes(is_esc_char,string)

persistent CHARS_TO_FIX

if isempty(CHARS_TO_FIX)
   CHARS_TO_FIX = sort('bfnrt');
   %TODO: Should move escape chars up here as well ...
end

is_esc_char_I = find(is_esc_char)+1;
if ~isempty(is_esc_char_I)
%TODO: This most likely could be improved using ismember
esc_chars   = string(is_esc_char_I);
%\" - do nothing
%\\ - do nothing
%\/ - do nothing

[is_present,loc] = sl.str.quick.ismemberCharSortedSecondInput(esc_chars,CHARS_TO_FIX);

if any(is_present)
    fixed_chars = sprintf('\b\f\n\r\t');
    string(is_esc_char_I(is_present)) = fixed_chars(loc(is_present));
end

I_unicode = find(esc_chars == 'u');
n_unicode = length(I_unicode);
if n_unicode ~= 0
    all_unicode = char(zeros(6,n_unicode));
    all_unicode(1,:) = '\';
    all_unicode(2,:) = 'u';
    unicode_starts = is_esc_char_I(I_unicode);
    for iUni = 1:n_unicode
        cur_start = unicode_starts(iUni);
        all_unicode(3:end,iUni) = string(cur_start+1:cur_start+4);
        
        %We mark the 4 characters for omission in the grab
        is_esc_char(cur_start+1:cur_start+4) = true;
        %\u00a0
    end
    
    %NOTE: We assign the final value to u, the rest are marked for deletion
    string(unicode_starts) = sl.str.javaStringToChar(org.apache.commons.lang.StringEscapeUtils.unescapeJava(all_unicode(:)'));
    
end
end

end

function [is_string,is_esc_char,is_quote] = helper__getQuotesAndEscapes(string)
% % % % str_len = length(string);
% % % % %NOTE: This could easily be mexed ...
% % % % %---------------------------------------------------
% % % % tic
% % % % is_quote        = false(1,str_len);
% % % % is_not_esc_char = true(1,str_len);
% % % % for iStr = 2:length(string)
% % % %     if is_not_esc_char(iStr-1)
% % % %         if string(iStr) == '"'
% % % %             is_quote(iStr) = true;
% % % %         elseif string(iStr) == '\'
% % % %             is_not_esc_char(iStr) = false;
% % % %         end
% % % %     end
% % % % end
% % % % is_esc_char = ~is_not_esc_char;
% % % % toc
% % % % 
% % % % 
% % % % tic
[is_string,is_esc_char,is_quote] = parse_json_helper(string);


end

function [object,cur_special_index,cur_string_index] = parse_object(string,special_chars,special_chars_I,cur_special_index,all_strings,cur_string_index)

%NOTE: An object is like a structure, with fields

cur_special_index = cur_special_index + 1;

object = [];

if special_chars(cur_special_index) ~= '}'
    while 1
        
        str = all_strings{cur_string_index};
        cur_special_index = cur_special_index + 2;
        cur_string_index  = cur_string_index  + 1;

        
%We'll let this cause an error below ...
%         if isempty(str)
%             error_pos('Name of value at position %d cannot be empty');
%         end
        
        if special_chars(cur_special_index) ~= ':'
            error('Expected ":" following object definition, observed: "%s"',special_chars(cur_special_index))
        end
        
        cur_special_index = cur_special_index + 1;
        
        
        if special_chars(cur_special_index) == '"'
            val = all_strings{cur_string_index};
            cur_special_index = cur_special_index + 2;
            cur_string_index  = cur_string_index  + 1;
        else
            [val,cur_special_index,cur_string_index] = parse_value(string,special_chars,special_chars_I,cur_special_index,all_strings,cur_string_index);
        end
        
        try
            object.(str) = val;
        catch
            object.(valid_field(str)) = val;
        end
        
        if special_chars(cur_special_index) == '}'
            break
        else
            %NOTE: We should check that we have a comma ...
            cur_special_index = cur_special_index + 1;
        end
    end
end

cur_special_index = cur_special_index + 1;

end

function [object,cur_special_index,cur_string_index] = parse_array(string,special_chars,special_chars_I,cur_special_index,all_strings,cur_string_index)

cur_special_index = cur_special_index + 1;

%Yikes, this approach makes true array growth awful, could be improved with
%preprocessing ...

object = {};
if special_chars(cur_special_index) ~= ']'
    while 1
        if special_chars(cur_special_index) == '"'
            val = all_strings{cur_string_index};
            cur_special_index = cur_special_index + 2;
            cur_string_index  = cur_string_index  + 1;
        else
            [val,cur_special_index,cur_string_index] = parse_value(string,special_chars,special_chars_I,cur_special_index,all_strings,cur_string_index);
        end
        
        object{end+1} = val; %#ok<AGROW>
        
        if special_chars(cur_special_index) == ']'
            break
        else
            %NOTE: We should check that we have a comma ...
            cur_special_index = cur_special_index + 1;
        end
    end
end

cur_special_index = cur_special_index + 1;

end

% % % function special_chars = helper__initializeSpecialChars()
% % % 
% % % all_chars = '"\/bfnrt';
% % % special_chars = cell(1,max(all_chars));
% % % special_chars{'\'} = '\';
% % % special_chars{'/'} = '/';
% % % special_chars{'"'} = '"';
% % % special_chars{'b'} = sprintf('\b');
% % % special_chars{'f'} = sprintf('\f');
% % % special_chars{'n'} = sprintf('\n');
% % % special_chars{'r'} = sprintf('\r');
% % % special_chars{'t'} = sprintf('\t');
% % % 
% % % end

function str = valid_field(str)
% From MATLAB doc: field names must begin with a letter, which may be
% followed by any combination of letters, digits, and underscores.
% Invalid characters will be converted to underscores, and the prefix
% "alpha_" will be added if first character is not a letter.

if ~isletter(str(1))
    str = ['alpha_' str];
end

%TODO: This can be optimized ...
str(~isletter(str) & ~('0' <= str & str <= '9')) = '_';

end

function [val,cur_special_index,cur_string_index] = parse_value(string,special_chars,special_chars_I,cur_special_index,all_strings,cur_string_index)
%
%
%   Called by:
%   parse_array
%   parse_object



%[ - start of an array
%" - start of a string
%{ - start of an object
%
%--- following indicate a number or special value, true, false, null
%]
%}
%,


switch special_chars(cur_special_index)
%We took this out into the caller ...
%     case '"'
%         val = all_strings{cur_string_index};
%         cur_special_index = cur_special_index + 2;
%         cur_string_index  = cur_string_index + 1;
    case '['
        [val,cur_special_index,cur_string_index] = parse_array(string,special_chars,special_chars_I,cur_special_index,all_strings,cur_string_index);
    case '{'
        [val,cur_special_index,cur_string_index] = parse_object(string,special_chars,special_chars_I,cur_special_index,all_strings,cur_string_index);
    otherwise
        %Pointer to ',' ']' or '}'
        %??? - use deblank instead, don't care about trailing stuffs ...
        prev_str = strtrim(string((special_chars_I(cur_special_index-1)+1):(special_chars_I(cur_special_index)-1)));
        switch(prev_str(1))
            case 't'
                val = true;
            case 'f'
                val = false;
            case 'n'
                val = [];
            otherwise
                %TODO: Add error check ???
                val = sscanf(prev_str,'%f',1);
                %Treat as number
        end
end

end