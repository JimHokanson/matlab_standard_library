function [combImage,registered1,registered2,reg_output,cps_rs,cps_trans] = fourier_mellin(data)
% USAGE : [combImage,registered1,registered2,reg_output,cps_rs,cps_trans] = fourier_mellin(data)
%
% coded for use with GUI - see fm_gui.m and fm_guifun.m for details... 
%
% Adam Wilmer, September 2002

global rho

[input1,input2,ROT_METHOD,SCALE_METHOD,WINDOW_TYPE,DISP_TEXT,SORTLIST,WINDOW_SCALE] = fm_parse_inputs(data);

PHASECORR_WINDOW = 0;  % don't apply a window prior to calculation phase-correlation 
SCALE_THRESHOLD = 6;

% -------------------------------------------------------------------------------------------------------------------------------------
% RECOVER ROTATION AND SCALE
% 3) Apply phase-correlation and recover rotation and scale
if (DISP_TEXT) disp('-------'); end
if (WINDOW_SCALE)
    disp('need to confirm whether this is a beneficial thing to do...')
    cps_rs = crosspowerspectrum(data.windowed_input1_freq_lp,data.windowed_input2_freq_lp);      
else
    cps_rs = crosspowerspectrum(data.input1_freq_lp,data.input2_freq_lp);      
end
degrees_per_pixel = 360/size(cps_rs,2);

% - SORTING THE PHASE CORRELATION PEAKS TO IMPLEMENT THE BODGE SLIDER ---------
sorted_cps_rs = sort(cps_rs(:));    % sort the phase correlation output so we can list the most likely rotations/scale combinations (fast)

reg_output.trans_peak = -Inf;
FINEFLAG = 0;

for sorted_index = length(sorted_cps_rs):-1:(length(sorted_cps_rs)+1-SORTLIST)    % iterate through the highest peaks
    [irx,jrx] = find(cps_rs==sorted_cps_rs(sorted_index));     % find {scale,rotation} corresponding to maximum point
    
    sorted_cps_rs_peak = cps_rs(irx,jrx); 
    sorted_rotation = degrees_per_pixel*(jrx-1);

    % decode the scale
    if (irx > size(cps_rs,1)/2)    % then input2 has been scaled DOWN wrt input1
        dsi = size(cps_rs,1)-irx+2;    % not sure why the 2 but reference images show it is necessary
    else                            % input2 has been scaled UP wrt input1
        dsi = irx;
    end

    if(dsi<=1)
        scale_neighbourhood = [NaN; rho(dsi); rho(dsi+1)];
    elseif (dsi>=length(rho))
        scale_neighbourhood = [rho(dsi-1); rho(dsi); NaN];
    else
        scale_neighbourhood = [rho(dsi-1);rho(dsi); rho(dsi+1)];
    end
    if (irx > size(cps_rs,1)/2)    % then input2 has been scaled DOWN wrt input1
        scale_neighbourhood = 1./scale_neighbourhood;
    end
    sorted_scale = scale_neighbourhood(2);
    
    if (sorted_scale>(1/SCALE_THRESHOLD))&(sorted_scale<SCALE_THRESHOLD)    % a lot of scales are stupidly large so threshold them out
        sorted_rotRect1 = imrotate(input2,-sorted_rotation,ROT_METHOD,'crop');  sorted_rotRect2 = imrotate(input2,-(sorted_rotation+180),ROT_METHOD,'crop');  % rectify for rotation and 180degs plus rotation
        sorted_rsRect1 = imresize(sorted_rotRect1,1.0/sorted_scale,SCALE_METHOD);      sorted_rsRect2 = imresize(sorted_rotRect2,1.0/sorted_scale,SCALE_METHOD);   % rectify sorted image prior to translation registration  
        
        [input1,sorted_rsRect1] = zeropad(input1,sorted_rsRect1,0);   % zero-pad the images to be the same size
        [input1,sorted_rsRect2] = zeropad(input1,sorted_rsRect2,0);   % zero-pad the images to be the same size
        sorted_cps_trans1 = crosspowerspectrum(input1,sorted_rsRect1);   sorted_cps_trans2 = crosspowerspectrum(input1, sorted_rsRect2);  % perform phase-correlation     

        if(max(max(sorted_cps_trans1))>max(max(sorted_cps_trans2)));        % then don't add the 180
            [i1,j1]=find(sorted_cps_trans1==max(max(sorted_cps_trans1)));
            sorted_cps_trans_peak = sorted_cps_trans1(i1,j1);
            sorted_rsRect = sorted_rsRect1;
            cps_trans = sorted_cps_trans1;
        else                                                                % then add the 180
            [i1,j1]=find(sorted_cps_trans2==max(max(sorted_cps_trans2)));
            if (sorted_rotation<180)
                sorted_rotation = sorted_rotation+180;
            else
                sorted_rotation = sorted_rotation-180;
            end
            sorted_cps_trans_peak = sorted_cps_trans2(i1,j1);
            sorted_rsRect = sorted_rsRect2;
            cps_trans = sorted_cps_trans2;
        end
            
        %decode the translation
        sortedHtTrans = i1-1; sortedWdTrans = j1-1;             
        if(i1>size(cps_trans,1)/2)   % then need to read the height from the bottom of the phase correlation plot
            sortedHtTrans = sortedHtTrans-size(cps_trans,1);
        end
        if (j1>size(cps_trans,2)/2)  % then need to read the height from the right of the phase correlation plot
            sortedWdTrans = sortedWdTrans-size(cps_trans,2);  
        end
        
        if (sorted_cps_trans_peak>reg_output.trans_peak)
            FINEFLAG=1;
            reg_output.translation = [sortedHtTrans sortedWdTrans];
            reg_output.rotation = sorted_rotation;
            reg_output.scale = sorted_scale;
            reg_output.trans_peak = sorted_cps_trans_peak;
            reg_output.rs_peak = sorted_cps_rs_peak;
            the_one_to_use = sorted_rsRect;
            scales = scale_neighbourhood;
            if (DISP_TEXT) disp(['SAVING: Peak ',num2str(length(sorted_cps_rs)-sorted_index+1),' at rotation=',num2str(sorted_rotation),', scale=',num2str(sorted_scale),' (cps_rs peak ht=',num2str(sorted_cps_rs_peak),') with MAX trans peak at (',num2str(sortedHtTrans),',',num2str(sortedWdTrans),') with ht=',num2str(sorted_cps_trans_peak)]); end
        else
            if (DISP_TEXT) disp(['NOT SAVING: Peak ',num2str(length(sorted_cps_rs)-sorted_index+1),' at rotation=',num2str(sorted_rotation),', scale=',num2str(sorted_scale),' (cps_rs peak ht=',num2str(sorted_cps_rs_peak),') with MAX trans peak at (',num2str(sortedHtTrans),',',num2str(sortedWdTrans),') with ht=',num2str(sorted_cps_trans_peak)]); end
        end

    end
