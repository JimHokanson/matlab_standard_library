close all

N  = 1;
ii = 81;

time        = linspace(0,10,10000)';
interp_time = linspace(0,10,1000)';
data        = repmat( exp(time),[1 100]);

xi = linspace(time(1),time(end),2*length(time));
method = 1;

tic
for ii = 1:N
    Yi1 = mex_qinterp1(time,data,xi,method);
end
my_time = toc;


tic
for ii = 1:N
    Yi2 = qinterp1(time,data,xi,method);
end
old_time = toc;

fprintf('%g vs %g: %gx improvement\n',my_time,old_time,old_time/my_time)
if any(isnan(Yi1))
    formattedWarning('Detected Nans in output\n')
end

for ii = 1:size(data,2)
    %     figure;
    %     plot(time,data(:,ii))
    %     hold all;
    %     plot(xi,Yi1(:,ii),'-o');
    %     plot(xi,Yi2(:,ii),'-o');
    errz = nansum(abs(Yi1(:,ii)-Yi2(:,ii)));
    if errz> 20*eps
        formattedWarning('Large Error: %sd\n',errz);
    end
    %     legend('src','mex','mfile')
end