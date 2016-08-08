classdef mlint < sl.mlint
    %
    %   Class:
    %   sl.mlint.mlint
    %
    %
    %   Status: The default messages are not that useful. I'm currently
    %   looking through all flags to find the best one for thigs type of
    %   information ...
    %
    %   NOTE: Not a lot of detail is available ...
    %   m3 - nothing?? - seems to return fatal errors ...
    %   m2 - errors only
    %   m1 - errors and severe warnings only
    %   m0 - all errors and warnings
    %
    %
    %   Related:
    %   -mess  ??What does this do???
    %   -all   ??I think this ignores things specified as ok
    %   -id    Returns ids
    %   -toks
    %
    %   L 7 (C 9): SYNER: Parse error at '<EOL>': usage might be invalid MATLAB syntax.
    %
    %   Fatal errors are indicated in -lex by:
    %   1/10(10): <NAME>:  fatalError
    
    properties
       line_ 
    end
    
    methods
        function obj = mlint(file_path)
            %
            %   ??? - what does fix mean????
            
            %Flags
            %-notok - include oks - make them 'not ok'
            %???? - how to know if something is marked as ok????
            
            obj.file_path = file_path;
            obj.raw_mex_string = mlintmex(file_path,'-id');
            
            % L 1 (C 10-18): FNDEF: Function name 'test_asdf' is known to MATLAB by its file name: 'test_file_005'.
            % L 9 (C 1): NASGU: The value assigned to variable 'x' might be unused.
            
            %this is a cop out for now and should be removed
            temp = mlintmex(file_path,'-id','-struct');            
            s = temp{1}; %Output is a cell array :/
            
            %Struct format:
            %code being parsed => x = prod(size(y));
            %
            %loc 
            %9 - line # 
            %5 - start column - points to p
            %8 - end -> points to d
            %
            %     loc: [9 5 8]
            %      id: 'PSIZE'
            % message: 'NUMEL(x) is usually faster than PROD(SIZE(x)).'
            %     fix: 0

            ids = {s.id};
            
            levels = mlintlib.all_msg.getIDLevels(ids);
            
            keyboard

            
            
        end
    end
    
end

function helper__examples()

    t = sl.mlint.tester;
    temp = sl.mlint.mlint(t.getSpecificTestFilePath(5));


end

