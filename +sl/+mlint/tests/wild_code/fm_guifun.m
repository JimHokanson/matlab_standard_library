function fm_guifun(action)
% GUI functions for Fourier-Mellin transform GUI
%
% Adam Wilmer, aiw99r@ecs.soton.ac.uk

% Colormap 
m = gray(256);

switch(action)
    
    % Init  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case('create')    
    data.pathname = 'C:\Documents and Settings\aiw99r\My Documents\My Pictures\';   % path pointing to data
    
    % ------------------- window handle storage --------------------
    data.hmain = get(findobj(gcbf,'Tag','Fig1'));
    
    % --------- IMAGE 1 ---------------------------------------------------    
    data.input1reference = [];
    data.input1 = [];   % image data
    data.input1_windowed = [];
    data.input1_freq = [];
    data.input1_magSpec = [];
    data.input1_freq_lp = [];
    data.windowed_input1_freq_lp = [];
    data.logmagspec_lp_ms1 = [];
    data.filename1 = [];    % filename corresponding to image 1
    
    % --------- IMAGE 2 ------------------------------------------------------    
    data.input2reference = [];
    data.input2 = [];
    data.input2_windowed = [];
    data.input2_freq = [];
    data.input2_magSpec = [];
    data.input2_freq_lp = [];
    data.windowed_input2_freq_lp = [];
    data.logmagspec_lp_ms2 = [];
    data.filename2 = [];      % filename corresponding to image 2
    
    % -------- SOME FOURIER-MELLIN PARAMETERS ------------------------  
    data.logpolarScaleRes = 256;    % arguments for imlogpolar() function - they control resolution of the log-polar plot
    data.logpolarAngleRes = 256;  
    data.autocrop = 0;     % automatically crop inputs after resizing
    data.windowType = 'none';   % default window type
    data.RotInterp = 'nearest';      % the default interpolations to use
    data.SclInterp = 'nearest';
    data.LogInterp = 'nearest';
    data.dispText = 0;
    data.performanceLevel = 1;
    data.windowScale = 0;
    
    % -------- REGISTERED IMAGE --------------------------------------    
    data.registered = [];   % registered image matrix
    data.input1registered = [];
    data.input2registered = [];
    data.pc_rs = [];    % phase correlation for the log-polar form
    data.pc_trans = [];
    
    set(gcbf,'Userdata',data);
    set(findobj(gcbf,'Tag','CropInput2'),'String',[num2str(100) '%']);
    
    % Load image 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
