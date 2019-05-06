function output = cellToListbox(cell_data,varargin)
%
%   output = sl.gui.cellToListbox(cell_data,varargin)
%
%   Outputs
%   -------
%   output : struct
%       .row_data
%       .header_string
%
%   Optional Inputs
%   ---------------
%   headers : default {}
%   post_pad_length : default 2
%   
%
%   Improvements
%   ------------
%   1) Eventually support max widths per column
%   2) Replace non-printable chars with space => (or optionally some other
%   character)




%{


wtf = uicontrol('style','listbox','Position',[10 10 500 300])

headers = {'name','value'};
cell_data = {'This is a test' 12345; 'Hi mom' 13413241};

output = sl.gui.cellToListbox(cell_data,'headers',headers)

output = sl.gui.cellToListbox({},'headers',headers)


%}

s = struct;

TRUE_FALSE = {'false' 'true'};

in.line_numbers = [];
in.show_line_numbers = true;
in.post_pad_length = 1;
in.pre_pad_length = 1;
in.headers = {};
in.merge_header = false;
% in.logical %Thinking about allowing different styles of logical ...
%   => could also allow function handles ...
in = sl.in.processVarargin(in,varargin);


PRE_PAD = char(32*ones(1,in.pre_pad_length));
POST_PAD = char(32*ones(1,in.post_pad_length));


%TODO: Test if empty ...  
%-------------------------------------------------------
if in.show_line_numbers
    %This could be improved from a memory standpoint
    if ~isempty(in.line_numbers)
        temp = num2cell(in.line_numbers);
    else
        temp = num2cell(1:size(cell_data,1));
    end
    temp = temp(:);
    cell_data = [temp cell_data];
    if ~isempty(in.headers)
        %Note, can't do empty string, this would remove it the headerr
        in.headers = [' ' in.headers];
    end
end

%Conversion of everything to strings
%-------------------------------------------------------
string_data = cell(size(cell_data));
for i = 1:size(cell_data,1)
    for j = 1:size(cell_data,2)
        temp = cell_data{i,j};
        if ischar(temp)
            string_data{i,j} = temp;
        elseif islogical(temp)
            string_data{i,j} = TRUE_FALSE{double(temp)+1};
        else
            %What about NaNs - 
            string_data{i,j} = sprintf('%g',temp);
        end
    end
end

%Length determination
%-------------------------------------------------------
all_lengths = cellfun('length',string_data);
max_column_lengths = max(all_lengths,[],1);

if ~isempty(in.headers)
    if isempty(string_data)
        max_column_lengths = cellfun('length',in.headers);
    else
        max_column_lengths = max(max_column_lengths,cellfun('length',in.headers));
    end
end

%Padding of all strings
%-------------------------------------------------------
for i = 1:size(cell_data,1)
    for j = 1:size(cell_data,2)
        temp = string_data{i,j};
        n_extra = max_column_lengths(j)-length(temp);
        %TODO: Support optional prepad length
        new_string = [PRE_PAD temp char(32*ones(1,n_extra)) POST_PAD];
        string_data{i,j} = new_string;
    end
end

%Padding of all header strings
%-------------------------------------------------------
if ~isempty(in.headers)
    for i = 1:length(in.headers)
     	temp = in.headers{i};
        n_extra = max_column_lengths(i)-length(temp);
        %TODO: Support optional prepad length
        new_string = [PRE_PAD temp char(32*ones(1,n_extra)) POST_PAD];
        in.headers{i} = new_string;
    end 
end

%Creation of merged strings
%-------------------------------------------------------
row_data = cell(size(cell_data,1),1);
for i = 1:size(cell_data,1)
   row_data{i} = sprintf('%s|',string_data{i,:}); 
end

if ~isempty(in.headers)
   header_string = sprintf('%s|',in.headers{:});
else
   header_string = ''; 
end

%Output
%-------------------------------------------------------
if in.merge_header
s.row_data = vertcat(header_string,row_data);
else
s.row_data = row_data;    
end
s.header_string = header_string;
output = s;

end