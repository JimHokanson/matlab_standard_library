function data = parseJSON(string)
%
%
%   data = parseJSON(string)
%
% This function parses a JSON string and returns a cell array with the
% parsed data. JSON objects are converted to structures and JSON arrays are
% converted to cell arrays.
%
%   Original Version by:
%   F. Glineur, 2009
%   LICENSE: see http://www.mathworks.com/matlabcentral/fileexchange/23393
%
%   JAH NOTE: I've since modified the code a bit ...

%JAH MOD

persistent special_chars

if isempty(special_chars)
    special_chars = helper__initializeSpecialChars();
end

pos = 1;
len = length(string);
% String delimiters and escape characters are identified beforehand to improve speed
esc       = regexp(string, '["\\]');
index_esc = 1;
len_esc   = length(esc);


is_esc_char   = string == '\';
is_quote_char = string == '"';
quote_char_I  = find(is_quote_char);
next_quote_I(is_quote_char) = [quote_char_I(2:end) length(string)+1];

%MEMORY ASSUMPTION: Tradeoff ...
%For a given string, if it is a space, point to the next non-space
%otherwise, point to itself
% % % mask = [~isspace(string) true];
% % % I    = fliplr(find(mask));
% % % temp = cumsum(mask(end:-1:1));
% % % next_non_space = I(temp(end:-1:1));


switch(next_char)
    case '{'
        data = parse_object;
    case '['
        data = parse_array;
    otherwise
        error_pos('Outer level structure must be an object or an array');
end


    function object = parse_object
        %NOTE: An object is like a structure, with fields
        parse_char('{');
        object = [];
        if next_char ~= '}'
            while 1
                str = parse_string;
                if isempty(str)
                    error_pos('Name of value at position %d cannot be empty');
                end
                parse_char(':');
                val = parse_value;
                object.(valid_field(str)) = val;
                if next_char == '}'
                    break;
                end
                parse_char(',');
            end
        end
        parse_char('}');
    end

    function object = parse_array
        parse_char('[');
        object = {};
        if next_char ~= ']'
            while 1
                val = parse_value;
                object{end+1} = val;
                if next_char == ']'
                    break;
                end
                parse_char(',');
            end
        end
        parse_char(']');
    end

    function parse_char(c)
        %Let's assume we're there already, this saves time if right
        if string(pos) == c
            pos = pos + 1;
            skip_whitespace;
        else
            skip_whitespace;
            if pos > len || string(pos) ~= c
                error_pos(sprintf('Expected %c at position %%d', c));
            else
                pos = pos + 1;
                skip_whitespace;
            end
        end
    end

    function c = next_char
        skip_whitespace;
        if pos > len
            c = [];
        else
            c = string(pos);
        end
    end

    function skip_whitespace
        %JAH MOD
        %pos = next_non_space(pos);
        while pos <= len && isspace(string(pos))
            pos = pos + 1;
        end
    end

    function str = parse_string
        %
        %
        %   A string consists of characters
        %   ---------------------------------------------
        %   \" \\  \/  \b  \f  \n  \r  \uxxxx
        %   What is \/ ->
        
        if string(pos) ~= '"'
            error_pos('String starting with " expected at position %d');
        end
        
        temp = next_quote_I(pos);
        
        if ~any(is_esc_char(pos+1:temp-1))
            str = string(pos+1:temp-1);
            if isempty(str)
                str = '';
            end
            pos = temp + 1;
            return
        end
        
        %NOTE: At this point, we should only proceed
        %if we have escape characters in the string
        
        pos = pos + 1;
        
        str  = '';
        done = false;
        while ~done
            %Advance to next escape character ...
            while index_esc <= len_esc && esc(index_esc) < pos
                index_esc = index_esc + 1;
            end
            if index_esc > len_esc
                str = [str string(pos:end)];
                pos = len + 1;
            else
                str = [str string(pos:esc(index_esc)-1)];
                pos = esc(index_esc);
                esc_char = string(pos);
                
                if esc_char == '"'
                    pos = pos + 1;
                    %Yikes, this is the normal escape mode ...
                    done = true;
                elseif esc_char == '\'
                    %Safety off ...
                    % if pos+1 > len
                    %     error_pos('End of file reached right after escape character');
                    % end
                    pos = pos + 1;
                    next_char = string(pos);
                    if next_char == 'u'
                        %Safety off ...
                        str(end+1) = helper__decodeJavaString(string(pos-1:pos+4));
                        %error_pos('End of file reached in escaped unicode character');
                        pos = pos + 5;
                    else
                        str(end+1) = special_chars{string(pos)};
                        pos = pos + 1;
                    end
                end
            end
        end
        if ~done
            error_pos('End of file while expecting end of string');
        end
    end

    function num = parse_number
        [num, one, err, delta] = sscanf(string(pos:min(len,pos+20)), '%f', 1); % TODO : compare with json(pos:end)
        if ~isempty(err)
            error_pos('Error reading number at position %d');
        end
        pos = pos + delta-1;
    end

    function val = parse_value
        switch(string(pos))
            case '"'
                val = parse_string;
                return;
            case '['
                val = parse_array;
                return;
            case '{'
                val = parse_object;
                return;
            case {'-','0','1','2','3','4','5','6','7','8','9'}
                val = parse_number;
                return;
            case 't'
                if pos+3 <= len && strcmpi(string(pos:pos+3), 'true')
                    val = true;
                    pos = pos + 4;
                    return;
                end
            case 'f'
                if pos+4 <= len && strcmpi(string(pos:pos+4), 'false')
                    val = false;
                    pos = pos + 5;
                    return;
                end
            case 'n'
                if pos+3 <= len && strcmpi(string(pos:pos+3), 'null')
                    val = [];
                    pos = pos + 4;
                    return;
                end
        end
        error_pos('Value expected at position %d');
    end

    function error_pos(msg)
        poss = max(min([pos-15 pos-1 pos pos+20],len),1);
        if poss(3) == poss(2)
            poss(3:4) = poss(2)+[0 -1];         % display nothing after
        end
        msg = [sprintf(msg, pos) ' : ... ' string(poss(1):poss(2)) '<error>' string(poss(3):poss(4)) ' ... '];
        ME = MException('JSONparser:invalidFormat', msg);
        throw(ME);
    end

    function str = valid_field(str)
        % From MATLAB doc: field names must begin with a letter, which may be
        % followed by any combination of letters, digits, and underscores.
        % Invalid characters will be converted to underscores, and the prefix
        % "alpha_" will be added if first character is not a letter.
        if ~isletter(str(1))
            str = ['alpha_' str];
        end
        str(~isletter(str) & ~('0' <= str & str <= '9')) = '_';
    end

end

function char_out = helper__decodeJavaString(char_in)
char_out = sl.str.javaStringToChar(org.apache.commons.lang.StringEscapeUtils.unescapeJava(char_in));
end

function special_chars = helper__initializeSpecialChars()

all_chars = '"\/bfnrt';
special_chars = cell(1,max(all_chars));
special_chars{'\'} = '\';
special_chars{'/'} = '/';
special_chars{'"'} = '"';
special_chars{'b'} = sprintf('\b');
special_chars{'f'} = sprintf('\f');
special_chars{'n'} = sprintf('\n');
special_chars{'r'} = sprintf('\r');
special_chars{'t'} = sprintf('\t');

end