case('loadA')
    dispText('','b');
    data = get(gcbf,'Userdata');
    pathname 	= data.pathname;
    
    dispTag('Ref_im','r');     % this stuff isn't that apparent in the aplication??!!
    dispText('Loading image 1','b');
    
    [filename, pathname] = uigetfile([pathname '*.*'], 'Load image 1');    % GUI file browser
    if filename~=0         % if we have a file
        if isempty(findstr(filename,'pgm'))           % if not a PGM
            [M1,ma] = imread([pathname, filename]);
            
            if isind(M1) & ~isempty(ma)
                M1 = 256*double(ind2gray(M1,ma));
            else
                if isgray(M1)
                    M1 = double(M1);
                else
                    M1 = double(rgb2gray(M1));
                end;
            end;
        else     % if it is a PGM
            cesta=strrep([pathname, filename],'.pgm','');    % strip off the .pgm bit for some reason
            M1=readpgm(cesta);    % special pgm reader?!!
        end;
        
        data.input1reference = M1;
        data.input1 = M1;
        data.input1_windowed = window2d(size(M1,1),size(M1,2),data.windowType).*M1;
        set(gcbf,'Userdata',data);
        updateImage(1,0);   % update all the other plots...
        data = get(gcbf,'Userdata');
        
        imDims = size(M1);          % dimensions
        
        set(findobj(gcbf,'Tag','Ref_im_c'),'String',[filename ',   ' int2str(imDims(1)) ' x ' int2str(imDims(2))],'ForegroundColor','k'); 
        
        data.pathname = pathname;   % save pathname of this file
        
        data.filename1 = filename;
        set(gcbf,'Userdata',data);    	
        dispTag('Ref_im','k');
        dispText('','b');
        
    end;
    
    % Load image 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case('loadB')
    dispText('','b');
    
    data 			= get(gcbf,'Userdata');
    pathname 	= data.pathname;
    
    dispTag('Sens_im','r');
    dispText('Loading image 2','b');
    
    [filename, pathname] = uigetfile([pathname '*.*'], 'Load image 2');
    if filename~=0
        if isempty(findstr(filename,'pgm'))
            [M2,ma] = imread([pathname, filename]);
            
            if isind(M2) & ~isempty(ma)
                M2 = 256*double(ind2gray(M2,ma));
            else
                if isgray(M2)
                    M2 = double(M2);
                else
                    M2 = double(rgb2gray(M2));
                end;
            end;
        else
            cesta=strrep([pathname, filename],'.pgm','');
            M2=readpgm(cesta);
        end;
        
        data.input2reference = M2;
        data.input2 = M2;
        data.input2_windowed = window2d(size(M2,1),size(M2,2),data.windowType).*M2;
        set(gcbf,'Userdata',data);
        updateImage(2,0); 
        data = get(gcbf,'Userdata');
        
        vel=size(M2);         
        set(findobj(gcbf,'Tag','Sens_im_c'),'String',[filename ',   ' int2str(vel(1)) ' x ' int2str(vel(2))],'ForegroundColor','k'); 
        
        data.pathname = pathname;
        set(gcbf,'CurrentAxes',findobj(gcbf,'Tag','Axes2'));
        data.h2 =  findobj(gcbf,'Tag','Axes2');
        
        dispTag('Sens_im','k');
        data.filename2 = filename;
        set(gcbf,'Userdata',data);    	
        dispText('','b');
        
        set(findobj(gcbf,'Tag','RotInput2'),'String',num2str(0));   % set the rotate input2 value to ZERO
        set(findobj(gcbf,'Tag','SclInput2'),'String',num2str(1));   % set the scale input2 value to ONE
        set(findobj(gcbf,'Tag','CropInput2'),'String',[num2str(100) '%']);   % set the crop % input2 value to 100
        
    end;
    
case('SetRotInterp')    
    data = get(gcbf,'Userdata');   
    rotStrings = get(findobj(gcbf,'Tag','RotInterp'),'String');
    rotInterp = rotStrings(get(findobj(gcbf,'Tag','RotInterp'),'Value'),:);   % this is a character array possibly with spaces in
    rotInterp(rotInterp==' ') = '';   % get rid of any spaces
    data.RotInterp = rotInterp;
    set(gcbf,'Userdata',data);
    
case('SetSclInterp')
    data = get(gcbf,'Userdata');   
    sclStrings = get(findobj(gcbf,'Tag','SclInterp'),'String');
    sclInterp = sclStrings(get(findobj(gcbf,'Tag','SclInterp'),'Value'),:);   % this is a character array with 8 characters in it
    sclInterp(sclInterp==' ') = '';   % get rid of any spaces
    data.SclInterp = sclInterp;
    set(gcbf,'Userdata',data);
    
case('SetLogPolInterp')
    data = get(gcbf,'Userdata');  
    set(findobj(gcbf,'Tag','Pushbutton1'),'String','please wait...'); 
    lpStrings = get(findobj(gcbf,'Tag','LogPolInterp'),'String');
    lpInterp = lpStrings(get(findobj(gcbf,'Tag','LogPolInterp'),'Value'),:);   % this is a character array with 8 characters in it
    lpInterp(lpInterp==' ') = '';   % get rid of any spaces
    data.LogInterp = lpInterp;
    set(gcbf,'Userdata',data);
    
    updateImage(1,1);   % only update the log-polar plots and related plots...
    updateImage(2,1);

    if data.performanceLevel==1
        set(findobj(gcbf,'Tag','Pushbutton1'),'String',['REGISTER (' num2str(data.performanceLevel) 'peak)']);
    else
        set(findobj(gcbf,'Tag','Pushbutton1'),'String',['REGISTER (' num2str(data.performanceLevel) 'peaks)']);
    end
