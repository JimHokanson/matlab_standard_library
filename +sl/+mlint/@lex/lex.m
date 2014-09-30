classdef lex < sl.mlint
    %
    %   Class:
    %   sl.mlint.lex
    %
    %   This class exposes the mlintmex function with the '-lex' input.
    
    %Properties Per Entry
    %----------------------------------------------------------------------
    properties
        d0 = '----  From raw mlintmex call ----'
        %Following are the properties that are parsed the mlint call.
        %------------------------------------------------------------------
        line_numbers            %[1 x n], For each parsed entry, this 
        %indicates the line number that the entry is on
        column_start_indices    %[1 x n], For each parsed entry
        lengths                 %[1 x n], " " length of content, for some
        %types this is the type itself (if,end,+,-, etc), for others 
        types                   %[1 x n], string name indicating type
        %For example types include:
        %   '{' 
        %   ']' 
        %   '==' 
        %   ';' etc.
        %
        %See private\type_notes for more details
        strings                 %[1 x n], NOT YET IMPLEMENTED
        
        d1 = '-----  Processed Variables -----'
        %NOTE: This should probably be a shared method ...
        %TODO: Lazy evaluation
        absolute_start_indices %[1 x n], Instead of a line number and column
        %index, this provides an absolute index into the string of the file
        %as to where the content starts.
    end
    
    
    %TODO: Make things below private????
    %Would like local tab completion but hidden display
    %Might need to finish help display class to get this ...
    properties
       %.getAbsoluteStartIndices() 
       newline_indices %Indices of '\n'
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
            %   obj = mlintlib.lex(file_path)
            %
            %   INPUTS
            %   -----------------------------------------------------------
            %   file_string : (default, reread from path), this variable
            %       should be read using fileread or similar mechanism
            %       without parsing otherwise a mismatch will occur between
            %       the mlintmex output and 
            
            obj.file_path = file_path;
            %NOTE: The -m3 specifies not to return mlint messages
            obj.raw_mex_string = mlintmex(file_path,'-lex','-m3');

            %Consider: textscan(par.lex,'%d/%d(%d):%[^:]:%s');
            
            c = textscan(obj.raw_mex_string,'%f / %f ( %f ): %s %[^\n]','MultipleDelimsAsOne',true);
            
            %NOTE: Our delimeter is the default (a space). The middle part
            %which specifies the type ends in a colon which is not meant to
            %be included, but filtering on a colon messes up the situation
            %in which the colon character is the type (i.e. '':'':  ). We 
            %use a regular expression below to tease this apart ...
            
            obj.line_numbers         = c{1}';
            obj.column_start_indices = c{2}';
            obj.lengths              = c{3}';
            
            %NOTE: At this point, some of these are invalid as they
            %get truncated when they are too long. We can use the length
            %observed versus their specified lengths to determine when this
            %happens and fix them. See .fixStrings
            obj.strings              = c{5}';
            
            %NOTE: I had a hard time extracting the lexical content using
            %just textscan. The general format is space, followed by text 
            %followed by a colon, followed by spaces. 
            %For example:
            %   '(':
            %   IF:
            %   <NAME>:
            % 
            %   The tricky one is the colon identifier:
            %   ':':
            %
            %   In c{4} we have the text, followed by a colon.
            %
            %   
            obj.types = regexp(c{4},'[^''][^:'']*','match','once')';
            
            %TODO: Eventually these should undergo lazy evaluation
            %At its base level, the class should just return information
            %from the mex function
            obj.getAbsoluteStartIndices();
            obj.getUniqueGroups();
            obj.fixStrings();
        end
    end
    
    methods (Hidden)
        function fixStrings(obj)
           %
           %
           %    fixStrings(obj)
            
           observed_lengths     = cellfun('length',obj.strings);
           short_string_indices = find(obj.lengths > observed_lengths);
           
           if isempty(short_string_indices)
               return
           end
           
           %??? Would the addition of the ellipsis ever cause the lengths
           %to match????? Presumably not as otherwise the string itself
           %would be displayed instead of the truncated version.
           %
           %    i.e. my short string t...
           %    ->   my short string test
           
           short_starts = obj.absolute_start_indices(short_string_indices);
           short_ends   = short_starts + obj.lengths(short_string_indices) - 1;
           
           str = obj.raw_file_string;
           
           %Grab full strings based on start and end ...
           %---------------------------------------------------------------
           all_strings = obj.strings;
           obj.strings = {}; %Not sure if this helps, idea was to try
           %and prevent data duplication by object trying to hold onto
           %to versions ...
           for iShort = 1:length(short_string_indices)
              all_strings{short_string_indices(iShort)} = str(short_starts(iShort):short_ends(iShort));
           end
           obj.strings = all_strings;
        end
        function getAbsoluteStartIndices(obj)
           %getAbsoluteStartIndices
           % 
           %    getAbsoluteStartIndices(obj)
           
           %NOTE: We can't rely on EOL parsing for returning all 
           %end of lines, as EOL signifies the line with the end of the
           %statement, and ignores ... lines
           I_newline = obj.raw_file_newline_indices();
           
           index_of_previous_line_end = [0 I_newline];
           
           obj.absolute_start_indices = ...
                        index_of_previous_line_end(obj.line_numbers) ...
                                    + obj.column_start_indices;
                                
           obj.newline_indices = I_newline;                     
        end
        function getUniqueGroups(obj)
           %
           %

           u_obj = sl.cellstr.unique(obj.types);
           unique_types = u_obj.s_unique;
           unique_types__indices_ca = u_obj.s_group_indices;
           
           obj.unique_types_map = containers.Map(unique_types,unique_types__indices_ca);

        end
        function showAsDocument(obj)
           temp_doc = matlab.desktop.editor.newDocument;
           
           %The idea with this method is to show each line
           %and if it is not a comment line, the parsed
           %lex output ...
           
           %Ideally I could generalize this to other functions as well
           
        end
    end
end

