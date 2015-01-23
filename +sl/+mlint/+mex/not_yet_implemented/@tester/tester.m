classdef tester < sl.obj.handle_light
    %
    %   Class:
    %   sl.mlint.tester
    
    %The goal is to run a function over a bunch of files ...
    
    
    %-com -> from mtree -> comments should be included
    %Which does this effect?
    %TODO: write double testing function
    %
    properties
        %Known to be invalid:
        %
        ALL_KNOWN_FUNCTIONS = {
            '-all'      %1 ----
            '-allmsg'   %2
            '-amb'      %3
            '-body'     %4 ----
            '-callops'  %5
            '-calls'    %6
            '-com'      %7 db,set,tab,tree,ud
            '-cyc'      %8
            '-db'       %9
            '-dty'      %10
            '-edit'     %11
            '-en'       %12
            '-id'       %13
            '-ja'       %14
            '-lex'      %15
            '-m0'       %16
            '-m1'       %17
            '-m2'       %18
            '-m3'       %19
            '-mess'     %20
            '-msg'      %21
            '-notok'    %22
            '-pf'       %23
            '-set'      %24
            '-spmd'     %25
            '-stmt'     %26
            '-tab'      %27
            '-tmree'    %28
            '-tmw'      %29
            '-toks'     %30 ----
            '-tree'     %31
            '-ty'       %32
            '-ud'       %33
            '-yacc'     %34
            };
        UNKNOWN_FUNCTIONS = {'-all' '-body' '-toks'};
        %Since learned:
        %all  - all mlint, even those that are ok (I think), still to check
        %com  - comments - from mtree, effects ???
        %pf   - parfor, info on parfor loops
        %spmd - spmd is a matlab construct, this function finds these
        %    constructs
        %toks -
    end
    
    properties
        f_wild       %@type=sl.dir.file_list_result
        f_specific
    end
    
    methods
        function obj = tester()
            mlintlib_path       = sl.dir.getMyBasePath('',1);
            wild_code_base_path = fullfile(mlintlib_path,'tests','wild_code');
            obj.f_wild          = sl.dir.getFilesInFolder(wild_code_base_path);
            
            test_base_path = fullfile(mlintlib_path,'tests');
            obj.f_specific = sl.dir.getFilesInFolder(test_base_path);
        end
        function test_path = getSpecificTestFilePath(obj,index)
            test_path = obj.f_specific.file_paths{index};
        end
        function output = examineUnknowns(obj,use_wild)
            
            if use_wild
                file_paths_test = obj.f_wild.file_paths;
            else
                file_paths_test = obj.f_specific.file_paths;
            end
            options_test    =  obj.UNKNOWN_FUNCTIONS;
            
            n_files   = length(file_paths_test);
            n_options = length(options_test);
            output = cell(n_files+1,n_options+1);
            output(1,2:end) = options_test;
            for iFile = 1:n_files
                output(iFile+1,1) = {iFile+1};
                for iOption = 1:n_options
                    output{iFile+1,iOption+1} = mlintmex(file_paths_test{iFile},options_test{iOption},'-m3');
                end
            end
        end
        function output = higherOrderTester(obj,use_wild)
            %The goal of this function is to test unknowns in conjunction
            %with the known flags to see if the known flags change because
            %of the unknowns
            
            if use_wild
                file_paths_test = obj.f_wild.file_paths;
            else
                file_paths_test = obj.f_specific.file_paths;
            end
            
            options_test  = obj.UNKNOWN_FUNCTIONS;
            other_options = setdiff(obj.ALL_KNOWN_FUNCTIONS,options_test);
            n_files   = length(file_paths_test);
            n_unknown = length(options_test);
            n_known   = length(other_options);
            output    = cell(n_files,n_unknown,n_known);
            for iFile = 1:n_files
                for iOption = 1:n_unknown
                    for ik = 1:n_known
                        output{iFile,iOption,ik} = mlintmex(file_paths_test{iFile},options_test{iOption},other_options{ik});
                    end
                end
            end
            
            %6  - com -
            %21 - com -
            %24 - com -
            %27 - com -
            %29 - com - 
            
        end
    end
    
end

