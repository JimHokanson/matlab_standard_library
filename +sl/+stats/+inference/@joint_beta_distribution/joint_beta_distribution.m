classdef joint_beta_distribution < handle
    %
    %   Class:
    %   sl.stats.inference.joint_beta_distribution
    
    %{
        acc1 = 0.6;
        acc2 = 0.7;
        N = 100;
        obj = sl.stats.inference.joint_beta_distribution.fromAccuraciesAndCount(acc1,acc2,N);
        p_total = obj.getProbP1Greater()
        p_total = obj.getProbP2Greater()
    %}
    
    properties
        x
        a1
        b1
        a2
        b2
        p1
        p2
        p12
    end
    
    methods (Static)
        function obj = fromAccuraciesAndCount(acc1,acc2,N)
            %TODO: Verify acc is between 0 and 1
            if acc1 > 1 || acc2 > 1
                error('Accuracies must be specified from 0 to 1')
            end
            a1 = round(acc1*N);
            a2 = round(acc2*N);
            b1 = N - a1;
            b2 = N - a2;
            obj = sl.stats.inference.joint_beta_distribution(a1,b1,a2,b2);
        end
    end
    
    methods
        function obj = joint_beta_distribution(a1,b1,a2,b2,varargin)
            
            %Technically the beta distribution subtracts 1 ...
            
            in.subtract1 = false;  %NYI
            in = sl.in.processVarargin(in,varargin);
            
            x = 0:0.001:1;
            obj.p1 = (x.^a1).*(1-x).^b1;
            obj.p1 = obj.p1./sum(obj.p1);
            obj.p2 = (x.^a2).*(1-x).^b2;
            obj.p2 = obj.p2./sum(obj.p2);
            obj.p12 = obj.p1'.*obj.p2;
            obj.x = x;
            %1 - rows
            %2 - columns
        end
        function p_total = getProbP1Greater(obj,varargin)
            in.fh = [];
            in = sl.in.processVarargin(in,varargin);
            p_total = 0;
            p12_local = obj.p12;
            x_local = obj.x;
            for i = 1:length(x_local)
                for j = 1:length(x_local)
                    if i > j
                       p_total = p_total + p12_local(i,j); 
                    end
                end
            end
        end
        function p_total = getProbP2Greater(obj,varargin)
            in.fh = [];
            in = sl.in.processVarargin(in,varargin);
            p_total = 0;
            p12_local = obj.p12;
            x_local = obj.x;
            for i = 1:length(x_local)
                for j = 1:length(x_local)
                    if j > i
                       p_total = p_total + p12_local(i,j); 
                    end
                end
            end
        end
    end
end