case('autocrop')
    data = get(gcbf,'Userdata'); 
    data.autocrop = get(findobj(gcbf,'Tag','cb_autocrop'),'Value');
    set(gcbf,'Userdata',data);
        
case('SelectWindow')  
    data = get(gcbf,'Userdata');   
    windowStrings = get(findobj(gcbf,'Tag','FFTwindow'),'String');
    windowSel = windowStrings(get(findobj(gcbf,'Tag','FFTwindow'),'Value'),:);   % this is a character array with 8 characters in it
    windowSel(windowSel==' ') = '';   % get rid of any spaces
    data.windowType = windowSel; 
    set(gcbf,'Userdata',data);
    
case('windowScale')
    data = get(gcbf,'Userdata');
    data.windowScale = get(findobj(gcbf,'Tag','cb_windowScale'),'Value');
    set(gcbf,'Userdata',data);  
    
case('RotateScaleCropInput2')
    data = get(gcbf,'Userdata');    
    filename = data.filename2;
    set(findobj(gcbf,'Tag','Pushbutton1'),'String','please wait...');  
    % parse the rotation input
    rotateVal = str2num(get(findobj(gcbf,'Tag','RotInput2'),'String'));
    if (rotateVal>=360)   % then map back to an angle between 0 and 360
        rotateVal = rotateVal - (360*floor(rotateVal/360));
        set(findobj(gcbf,'Tag','RotInput2'),'String',num2str(rotateVal));
    elseif (rotateVal<360)
        rotateVal = rotateVal - (360*floor(rotateVal/360));
        set(findobj(gcbf,'Tag','RotInput2'),'String',num2str(rotateVal));
    elseif (rotateVal<0)
        rotateVal = rotateVal + 360;
        set(findobj(gcbf,'Tag','RotInput2'),'String',num2str(rotateVal));
    end
    
    % parse the scale input
    scaleVal = str2num(get(findobj(gcbf,'Tag','SclInput2'),'String'));
    if (scaleVal>5)   % 5 is currently the performance limit (increase if algorithm is improved!!)
        scaleVal = 5;
        set(findobj(gcbf,'Tag','SclInput2'),'String',num2str(scaleVal));
    elseif (scaleVal<0.2)
        scaleVal = 0.2;
        set(findobj(gcbf,'Tag','SclInput2'),'String',num2str(scaleVal));
    end
    
    if (size(data.input2reference,1)>0)&(size(data.input2reference,2)>0)   % can only perform if the second image actually exists
        in1ref = data.input1reference;
        
        if ((rotateVal==0)&(scaleVal==1))   % then reset the image to the original loaded one
            rotsclIm = data.input2reference;
            %[data.input1,data.input2] = zeropad(in1ref,rotsclIm,1);  % zero-pad the images for display

            in1_windowed = window2d(size(in1ref,1),size(in1ref,2),data.windowType).*in1ref;
            rs_windowed = window2d(size(rotsclIm,1),size(rotsclIm,2),data.windowType).*rotsclIm;
            [data.input1_windowed,data.input2_windowed] = zeropad(in1_windowed,rs_windowed,1);
            
        else                                % apply the rotation and scale
            rotsclIm = imrotate(data.input2reference,rotateVal,data.RotInterp,'crop');   % apply the rotation and don't change size compared to original      
            rotsclIm = imresize(rotsclIm,scaleVal,data.SclInterp);   % apply the scale, the image size will now have changed
            % now need to zero-pad image1 or image2 depending on what's happened to the image sizes
            if (~data.autocrop)   % then zero-pad the images so that they become the same size
                if ((size(data.input1reference,1)>0)&(size(data.input1reference,2)>0))    % i.e., can only zero-pad if image1 exists
                    %[data.input1,data.input2] = zeropad(data.input1reference,rotsclIm,1);  % zero-pad the images for display
                    data.input2 = rotsclIm;
                    in1_windowed = window2d(size(data.input1reference,1),size(data.input1reference,2),data.windowType).*data.input1reference;   % window the images and zero-pad for use in fourier_mellin
                    rs_windowed = window2d(size(rotsclIm,1),size(rotsclIm,2),data.windowType).*rotsclIm; 
                    [data.input1_windowed,data.input2_windowed] = zeropad(in1_windowed,rs_windowed,1);  % only zero=pad with respect to the original version of input1
                end
            else    % then perform cropping on the larger image
                size_in1 = size(data.input1reference); size_rs = size(rotsclIm);
                if ((size(data.input1reference,1)>1)&(size(data.input1reference,2)>0))     % only crop if input1 exists
                    if (size_rs(1)>size_in1(1))&(size_rs(2)>size_in1(2))     % ...then crop rotsclIm
                        sht = (size_rs(1)-size_in1(1))/2;      swd = (size_rs(2)-size_in1(2))/2;
                        rotsclIm = imcrop(rotsclIm,[ceil(swd) ceil(sht) size_in1(2)-1 size_in1(1)-1]);
                        data.input2 = rotsclIm;     data.input2_windowed = window2d(size(rotsclIm,1),size(rotsclIm,2),data.windowType).*rotsclIm;
                        data.input1 = in1ref;   data.input1_windowed = window2d(size(in1ref,1),size(in1ref,2),data.windowType).*in1ref;
                    elseif (size_rs(1)<size_in1(1))&(size_rs(2)<size_in1(2))   % ...then crop input1
                        sht = (size_in1(1)-size_rs(1))/2;      swd = (size_in1(2)-size_rs(2))/2;
                        newInput1 = imcrop(data.input1reference,[ceil(swd) ceil(sht) size_rs(2)-1 size_rs(1)-1]);
                        data.input1 = newInput1;    data.input1_windowed = window2d(size(newInput1,1),size(newInput1,2),data.windowType).*newInput1;
                        data.input2 = rotsclIm;     data.input2_windowed = window2d(size(rotsclIm,1),size(rotsclIm,2),data.windowType).*rotsclIm;
                    elseif (size_rs(1)==size_in1(1))&(size_rs(2)==size_in1(2))   % then no need to crop anything
                        data.input2 = rotsclIm;     data.input2_windowed = window2d(size(rotsclIm,1),size(rotsclIm,2),data.windowType).*rotsclIm;
                        data.input1 = in1ref;   data.input1_windowed = window2d(size(in1ref,1),size(in1ref,2),data.windowType).*in1ref;                    
                    else
                        disp('fm_guifun.m (290ish): AUTOCROP does not currently work on these types of images (ie, certain rectangle shapes)........')   
                    end
                end
                
            end                
        end
        
        set(gcbf,'CurrentAxes',findobj(gcbf,'Tag','Axes2'));
        data.h2 =  findobj(gcbf,'Tag','Axes2');
        
        cla;
        set(gcbf,'Userdata',data);
        
        updateImage(1,0);
        updateImage(2,0); 
        data = get(gcbf,'Userdata'); 
        
        vel1 = size(data.input1_windowed);      
        vel2 = size(data.input2_windowed);      
        
        set(findobj(gcbf,'Tag','Ref_im_c'),'String',[data.filename1 ',   ' int2str(vel1(1)) ' x ' int2str(vel1(2))],'ForegroundColor','k'); 
        set(findobj(gcbf,'Tag','Sens_im_c'),'String',[data.filename2 ',   ' int2str(vel2(1)) ' x ' int2str(vel2(2))],'ForegroundColor','k'); 
        set(gcbf,'Userdata',data);
        
        dispTag('Sens_im','k');
        dispText('','b');
        
    else
        disp('Cannot rotate/scale a non-existent image')
    end
    
    if data.performanceLevel==1
        set(findobj(gcbf,'Tag','Pushbutton1'),'String',['REGISTER (' num2str(data.performanceLevel) 'peak)']);
    else
        set(findobj(gcbf,'Tag','Pushbutton1'),'String',['REGISTER (' num2str(data.performanceLevel) 'peaks)']);
    end
    set(gcbf,'Userdata',data); 
    
    
