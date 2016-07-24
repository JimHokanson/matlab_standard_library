classdef pair_info
    %
    %   Class:
    %   sl.array.pairs.pair_info
    
    %{
    TODO: Build in error causing cases
    
    %}
    
    properties
        p1
        p2
        n1
        n2
        length_mismatch
    end
    
    methods
        function obj = pair_info(p1,p2)
            %
            %   obj = sl.array.pairs.pair_info(p1,p2)
            
            obj.p1 = p1;
            obj.p2 = p2;
            obj.n1 = length(obj.p1);
            obj.n2 = length(obj.p2);
            
            obj.length_mismatch = obj.n1 ~= obj.n2;
            if obj.length_mismatch
                h__debugErrors(obj);
            elseif (p1(1) > p2(1)) || (p1(end) > p2(end)) || any(p1(1:end-1) > p2(2:end))
                h__debugErrors(obj);
            end
            %                ~all(ends_I > starts_I) || any(ends_I(1:end-1) > starts_I(2:end))
            %
            %            if o
            %
            
        end
    end
    
end

function h__debugErrors(obj)
%
%   Goal

%1) Assume start is right, where is the end wrong

%Get closest p1 to each p2

%2) Assume end is right, where is the start wrong

keyboard



p1 = obj.p1;
p2 = obj.p2;
n1 = obj.n1;
n2 = obj.n2;
I1 = 1;
I2 = 1;
done = false;
while ~done
    d1 = p1(I1);
    d2 = p2(I2);
    if d1 > d2
       keyboard 
    end
    I1 = I1 + 1;
    I2 = I2 + 1;
    if I1 > n1
        if I2 > n2
            %then we're ok
        else
            %extra n2s
            keyboard
        end
    elseif I2 > n2
       %I1 is not, have extra I1s
       %
       %    Issues:
       %    -------
       %    1) missing last p2
       %    2) extra p1 at end
       %    3) extra p1 somewhere in the middle
       %    
       keyboard 
    end
end
end

