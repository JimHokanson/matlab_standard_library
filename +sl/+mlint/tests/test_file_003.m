

function test_file_003

persistent tok_class

print -s

import com.mathworks.jmi.*

Matlab.mtEval('sqrt(5)',1)

!dir

tic
toc

profile viewer

matlabpool(3) 
parfor i = 1:3
c(:,i) = eig(rand(1000));
end
   awesome(3)
%Nested ...
    function awesome(x)
        disp(x)
    end

oApp = actxserver('my.application');

h = actxGetRunningServer('matlab.application');

f = @(x) 4./(1 + x.^2);

G = gpuArray.rand(100);
s = size(G)

X = gather(A)
X = gather(C, lab)

j = batch('aScript')
j = batch(myCluster,'aScript')
j = batch(fcn,N,{x1, xn})

C = Composite()

C = codistributed(X)


c = parcluster
c = parcluster(profile)
% Enter an SPMD block to run the enclosed code in parallel on a number
% of MATLAB workers:
spmd

  % Choose a range over which to integrate based on my unique index:
  range_start      = (labindex - 1) / numlabs;
  range_end        = labindex / numlabs;
  % Calculate my portion of the overall integral
  my_integral      = quadl( f, range_start, range_end );
  % Aggregate the result by adding together each value of “my_integral” 
  total_integral   = gplus( my_integral );
end


syms x
f = taylor(log(1+x));
ezplot(f)
hold on
title(['$' latex(f) '$'],'interpreter','latex')
hold off

result = cexpr(cc,'expression',timeout)
result = cexpr(cc,'expression') 


try
   disp(2)
catch M
   disp(1) 
end

end

function t = tokenize(s,ignore_whitespace)
    
    if isempty(tok_class)
        tok_class = zeros(1,127);
        tok_class(double('A':'Z')) = 1;
        tok_class(double('a':'z')) = 1;
        tok_class(double('0':'9')) = 1;
        tok_class('_') = 1;
        tok_class(' ') = 2;
        tok_class(9) = 2;
    end
    if isempty(s)
        % Handling an empty string gets complicated later on, so we just
        % use a special case here.
        t = zeros(0,2);
        return;
    end
    s(s>127) = 'a'; % assume all non-ascii unicode points are letters
    cls = tok_class(double(s));
    % make sure runs of a given symbol does not count as a token
    symbols = find(cls==0);
    cls(symbols) = 100+(1:length(symbols));
    % we have now classified each character so form tokens from
    % runs of classes.
    [~,pos] = find(diff(cls));
    pos = [1 pos+1 length(s)+1];
    t = zeros(length(pos)-1,2);
    for k=1:length(pos)-1
        word = s(pos(k):(pos(k+1)-1));
        if ignore_whitespace
            % collapse spaces down into a single space
            if cls(pos(k))==2
                word = ' ';
            end
        end
        t(k,:) = [pos(k) hash(word)];
    end
end