case('dispText')
    data = get(gcbf,'Userdata');
    val = get(findobj(gcbf,'Tag','cb_dispText'),'Value');
    if val==1 
        data.dispText = 1;
    else
        data.dispText = 0;
    end
    set(gcbf,'Userdata',data);    
    
case('register')    
    data = get(gcbf,'Userdata');
    set(findobj(gcbf,'Tag','Pushbutton1'),'String','please wait...');  
    
    if ((size(data.input2reference,1)>0)&(size(data.input2reference,1)>0)&(size(data.input1,1)>0)&(size(data.input1,2)>0))
        [data.registered,data.input1registered,data.input2registered,reg_output,data.pc_rs,data.pc_trans] = fourier_mellin(data);
        
        regImDims = size(data.registered);      
        data.regInfo = reg_output;
        set(findobj(gcbf,'Tag','TransOut'),'String',[num2str(data.regInfo.translation(1)) 'x' num2str(data.regInfo.translation(2))],'ForegroundColor','k'); 
        set(findobj(gcbf,'Tag','RotOut'),'String',num2str(data.regInfo.rotation),'ForegroundColor','k'); 
        set(findobj(gcbf,'Tag','ScaleOut'),'String',num2str(data.regInfo.scale),'ForegroundColor','k'); 
        set(findobj(gcbf,'Tag','TransPeakOut'),'String',num2str(data.regInfo.trans_peak),'ForegroundColor','k'); 
        set(findobj(gcbf,'Tag','RSPeakOut'),'String',num2str(data.regInfo.rs_peak),'ForegroundColor','k'); 
        
        set(gcbf,'CurrentAxes',findobj(gcbf,'Tag','Axes3'));
        data.h2 =  findobj(gcbf,'Tag','Axes3');
    end
    if data.performanceLevel==1
        set(findobj(gcbf,'Tag','Pushbutton1'),'String',['REGISTER (' num2str(data.performanceLevel) 'peak)']);
    else
        set(findobj(gcbf,'Tag','Pushbutton1'),'String',['REGISTER (' num2str(data.performanceLevel) 'peaks)']);
    end
    
    set(gcbf,'Userdata',data);    	
    dispText('','b');
    
