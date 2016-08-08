function output = catSubElements(cell_array,index,varargin)
%
%   
%   output = sl.cell.catSubElements(cell_array,index,varargin)
%
%   for cases when you wish the following would work:
%   
%       output = [data{:}{index}]
%
%   This method is meant to get around the situation in which
%   we need to concatenate cell arrays that are in a cell array.
%   
%   ?? - do I want this or something more generic ??? where we specify a
%   function to run ...
%
%
%   TODO: Consider renaming to subsToVectorByIndex
%
%   TODO: Improve documentation
%
%   NOTE: index could be indices
%
%   See Also:
%   
%   

in.dim = 2;
in = sl.in.processVarargin(in,varargin);

sub_elements = cellfun(@(x) x{index},cell_array,'un',0);

output = cat(in.dim,sub_elements{:});

end

function helper__examples()

a    = cell(1,3);
a{1} = {1:3 4:10 5:20};
a{2} = {4:6 2:30};
a{3} = {7:9 3:20};

output1 = sl.cell.catSubElements(a,1);
output2 = sl.cell.catSubElements(a,1,'dim',1);

end
