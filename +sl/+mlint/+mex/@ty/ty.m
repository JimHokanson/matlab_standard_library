classdef ty < sl.mlint
    %
    %   Class:
    %   sl.mlint.ty
    %
    %   Display the line numbers where each of the file's identifiers are
    %   used.
    %
    %   Can we identify where property blocks start and end? If so, this
    %   would give us access to the line on which each property declaration
    %   starts. This function already does that but we could get a name
    %   collision with properties and variables used in the code. By
    %   restricting ourselves to the extents of property blocks, we'd know
    %   where the property declarations are.
    %
    %   Status:
    %   -------
    %   The code has been finished although the implementation is a bit
    %   rough. We also are not pulling out line numbers by type (cell,
    %   struct, ???, flint)
    %
    
    %{
    FUNCTIONS:  data sl.obj.display_class get.event_names fieldnames get.n_samples size get.n_channels size get.n_reps size data nargin sl isobject sci struct isempty copy length cell sci copy export sl length export fieldnames fromStruct length cell sci sl plotRows sl length subplot plot gcf plot nargin sl isempty all copy min length hold ischar plot ylabel sprintf xlabel plotStacked struct nargin sl length cell isempty error zeros end cumsum hold addEventElements iscell isstruct struct2cell length addHistoryElements iscell size ischar error getDataSubset false sl length zeros cell ischar <VOID> <VOID> <VOID> zeroTimeByEvent length isnumeric zeros error fieldnames getDataAlignedToEvent size error true sl <VOID> length zeros sci getRawDataAndTime removeTimeGapsBetweenObjects length filter nargout copy false sl sci decimateData length cell ceil size end zeros mean abs copy <VOID> runFunctionsOnData iscell ischar str2func isa error class length changeUnits sci length add isobject copy length minus isobject copy length meanSubtract sl nargout copy isempty length bsxfun minus mean abs nargout copy abs mrdivide nargout copy mrdivide power nargout copy power getEventCalculatorMethods sci getSpectrogramCalculatorMethods sci h__createNewDataFromOld copy h__getEventTimes sl isfield error ischar h__timeToSamples h__getNewTimeObjectForDataSubset sl
d:
                     ???: 88
time:
                     ???: 95
units:
                     ???: 96
channel_labels:
                     ???: 97
y_label:
                     ???: 98
history:
                    cell: 103
devents:
                     ???: 112
    
    
    %}
    
    properties
        function_list
        call_names
        call_line_numbers %{1 x n}
        first_line_number
    end
    
    methods
        function obj = ty(file_path)
            
            obj.file_path      = file_path;
            obj.raw_mex_string = mlintmex(file_path,'-ty','-m3');
            
            
            %Extract functions list
            %------------------------------------------------------------
            temp = regexp(obj.raw_mex_string,'[^\n]*','match','once');
            
            if length(temp) < 10 || ~strcmp(temp(1:10),'FUNCTIONS:')
                error('I was assuming that the first line would be a list of functions starting with FUNCTIONS:')
            end
            
            obj.function_list = regexp(temp,'\s*','split');
            
            
            %Extract call info
            %---------------------------------------------------------
            %
            %   This could be made cleaner
            %
            %****
            %The first line is a list of all functions
            
            %****
            %We're currently not holding onto the type of the call
            %like whether or not the variable is a struct or cell
            
            %This approach would give us indices that we want but it would
            %make us loop to get the entries
            [start_I,end_I,call_entries] = regexp(obj.raw_mex_string,'^[^\s:]+','lineanchors','start','end','match');
            
            %Nothing is coming to mind without lookaround operators, for
            %now we'll
            n_entries = length(call_entries)-1;
            line_number_raw_text = cell(1,n_entries);
            
            %We are ignoring the first line with all of the functions
            start_raw_I = end_I(2:end)+2; %name: %We've matched until the
            %'e' so we want to start the raw after the colon
            end_raw_I   = [start_I(3:end)-1 length(obj.raw_mex_string)];
            raw_string = obj.raw_mex_string;
            for iEntry = 1:n_entries
                line_number_raw_text{iEntry} = raw_string(start_raw_I(iEntry):end_raw_I(iEntry));
            end
            
            numbers_only = regexprep(line_number_raw_text,'[^\d]+',' ');
            
            line_numbers = cellfun(@h__toInt,numbers_only,'un',0);
            
            sorted_line_numbers = cellfun(@sort,line_numbers,'un',0);
            
            obj.call_names = call_entries(2:end); %Remove functions
            obj.call_line_numbers = sorted_line_numbers;
            obj.first_line_number = cellfun(@(x) x(1),sorted_line_numbers);
        end
    end
    
end

function array_out = h__toInt(string_in)
array_out = sscanf(string_in,'%d');
end

