function rate = calculateRate(new_time, event_times, kw, method)
%x  Calculate firing rate for time vector
%
%   rate = sci.spikes.calculateRate(new_time, event_times, kw, method)
%
%   Inputs
%   ------
%   new_time : array
%       Times at which to evaluate the rate.
%   event_times : array
%   kw : scalar
%       Kernel width (seconds)
%   method: string
%       Type of kernel. Valid values are:
%       - boxcar
%       - gaussian
%       - alpha
%       - exp ... kw is the time constant of the exponential
%       - triangleNC - non-causal kernel, response is centered on event
%       - triangleC - causal kernel - response follows time
%       - aliasFree - I'm not sure what this is

dt = mean(diff(new_time));
rate = zeros(length(new_time),1);

if ~issorted(new_time)
    error('This function only works for sorted reference times, TI')
end

fh = @(ts,t1,t2)sl.array.indices.ofDataWithinEdges(ts,t1,t2);

switch method
    case 'boxcar'
        %standard rate histogram method
        t1 = new_time - kw/2;
        t2 = new_time + kw/2;
        [I1,I2] = fh(event_times,t1,t2);
        
        rate = (I2-I1+1)*(1/kw);
        
% %         % only compute the rate for non-empty segments.  This is a
% %         % big efficiency gain for sparse data
% %         valid_ind = find( (I2-I1) >= 0);
% %         valid_ind = valid_ind(:)';
% %         for i = valid_ind
% %             rate(i) = (I2(i)-I1(i)+1)/kw;
% %         end
        
    case 'gaussian'
        %non-causal kernel
        %         %time constant for gaussian kernel (sigma)
        %         sigma = dt;
        %         %time interval to construct gaussian kernel
        %         tau = -5*sigma:sigma/5:5*sigma;
        %         %compute gaussian kernel
        %         h = exp(-tau.^2/(2*sigma^2))/(sqrt(2*pi)*sigma);
        %         %transform timestamps into rho vector (delta function)
        %         rho = hist( ts, 0.001:.001:range(ti) );
        %         %cannot have more than 1 spike per 1 ms bin
        %         rho(rho>1)=1;
        %         rate = conv( rho, h );
        sigma = kw/pi;
        t1 = new_time - 5*sigma;
        t2 = new_time + 5*sigma;
        [I1,I2] = fh(event_times,t1,t2);
        
        % only compute the rate for non-empty segments.  This is a
        % big efficiency gain for sparse data
        valid_ind = find( (I2-I1) >= 0);
        valid_ind = valid_ind(:)';
        
%         for i = valid_ind
%             tau = ti(i) - ts(I1(i):I2(i));
%             rate(i) = sum( exp(-tau.^2/(2*sigma^2))/(sqrt(2*pi)*sigma) );
%         end
        
        %Recomputing these each loop takes time
        denom = 1/(sqrt(2*pi)*sigma);
        twoS2 = 1/(2*sigma^2);
        for i = valid_ind
            tau = new_time(i) - event_times(I1(i):I2(i));
            rate(i) = sum(exp(-tau.^2*twoS2));
        end
        rate = rate*denom;
        
    case 'alpha'
        %causal kernel
        %general form of the kernel
        %alpha = dt;
        %h = alpha^2*tau*exp(-alpha*tau);
        %h(h<0)=0;
        
        alpha = 1/(kw/pi);
        if alpha >= 10
            tauMax = 1;
        elseif alpha >= 5 && alpha < 10
            tauMax = 2;
        elseif alpha >= 2 && alpha < 5
            tauMax = 5;
        else
            tauMax = 10;
        end
        
        t1 = new_time - tauMax;
        t2 = new_time;
        [I1,I2] = fh(event_times,t1,t2);
        % only compute the rate for non-empty segments.  This is a
        % big efficiency gain for sparse data
        valid_ind = find( (I2-I1) >= 0);
        valid_ind = valid_ind(:)';
        for i = valid_ind
            tau = new_time(i) - event_times(I1(i):I2(i));
            h = alpha^2*tau.*exp(-alpha*tau);
            rate(i) = sum(h(h > 0));
        end
        
    case 'exp'
        % Causal exponential filter where the kernal width is the time
        % constant of the exponential.
        
        t1 = new_time - 10*kw; % Calculate the exp until < .01% of the signal
        t2 = new_time;
        [I1,I2] = fh(event_times,t1,t2);
        valid_ind = find( (I2-I1) >= 0);
        valid_ind = valid_ind(:)';
        for i = valid_ind
            tau = new_time(i) - event_times(I1(i):I2(i));
            h = exp(-tau/kw);
            rate(i) = sum(h(h > 0));
        end
        
    case 'triangleNC'
        ht = 1/kw;
        m = -1*ht/kw;
        
        t1 = new_time - kw;
        t2 = new_time + kw;

        [I1,I2] = fh(event_times,t1,t2);

        % only compute the rate for non-empty segments.  This is a
        % big efficiency gain for sparse data
        valid_ind = find( (I2-I1) >= 0);
        valid_ind = valid_ind(:)';

        for i = valid_ind
            %NOTE: For speed we avoid the intermediate assignment
            %tau = ti(i)-ts(I1(i):I2(i));
            %                       this below is tau
            rate(i) = sum(abs(    new_time(i)-event_times(I1(i):I2(i))   )*m + ht);
        end

    case 'triangleC'
        %kernel is centered over previous bin
        ht = 1/kw;
        m = ht/kw;
        
        t1 = new_time - 2*kw;
        t2 = new_time;
        [I1,I2] = fh(event_times,t1,t2);
        
        % only compute the rate for non-empty segments.  This is a
        % big efficiency gain for sparse data
        valid_ind = find( (I2-I1) >= 0);
        valid_ind = valid_ind(:)';
        for i = valid_ind
            tau = new_time(i)-event_times(I1(i):I2(i));
            rate(i) = sum( tau(tau<=dt)*m ) + sum( tau(tau>dt)*-m+2*ht );
        end
        
    case 'aliasFree'
        %Sa(x) = sin(x)/x;
        % x = 2*pi*fN*t;
        
        fN = 1/(2*dt);
        
        t1 = new_time - 2/fN;
        t2 = new_time + 2/fN;
        [I1,I2] = fh(event_times,t1,t2);
        
        % only compute the rate for non-empty segments.  This is a
        % big efficiency gain for sparse data
        valid_ind = find( (I2-I1) >= 0);
        valid_ind = valid_ind(:)';
        for i = valid_ind
            tau = new_time(i) - event_times(I1(i):I2(i));
            x = 2*pi*fN*tau;
            rate(i) = sum(fN*sin(x)./x);
        end
    otherwise
        error('Option not found')
end
end