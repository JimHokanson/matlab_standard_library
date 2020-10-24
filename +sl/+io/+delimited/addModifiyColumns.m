function addModifiyColumns(file_path,data,varargin)
%
%   sl.io.delimited.addModifiyColumns(file_path,data)
%
%   Inputs
%   ------
%   data : {table,struct,name/value cell arrays}
%       Data should be converted to strings if accuracy of conversion is
%       desired, otherwise the following will be used ...
%       


%{
file_path = dba.files.trial.getSavePath('171211_J');
sl.io.delimited.addModifiyColumns(file_path,{})
%}

in.num_format = '%g';
in.delimiter = 'auto';
in = sl.in.processVarargin(in,varargin);

if strcmp(in.delimiter,'auto')
    [~,~,ext] = fileparts(file_path);
    switch lower(ext)
        case {'.tsv','txt'}
            in.delimiter = '\t';
        case '.csv'
            in.delimiter = ',';
    end
end

%Assuming 1 header line ...
[output, extras] = sl.io.delimited.readFile(file_path,in.delimiter);

d2 = output;
%Note, output is just a set of strings, no formatting

header_names = output(1,:);

if isstruct(data)
    add_names = fieldnames(data);
    for i = 1:length(add_names)
        cur_name = add_names{i};
        data_out = h__addModifyColumn(data_in,header_names,name,value,in);
    end
elseif istable(data)
    
else
    %Assume name/value pairs
    
end

keyboard

end

function data_out = h__addModifyColumn(data_in,header_names,name,value,in)

I = find(strcmp(header_names,name),1);

if isempty(I)
   I = size(data_in,2) + 1;    
end

n_rows = size(data_in,1);

%value
%- numeric
%- strings

if isnumeric(value)
    str_values = arrayfun(@(x) sprintf(in.num_format,x),value,'un',0);
elseif isstring(value)
    str_values = value;
else
    error('Unsupported value for writing to spreadsheet')
end

if length(str_values) == 1
    str_values = str_values';
end

if length(str_values) ~= n_rows-1
   error('mismatch in data length') 
end

data_out = data_in;

data_out(I,:) = str_values;


end