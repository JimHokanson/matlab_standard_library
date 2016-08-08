classdef lex < sl.mlint
    %
    %   Class:
    %   sl.mlint.mex.lex
    %
    %   This class exposes the mlintmex function with the '-lex' input.
    %
    %   Usefulness
    %   ----------
    %   This class is good for identifying different lexical operators
    %   such as: %, /, +, ', :, <EOL> (end of line), etc
    %
    
    %{
    Observed types
    --------------
    '<Cmd Arg>' => e.g. 'filename' in load filename
    '<Name>' %Name of function or variable
    '('
    '<LEX_ERR>'
    '<EOL>'
    'NUL'
    FUNCTION : For a function declaration
    - '%' - line comment, these also seem to appear for continuation comments 
      - i.e. => something ... this is a comment
      - They also appear for lines that make up group comments, except for the start and end lines, which are indicated as group comment lines
    - '&' 
    - '&&'
    - '('
    - ')'
    - '*'
    - '+'
    - ','
    - '-'
    - '.'
    - ':'
    - ';'
    - '&lt;'
    - '&lt;='
    - '&lt;DOUBLE&gt;'
    - '&lt;EOL&gt;' - end of line character. NOTE, for lines with '...' the EOL character is not present. This points to the \n character.
    - '&lt;INT&gt;'
    - '&lt;NAME&gt;'
    - '&lt;STRING&gt;'
    - '='
    - '=='
    - '&gt;'
    - '@'
    - 'BREAK'
    - 'CASE'
    - 'CATCH'
    - 'CLASSDEF'
    - 'CONTINUE'
    - 'ELSE'
    - 'ELSEIF'
    - 'END'
    - 'FOR'
    - 'FUNCTION'
    - 'GLOBAL'
    - 'IF'
    - 'METHODS'
    - 'NUL' - I think this is reserved for the end of the file
    - 'OTHERWISE'
    - 'PERSISTENT'
    - 'PROPERTIES'
    - 'RETURN'
    - 'SWITCH'
    - 'TRY'
    - 'WHILE'
    - '['
    - ']'
    - '{'
    - '||'
    - '}'
    - '~' - this does not distinguish between tilde and not
    - '~='

    
    
    %}
    
    
    %Properties Per Entry
    %----------------------------------------------------------------------
    properties
        d0 = '----  From raw mlintmex call ----'
        %Following are the properties that are parsed the mlint call.
        %------------------------------------------------------------------
        line_numbers %[1 x n], For each parsed entry this indicates the 
        %line number that the entry is on
        
        column_I %[1 x n], For each parsed entry this indicates the 
        %column at which the parsed entry starts
        
        lengths %[1 x n], " " length of content, for some
        %types this is the type itself (if,end,+,-, etc), for others 
        
        types %{1 x n}, string name indicating type
        %For example types include:
        %   '{' 
        %   ']' 
        %   '==' 
        %   ';' etc.
        %
        %See above for more details
        
        strings %{1 x n}, the actual string that is in the file. In many
        %cases the type and string values are identical.
        %
        %Notable differences include the following types:
        %<NAME> : indicates a variable, function etc. e.g. processVarargin
        %  %    : indicates a comment, string contains the comment text
        %<INT>
        %<Cmd Arg> : e.g. all in: hold all
        %<DOUBLE>
        %<STRING>
        
        absolute_I %[1 x n], Instead of a line number and column
        %index, this provides an absolute index into the string of the file
        %as to where the content starts.
    end
    
    methods
        function value = get.absolute_I(obj)
           value = obj.absolute_I;
           if isempty(value)
              value = obj.getAbsIndicesFromLineAndColumn(obj.line_numbers,obj.column_I);
              obj.absolute_I = value;
           end
        end
    end
    
    properties
       %??? - Make Hidden and expose via a method?????
       unique_types_map  %@type=containers.Map
       %Keys are the unique types and values are the array indices 
       %that have that specified typed. For example, to get all ':'
       %indices you could use the following code.
       %
       %   colon_indices = obj.unique_types_map(':')
    end
    
    methods
        function obj = lex(file_path)
            %
            %
            %   obj = sl.mlint.mex.lex(file_path)
            %
            %   Inputs:
            %   -------
            %   file_path : string
            %       Path of file to parse
            
            obj.file_path = file_path;
            
            %NOTE: The -m3 specifies not to return mlint messages
            obj.raw_mex_string = mlintmex(file_path,'-lex','-m3');

            c = textscan(obj.raw_mex_string,'%f / %f ( %f ): %s %[^\n]','MultipleDelimsAsOne',true);
            %1 %f
            %2 %f
            %3(%f):
            %4 %s Just grabb all text until a space
            %5 Everything else remaining until a newline
            
            %Our delimeter is the default (a space). The middle part
            %which specifies the type ends in a colon.
            %
            %Filtering on a colon messes up the situation in which the 
            %colon character is the type, i.e. 
            %   '':'':  
            %
            %   We use a regular expression below to tease this apart.
            
            obj.line_numbers = c{1}';
            obj.column_I     = c{2}';
            obj.lengths      = c{3}';
            
            %I had a hard time extracting the lexical content using
            %just textscan. The general format is space, followed by text 
            %followed by a colon, followed by spaces. We have currently
            %grabbed all non space characters.
            %
            %Examples of c{4} values:
            %
            %   '(':
            %   IF:
            %   <NAME>:
            % 
            %   The tricky one is the colon identifier:
            %   ':':
            %
            %   In c{4} we have the text, followed by a colon.
            
            %Tricky cases:
            %-------------
            %1) Transpose
            %   520/56(1): ':  '
            %2) 363/26(3): <Cmd Arg>:  all
            
            
            is_colon = cellfun(@(x)x(end) == ':',c{4});
            if ~all(is_colon)
               %TODO: Move this into a function 
               %-----------------------------------------------------------
               %This
               temp_types = c{4};
               temp_strings = c{5};
               I_broken = find(~is_colon);
               
               n_broken = length(I_broken);
               fixed_types   = cell(1,n_broken);
               fixed_strings = cell(1,n_broken);
               for iLine = 1:n_broken
                   cur_I = I_broken(iLine);
                   cur_partial_type = temp_types{cur_I};
                   cur_string = temp_strings{cur_I};  
                   %We are assuming that we only removed 1 space via
                   %textscan. 
                   %
                   %An alternative approach would be to take the raw mex
                   %lines and reparse them. If this is done, we would also
                   %need to remove empty lines in the mex output as these
                   %empty lines cause a misalignment between the textscan
                   %output and the strings output from the mex call.
                   full_line = [cur_partial_type ' ' cur_string];
                   temp = regexp(full_line,'([^:]+:)\s+(.*)','tokens','once');
                   fixed_types{iLine}   = temp{1};
                   fixed_strings{iLine} = temp{2};
               end
               c{4}(I_broken) = fixed_types;
               c{5}(I_broken) = fixed_strings;
            end
            
            obj.types = cellfun(@(x)x(1:end-1),c{4},'un',0)';
                        
            %Check on length is to handle the transpose case '
            has_quote = cellfun(@(x) x(1) == '''' && length(x) > 1,obj.types);
            obj.types(has_quote) = cellfun(@h__removeQuotes,obj.types(has_quote),'un',0);
            
            
            %At this point, some of these are invalid as they
            %get truncated when they are too long. We can use the length
            %observed versus their specified lengths to determine when this
            %happens and fix them. See .fixStrings
            obj.strings = c{5}';
            obj.strings(has_quote) = cellfun(@h__removeQuotes,obj.strings(has_quote),'un',0);
            
            
            %TODO: Eventually these should undergo lazy evaluation
            %At its base level, the class should just return information
            %from the mex function
            obj.getUniqueGroups();
            obj.fixStrings();
        end
    end
    
    methods (Hidden)
        function fixStrings(obj)
           %
           %
           %    fixStrings(obj)
           %
           %    This is necessary as some strings in the lex parsing are
           %    truncated. We thus go to the original source
            
           observed_lengths     = cellfun('length',obj.strings);
           needs_fixin          = obj.lengths > observed_lengths;
           
           if ~any(needs_fixin)
               return
           end
           
           short_string_I = find(needs_fixin);
           
           %??? Would the addition of the ellipsis ever cause the lengths
           %to match????? Presumably not as otherwise the string itself
           %would be displayed instead of the truncated version.
           %
           %    i.e. my short string t...
           %    ->   my short string test
           %
           %    This has yet to be tested ...
           
           short_starts = obj.absolute_I(short_string_I);
           short_ends   = short_starts + obj.lengths(short_string_I) - 1;
           
           raw_file_string = obj.raw_file_string;
           
           %Grab full strings based on start and end ...
           %---------------------------------------------------------------
           n_strings_to_fix = length(short_string_I);
           
           fixed_strings = cell(1,n_strings_to_fix);
           for iShort = 1:n_strings_to_fix
              fixed_strings{iShort} = raw_file_string(short_starts(iShort):short_ends(iShort));
           end
           obj.strings(needs_fixin) = fixed_strings;
        end
        function getUniqueGroups(obj)
           %
           %

           u_obj = sl.cellstr.unique(obj.types);
           unique_types = u_obj.s_unique;
           unique_types__indices_ca = u_obj.s_group_indices;
           
           obj.unique_types_map = containers.Map(unique_types,unique_types__indices_ca);

        end
% % %         function showAsDocument(obj)
% % %            temp_doc = matlab.desktop.editor.newDocument;
% % %            
% % %            %The idea with this method is to show each line
% % %            %and if it is not a comment line, the parsed
% % %            %lex output ...
% % %            
% % %            %Ideally I could generalize this to other functions as well
% % %            
% % %         end
    end
end

function string_out = h__removeQuotes(string_in)
   %
   %    Goes from:
   %    'text'
   %    to:
   %    text
   string_out = string_in(2:end-1);
end