case('setPerformanceLevel')
    data = get(gcbf,'Userdata');
    data.performanceLevel = floor(get(findobj(gcbf,'Tag','performLevel'),'Value'));
    if data.performanceLevel==1
        set(findobj(gcbf,'Tag','Pushbutton1'),'String',['REGISTER (' num2str(data.performanceLevel) 'peak)']);
    else
        set(findobj(gcbf,'Tag','Pushbutton1'),'String',['REGISTER (' num2str(data.performanceLevel) 'peaks)']);
    end
    set(gcbf,'Userdata',data);    	
    
    
    % invoke help window
case('help')
    data	= get(gcbf,'Userdata');
    
    dispText('','b');
    global FM_PATH;
    web(['file:///' FM_PATH 'help/help_fm.html']);
    
    % BELOW IS THE SELECTIONS FOR THE ANALYSIS WINDOW    
case('input1Select')   
    data = get(gcbf,'Userdata');  
    set(findobj(gcbf,'Tag','Pushbutton1'),'String','please wait...'); 
    sel = get(findobj(gcbf,'Tag','input1analysis'),'Value');
    
    if (sel==1)   % input image 'Input|Magnitude Spectrum|Phase Spectrum|Log-Polar'
        mx = data.input1;
    elseif (sel==2)
        mx = data.input1_windowed;
    elseif(sel==3)  % magnitude spectrum
        mx = data.input1_magSpec;
    elseif(sel==4)  % phase spectrum
        mx = angle(data.input1_freq);
    elseif(sel==5)  % log-polar
        mx = data.input1_freq_lp;
    elseif(sel==6)  % windowed log-polar
        mx = data.windowed_input1_freq_lp;
    elseif(sel==7)   % invariant
        mx = data.logmagspec_lp_ms1;
    else
        disp('input1Select: Should never get here')
    end
    
    set(gcbf,'CurrentAxes',findobj(gcbf,'Tag','Axes1'));    % move to the correct axes
    
    cla;       % clear the image corresponding to these axes
    imagesc(mx);   % display image
    axis image;   % fit axis box tightly around image
    axis ij;      % puts MATLAB into its "matrix" axes mode.  The coordinate system origin is at the upper left corner.  The i axis is vertical and is numbered from top to bottom.  The j axis is horizontal and is numbered from left to right.
    axis off;   % turns off labelling
    colormap('gray');    % not sure where 'm' is coming from
    vel = size(data.input1);
    set(findobj(gcbf,'Tag','Ref_im_c'),'String',[data.filename1 ',   ' int2str(vel(1)) ' x ' int2str(vel(2))],'ForegroundColor','k');     
    
    if data.performanceLevel==1
        set(findobj(gcbf,'Tag','Pushbutton1'),'String',['REGISTER (' num2str(data.performanceLevel) 'peak)']);
    else
        set(findobj(gcbf,'Tag','Pushbutton1'),'String',['REGISTER (' num2str(data.performanceLevel) 'peaks)']);
    end
    
    set(gcbf,'Userdata',data);    	
    
