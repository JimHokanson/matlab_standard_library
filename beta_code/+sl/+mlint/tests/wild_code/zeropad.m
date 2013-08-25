function [zi1,zi2] = zeropad(i1,i2,centre_flag)
% USAGE: [zi1,zi2] = zeropad(i1,i2,centre_flag)
%
% function to zero-pad i1 and i2 so that they are exactly the same sizes
%
% centre_flag = 0 means pad from right and bottom edges
% centre_flag = 1 means pad equally from ALL edges of the image
%
% A.I.Wilmer, Oct 2002

% get the sizes of the images
ht_i1 = size(i1,1);  wd_i1 = size(i1,2);
ht_i2 = size(i2,1);  wd_i2 = size(i2,2);

% zero-pad the height
if (ht_i1 > ht_i2)   % then zero-pad i2
    zi2 = zeros(ht_i1,wd_i2);
    if centre_flag
        start_ht = ceil((ht_i1-ht_i2)/2);
        zi2(start_ht:start_ht+ht_i2-1,:) = i2;
    else
        zi2(1:ht_i2,:) = i2;
    end
    zi1 = i1;
elseif (ht_i2 > ht_i1)  % zero-pad i1
    zi1 = zeros(ht_i2,wd_i1);
    if centre_flag
        start_ht = ceil((ht_i2-ht_i1)/2);
        zi1(start_ht:start_ht+ht_i1-1,:) = i1;
    else
        zi1(1:ht_i1,:) = i1;
    end
    zi2 = i2;    
else    % then the images should have the same height
    zi1 = i1;
    zi2 = i2;
end

% zero-pad the width
if (wd_i1 > wd_i2 )  % then zero-pad i2
    out2 = zeros(size(zi2,1),wd_i1);
    if centre_flag
        start_wd = ceil((wd_i1-wd_i2)/2);
        out2(:,start_wd:start_wd+wd_i2-1) = zi2;
    else
        out2(:,1:wd_i2) = zi2;  
    end
    zi2 = out2;
elseif (wd_i2 > wd_i1)  % zeropad i1
    out1 = zeros(size(zi1,1),wd_i2);
    if centre_flag
        start_wd = ceil((wd_i2-wd_i1)/2);        
        out1(:,start_wd:start_wd+wd_i1-1) = zi1;
    else
        out1(:,1:wd_i1) = zi1;  
    end
    zi1 = out1;
end  % if images have the same width then the zi1 and zi2 images generated previously will not be altered...