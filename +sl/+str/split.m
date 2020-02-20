function output = split(str,varargin)
%
%   output = sl.str.split(str,varargin)
%
%   Optional Inputs
%   ---------------
%   d : string
%       Delimiter
%   escape_d : logical
%       If true, d should be treated as a literal. NYI
%
%   Improvements
%   ------------
%   Allow row splitting as well.
%
%   Examples
%   --------
%   1) By default we split on commas
%   output = sl.str.split('test1,test2,test3');
%   output =>  {'test1'}    {'test2'}    {'test3'}
%
%   2) Here we change the delimiter
%   output = sl.str.split('test1 test2 test3','d',' ')
%   output =>  {'test1'}    {'test2'}    {'test3'}
%
%   3) Splitting on \n is translated as splitting on newlines
%   output = sl.str.split('test1\ntest2\ntest3','d','\n')
%   output => {'test1\ntest2\ntest3'}
%
%   4) Here we split on literally '\n', not a newline
%   output = sl.str.split('test1\ntest2\ntest3','d','\n','escape_d',true)
%   output => {'test1'}    {'test2'}    {'test3'}
%
%   5) Multiple lines, tab delimited columns
%   str = sprintf('%s\t%s\t%s\n%s\t%s\t%s','t1','t2','t3','t4','t5','t6')
%   str =
%     't1	t2	t3
%      t4	t5	t6'
%   output = sl.str.split(str,'row_split',true,'d','\t')
%   output =>
%     {'t1'}    {'t2'}    {'t3'}
%     {'t4'}    {'t5'}    {'t6'}

in.d = ',';
in.escape_d = false;
in.row_split = false;
in = sl.in.processVarargin(in,varargin);

if in.escape_d
    in.d = regexptranslate('escape',in.d);
end

if in.row_split
    %We also have sl.str.getLines but I'm trying to keep this
    %to 1 file.
    lines = sl.str.split(str,'d','\r\n|\n|\r');
    temp = cellfun(@(x) sl.str.split(x,'d',in.d),lines,'un',0);
    if isempty(temp{end})
        temp(end) = [];
    end
    if isempty(temp)
        output = {};
        return
    end
    lengths = cellfun('length',temp);
    %TODO: We could allow padding here ...
    if ~all(lengths == lengths(1))
       error('length mismatch, # of columns differs between rows') 
    end
    output = vertcat(temp{:});
else
    output = regexp(str,in.d,'split');
end


end