case('input2Select')
    data = get(gcbf,'Userdata');   
    set(findobj(gcbf,'Tag','Pushbutton1'),'String','please wait...'); 
    sel = get(findobj(gcbf,'Tag','input2analysis'),'Value');
    
    if (sel==1)   % input image 'Input|Magnitude Spectrum|Phase Spectrum|Log-Polar|Invariant'
        mx = data.input2;
    elseif(sel==2)
        mx = data.input2_windowed;
    elseif(sel==3)  % magnitude spectrum
        mx = data.input2_magSpec;
    elseif(sel==4)  % phase spectrum
        mx = angle(data.input2_freq);
    elseif(sel==5)  % log-polar
        mx = data.input2_freq_lp;
    elseif(sel==6)  % windowed log-polar
        mx = data.windowed_input2_freq_lp;
    elseif(sel==7)   % invariant
        mx = data.logmagspec_lp_ms2;
    else
        disp('input2Select: Should never get here')
    end
    
    set(gcbf,'CurrentAxes',findobj(gcbf,'Tag','Axes2'));    % move to the correct axes
    
    cla;       % clear the image corresponding to these axes
    imagesc(mx);   % display image
    axis image;   % fit axis box tightly around image
    axis ij;      % puts MATLAB into its "matrix" axes mode.  The coordinate system origin is at the upper left corner.  The i axis is vertical and is numbered from top to bottom.  The j axis is horizontal and is numbered from left to right.
    axis off;   % turns off labelling
    colormap('gray');    % not sure where 'm' is coming from
    if data.performanceLevel==1
        set(findobj(gcbf,'Tag','Pushbutton1'),'String',['REGISTER (' num2str(data.performanceLevel) 'peak)']);
    else
        set(findobj(gcbf,'Tag','Pushbutton1'),'String',['REGISTER (' num2str(data.performanceLevel) 'peaks)']);
    end
    
    set(gcbf,'Userdata',data);    	
    
case('regSelect')    
    data = get(gcbf,'Userdata');   
    sel = get(findobj(gcbf,'Tag','reganalysis'),'Value');
    
    if (sel==1)   % regiistered image 'Registered|Registered Image 2|Log-Polar PC|Spatial PC'
        mx = data.registered;
    elseif(sel==2)
        mx = data.input1registered;
    elseif(sel==3)  % magnitude spectrum
        mx = data.input2registered;
    elseif(sel==4)  % phase spectrum
        mx = data.pc_rs;
    elseif(sel==5)  % log-polar
        mx = data.pc_trans;
    else
        disp('input2Select: Should never get here')
    end
    
    set(gcbf,'CurrentAxes',findobj(gcbf,'Tag','Axes3'));    % move to the correct axes
    
    cla;       % clear the image corresponding to these axes
    imagesc(mx);   % display image
    axis image;   % fit axis box tightly around image
    axis ij;      % puts MATLAB into its "matrix" axes mode.  The coordinate system origin is at the upper left corner.  The i axis is vertical and is numbered from top to bottom.  The j axis is horizontal and is numbered from left to right.
    axis off;   % turns off labelling
    %    colormap(m);    % not sure where 'm' is coming from

    
    set(gcbf,'Userdata',data);    	
    %  dispTag('Ref_im','k');
    %  dispText('','b');
    
