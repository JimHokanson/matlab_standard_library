classdef all_msg < sl.obj.handle_light
    %
    %   Class:
    %   sl.mlint.all_msg
    %
    %   Access via:
    %   sl.mlint.all_msg.getInstance
    %
    %   Status: Completed
    %
    %   Improvements
    %   ===================================================================
    %   1. Consider using msg by default instead of all msg
    
    %   TODO: I think there is a bug when a static method in a object
    %   that is in a package
    %   calls the same object in a different object
    %   I want to write this up and submit to TMW
    %   This occured when the getInstance was calling the old
    %   mlintlib.all_msg
    
    properties
       raw_string %output from mlintmex('-allmsg')
    end
    
    properties (Constant)
       LEVEL_DESCRIPTORS = {...
           0    'Aesthetics'
           1    'Warnings'
           2    'Non-Severe Errors'
           3    'Severe Errors'
           4    'Mlint Errors'
           5    'Info and Metrics'
           7    'Internal'} 
    end
    
    properties
        d1 = '------  Parsed information ------'
        ids    %{n x 1} These are strings that identify each error/warning
        %like: 
        %'LIC3'
        %'APWT'
        %'MCAP'
        
        %TODO: I'd like to name these or expose constants
        %with these names ...
        levels  %[n x 1]
        %0 - aesthetics, ex.
        %   NBRAK  0   Use of brackets [] is unnecessary. Use parentheses to group, if needed.
        %1 - warning
        %   ATTF  1   The attribute value <name> is unexpected. Use "true" or "false" instead.
        %2 - non-severe errors, ex.
        %   MCCMC  2   The constructor for superclass <NAME> can only be called once.
        %3 - severe errors 
        %   STRIN  3   A quoted string is unterminated.
        %4 - severe errors - more on mlint end
        %   DEEPN  4   Functions are nested too deeply.
        %5 - information and metrics
        %   CABE  5   The McCabe complexity of <name> is <line #>.
        %7 - internal
        %    These should never be seen by the user
        %   BAIL  7   done with run due to error
        
        msgs   %{n x 1} The full string explaining the reason for the
        %warning or error.
        section_indices %[1 x n] For each id, this indicates the index
        %of the parent type.
        %
        %   my_index = ;
        %   section_index     = obj.section_indices(my_index);
        %   parent_section_id = obj.section_ids(section_index);

        
        section_ids    %{1 x m} Each section is given similar ids 
        %as are given to the individual warning and error messages
        section_titles %{1 x m} 
        type_group_indices %{1 x m}->{1 x o} indices of the ids
        %that belong to each section
    end
    
    methods (Access = private)
        function obj = all_msg
            
            raw_string_local = mlintmex('-allmsg');
            obj.raw_string   = raw_string_local;
            
            %Step 1: Split into sections
            %---------------------------------------------------------------
            % NITS    ========== Aesthetics and Readability ==========
            % SEPEX  0   For better readability, use newline, semicolon, or comma before this statement.
            
            %The section has no # (level) and is wrapped with ==== signs
            %NOTE: We might need to look for more than one if some of the
            %titles ever include a title -> ={5,} <- something like this
            [temp,start_I,end_I] = regexp(raw_string_local,'^\s*(?<id>\w+)\s*=+ (?<type>[^=]+).*\n','names','start','end','lineanchors','dotexceptnewline');
            
            obj.section_ids    = {temp.id};
            obj.section_titles = cellfun(@deblank,{temp.type},'un',0);
            
            %Step 2: Parse each section
            %--------------------------------------------------------------
            start_I_grab = end_I + 1;
            end_I_grab   = [start_I(2:end) length(raw_string_local)] - 1;
            
            n_sections      = length(start_I_grab);
            section_text    = cell(1,n_sections);
            textscan_output = cell(1,n_sections);
            entry_lengths   = zeros(1,n_sections);
            for iSection = 1:n_sections
                section_text{iSection}    = raw_string_local(start_I_grab(iSection):end_I_grab(iSection));
                
                %Example:
                %   ALIGN  0   <reserved word> might not be aligned with its matching END (line <line #>).
                temp = textscan(section_text{iSection},'%s %f %[^\n]','MultipleDelimsAsOne',true);
                
                textscan_output{iSection} = temp;
                entry_lengths(iSection)   = length(temp{1});
            end
            
            %We have textscan results that are nested in cell arrays
            %This method hides some ugly cellfun code.
            fh = @(index) sl.cell.catSubElements(textscan_output,index,'dim',1);
            
            obj.ids    = fh(1);
            obj.levels = fh(2);
            obj.msgs   = fh(3);
            
            %Additional property population
            %--------------------------------------------------------------
            n_types = length(entry_lengths);
            obj.section_indices = sl.array.genFromCounts(entry_lengths,1:n_types);
            
            n_ids = length(obj.ids);
            obj.type_group_indices = sl.array.toCellArrayByCounts(1:n_ids,entry_lengths);
        end
    end
    
    methods (Static)
        function output = getInstance()
            
            persistent class_instance
            
            if isempty(class_instance)
                class_instance = sl.mlint.all_msg;
            end
            output = class_instance;
        end
        function levels_output = getIDLevels(input_ids)
            %
            %   Returns the value of the .levels property for each
            %   input id.
            
            obj = sl.mlint.all_msg.getInstance;
            [mask,loc] = ismember(input_ids,obj.ids);
            if ~all(mask)
                error('Not all input_ids matched')
            end
            
            levels_output = obj.levels(loc);
        end
    end
    
end