end

if (~FINEFLAG)
    disp(['There is no solution as the recommended scale factor is ',num2str(sorted_scale),' which is, quite frankly, ridiculous.  Move the slider to the RIGHT and try again to look for more suitable solutions.'])
    reg_output.translation = [0 0];
    reg_output.rotation = 0;
    reg_output.scale = 1;
    reg_output.trans_peak = -Inf;
    reg_output.rs_peak = sorted_cps_rs_peak;
    the_one_to_use = input2;
end

% ------ DISPLAY SOME GENERAL INFO ABOUT THE FOURIER-MELLIN SOLUTION -----
if (DISP_TEXT) 
    disp(['Orientation neighbourhood is { ',num2str(reg_output.rotation-degrees_per_pixel),', *',num2str(reg_output.rotation),'*, ',num2str(reg_output.rotation+degrees_per_pixel),' }, i.e., resolution of ',num2str(degrees_per_pixel),' degrees']);
    disp(['Scale neighbourhood is {',num2str(scales(1)),', *',num2str(scales(2)),'*, ',num2str(scales(3)),'}'])
    disp(['Translation is (',num2str(reg_output.translation(1)),',',num2str(reg_output.translation(2)),')'])
end

% -------------------------------------- DO A RECONSTRUCTION FOR VISUAL PURPOSES ------------------------------------------------------

input2_rectified = the_one_to_use; move_ht = reg_output.translation(1); move_wd = reg_output.translation(2);

total_height = max(size(input1,1),(abs(move_ht)+size(input2_rectified,1)));
total_width =  max(size(input1,2),(abs(move_wd)+size(input2_rectified,2)));
combImage = zeros(total_height,total_width); registered1 = zeros(total_height,total_width); registered2 = zeros(total_height,total_width);

% if move_ht and move_wd are both POSITIVE
if((move_ht>=0)&(move_wd>=0))
    registered1(1:size(input1,1),1:size(input1,2)) = input1;
    registered2((1+move_ht):(move_ht+size(input2_rectified,1)),(1+move_wd):(move_wd+size(input2_rectified,2))) = input2_rectified; 
elseif ((move_ht<0)&(move_wd<0))   % if translations are both NEGATIVE
    registered2(1:size(input2_rectified,1),1:size(input2_rectified,2)) = input2_rectified;
    registered1((1+abs(move_ht)):(abs(move_ht)+size(input1,1)),(1+abs(move_wd)):(abs(move_wd)+size(input1,2))) = input1;
elseif ((move_ht>=0)&(move_wd<0))
    registered2((move_ht+1):(move_ht+size(input2_rectified,1)),1:size(input2_rectified,2)) = input2_rectified;
    registered1(1:size(input1,1),(abs(move_wd)+1):(abs(move_wd)+size(input1,2))) = input1;
elseif ((move_ht<0)&(move_wd>=0))
    registered1((abs(move_ht)+1):(abs(move_ht)+size(input1,1)),1:size(input1,2)) = input1;
    registered2(1:size(input2_rectified,1),(move_wd+1):(move_wd+size(input2_rectified,2))) = input2_rectified;    
end

if sum(sum(registered1==0)) > sum(sum(registered2==0))   % find the image with the greater number of zeros - we shall plant that one and then bleed in the other for the combined image
    plant = registered1;    bleed = registered2;
else
    plant = registered2;    bleed = registered1;
end

combImage = plant;
for p=1:total_height
    for q=1:total_width
        if (combImage(p,q)==0)
            combImage(p,q) = bleed(p,q);
        end
    end
end