otherwise
    disp(['fm_guifun.m: trying to call non-existent switch...',action])
end

% ------------------------------------------------------------------------------------
% *************************** auxilliary functions

function dispText(txt,colr);

set(findobj(gcbf,'Tag','MessText'),'String',txt,'ForegroundColor',colr); 

% ------------------------------------------------------------------------------------
function vr=vrat(ktery);

idx = get(findobj(gcbf,'Tag',ktery),'value');
val = get(findobj(gcbf,'Tag',ktery),'String');
vr=str2num(val(idx));


% ------------------------------------------------------------------------------------
function ramek(kde,barva);

set(findobj(gcbf,'Tag',kde),'XColor',barva);
set(findobj(gcbf,'Tag',kde),'YColor',barva);
set(findobj(gcbf,'Tag',kde),'ZColor',barva);

% ------------------------------------------------------------------------------------
function dispTag(txt,colr);

set(findobj(gcbf,'Tag',txt),'ForegroundColor',colr); 

% ------------------------------------------------------------------------------------
function updateImage(im,LP_ONLY)
% USAGE: updateImage(im,LP_ONLY)        A.I.Wilmer, 2002
%
% function to update magnitude spectra, log-polar plots etc of image 'im'
% LP_ONLY : only update the log-polar plot and stuff dependent on it

data = get(gcbf,'Userdata');  

if (im==1)                  % then update image 1 information
    if (~LP_ONLY)       % if log-polar setting is changed then don't need to do the next couple of lines
        data.input1_freq = fftshift(fft2(data.input1_windowed));
        data.input1_magSpec = hipass_filter(size(data.input1_freq,1),size(data.input1_freq,2)).*abs(data.input1_freq);  
%        data.input1_magSpec = log10(abs(data.input1_freq));  
    end
    data.input1_freq_lp = imlogpolar(data.input1_magSpec,data.logpolarScaleRes,data.logpolarAngleRes,data.LogInterp);
    data.windowed_input1_freq_lp = repmat(window1d(size(data.input1_freq_lp,1),data.windowType),1,size(data.input1_freq_lp,2)).*data.input1_freq_lp;
    data.logmagspec_lp_ms1 = hipass_filter(size(data.input1_freq_lp,1),size(data.input1_freq_lp,2)).*abs(fftshift(fft2(data.input1_freq_lp)));    
elseif (im==2)           % update image 2 plots
    if (~LP_ONLY)    % if log-polar setting is changed then don't need to do the next couple of lines
        data.input2_freq = fftshift(fft2(data.input2_windowed));
        data.input2_magSpec = hipass_filter(size(data.input2_freq,1),size(data.input2_freq,2)).*abs(data.input2_freq);  
%        data.input2_magSpec = log10(abs(data.input2_freq));  
    end
    data.input2_freq_lp = imlogpolar(data.input2_magSpec,data.logpolarScaleRes,data.logpolarAngleRes,data.LogInterp);
    data.windowed_input2_freq_lp = repmat(window1d(size(data.input2_freq_lp,1),data.windowType),1,size(data.input2_freq_lp,2)).*data.input2_freq_lp;
    data.logmagspec_lp_ms2 = hipass_filter(size(data.input2_freq_lp,1),size(data.input2_freq_lp,2)).*abs(fftshift(fft2(data.input2_freq_lp)));    
else
    disp('updateImage(): incorrect image number used.')
end
set(gcbf,'Userdata',data); 