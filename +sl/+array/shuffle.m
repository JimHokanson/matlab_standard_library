function data_out = shuffle(data_in,varargin)
%
%
%   data_out = sl.array.shuffle(data_in,varargin);
%
%   Status: Basic functionality present but I haven't fully examined what
%   others would like to have and incorporated those things. Also,
%   documentation is unfinished.
%
%   IMPROVEMENTS
%   =======================================================================
%   1) 

in.dim = -1; %Dimension to shuffle along
%   -1,  singleton
%   0,   across all dimensions
%   > 0, specified dimension
in.use_fyd = true; %Uses the Fisher-Yates shuffle
%This tends to be faster, only available after 2011b with Matlab
%functions. In general this should be kept true unless debugging.
in = sl.in.processVarargin(in,varargin);


%NOTE: This should include a switch on the version being > 2011b
if in.use_fyd
    randperm_fh = @(x)randperm(x,x);
else
    randperm_fh = @randperm;
end

if numel(data_in) < 2
    data_out = data_in;
    return
end

dim_use = in.dim;

if dim_use < -1
    error('Dimension: %d is invalid')
elseif dim_use == -1
    %TODO: Make static method of package
    %NOTE: We should check if this is empty
    %but we have a check above for the # of elements
    dim_use = find(size(data_in) ~= 1,1);
elseif dim_use == 0
    data_out   = reshape(randperm_fh(numel(data_in)),size(data_in));
    return
end

if dim_use > ndims(data_in)
    error('Dim requested: %d, is greater than the max # of dims (%d) of the input array',...
        dim_use,ndims(data_in))
end

indices = cell(1,ndims(data_in));

%http://blogs.mathworks.com/loren/2006/11/10/all-about-the-colon-operator/
indices(:) = {':'};
indices(dim_use) = {randperm_fh(size(data_in,dim_use))};

data_out = data_in(indices{:});

end

function helper__examples()

r = reshape(1:25,5,5);
data_out_1  = sl.array.shuffle(r);       %#ok<NASGU>
data_out0 = sl.array.shuffle(r,'dim',0); %#ok<NASGU>
data_out1 = sl.array.shuffle(r,'dim',1); %#ok<NASGU>
data_out2 = sl.array.shuffle(r,'dim',2); %#ok<NASGU>


%Speed test
r = rand(1,100000);

tic
for i = 1:100
data_out0 = sl.array.shuffle(r,'dim',0); %#ok<NASGU>
end
toc

tic
for i = 1:100
data_out0 = sl.array.shuffle(r,'dim',0,'use_fyd',false); %#ok<NASGU>
end
toc

end