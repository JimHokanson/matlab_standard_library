function [output,is_matched] = regexpSingleMatchTokens(data_in,pattern,varargin)
%
%
%   [output,is_matched] = sl.cellstr.regexpSingleMatchTokens(data_in,pattern)
%   
%   TODO: Finish documentation
%
%
%   Example:
%   -----------------------------------------------------------------------
%   data =>
%     'Altman, Plonsey - 1992 - Approximations of excitation threshold in modeling nerve stimulation.pdf'
%     'Jones, Campbell, Normann - 1992 - A glasssilicon composite intracortical electrode array.pdf'
%     'Krnjevic - 1992 - Cellular and synaptic actions of general anaesthetics.pdf'
%     'Lan, Crago - 1992 - Control of limb movements by functional neuromuscular stimulation.pdf'
%   
%   [output,is_matched] = sl.cellstr.regexpSingleMatchTokens(data,'([^-]*)-\s*(\d+)\s*-\s*([^\.]*)');
%
%   output => {n x 3} -> 3 tokens in request
%     'Altman, Plonsey '                '1992'                         [1x68  char]
%     'Jones, Campbell, Normann '       '1992'                         [1x54  char]
%     'Krnjevic '                       '1992'                         [1x53  char]
%     'Lan, Crago '                     '1992'                         [1x65  char]

in.output_type = 'tokens';
in = sl.in.processVarargin(in,varargin);

if ischar(data_in)
    error('This function is designed for cell strings')
end

%??? Provide length as input????

temp = regexp(data_in,pattern,in.output_type,'once');

len = cellfun('length',temp);

is_matched = len ~= 0;

output_len = max(len);

n_rows = length(data_in);

switch in.output_type
    case 'tokens'
        output = cell(n_rows,output_len);
        output(~is_matched,:) = {''};
        for iRow = find(is_matched)
           output(iRow,:) = temp{iRow};  
        end
    case 'match'
        output = cell(n_rows,1);
        output(~is_matched,:) = {''};
        output(is_matched) = temp(is_matched);
%     case 'start'
%         type = 'numeric';
    otherwise
        error('Output type: "%s" not yet supported')
end



% % % %TODO: Don't iterate over non-matches
% % % %Do this assignment on the output
% % % temp(~is_matched) = {repmat({''},1,output_len)};
% % % 
% % % n_rows = length(data_in);
% % % 
% % % output = cell(n_rows,output_len);
% % % 
% % % for iRow = 1:n_rows
% % %    output(iRow,:) = temp{iRow}; 
% % % end

