function [tf,loc] = ismember_rows(data1,data2)
%x Run the ismember function on rows of strings
%
%   [tf,loc] = sl.cellstr.ismember_rows(data1,data2)
%
%   This function simply fills a gap, in that Matlab does not support
%   ismember on rows for cell arrays of strings.
%
%   This function gets around the awkward approach that I've generally seen
%   taken which is to concatenate entries in rows together using some
%   character, usually a space. This however could result in incorrect
%   matches in some corner cases. It also is presumably not as memory
%   efficient as this approach.
%
%   Inputs:
%   -------
%   data1 : cellstr
%   data2 : cellstr
%
%   Outputs:
%   --------
%   tf : logical array
%       Whether or not each row in 'data1' is present in any row in 'data2'
%   loc : numeric array
%       Location of each entry in 'data2'. Rows that don't match have
%       a value of 0
%   
%
%   Examples:
%   ---------
%   1)
%
%   a = {'cheese' 'test';
%       'Wisconsin' 'football';
%        'Duke' 'football'}
%
%   b = {'cheese' 'test';
%       'Duke' 'football'}
%
%   [is_present,loc_I] = sl.cellstr.ismember_rows(a,b)
%
% %   is_present =>
% % 
% %                  1
% %                  0
% %                  1
%
% %        loc_I =>
% % 
% %                 1
% %                 0
% %                 2
%
%   See Also:
%   ---------
%   sl.cell.uniqueRows

%NOTE: This was written rather quickly with little error checking and 
%possibly poor performance compared to a version specific to this task ...

n_rows_1 = size(data1,1);

all_data = [data1; data2];

[~,~,I]  = sl.cell.uniqueRows(all_data);

[tf,loc] = ismember(I(1:n_rows_1),I(n_rows_1+1:end));

end