% script to test FFT for resized images...

clear all
close all

global rho;

INTERPOLATION_TYPE = 'Fourier';
%INTERPOLATION_TYPE = 'Provided';
WINDOW_TYPE = 'hann';
scaleVal = 4;

input1 = imread('lena.bmp'); input1 = double(input1(:,:,1));   % cast inputs to doubles and only take first field
input2 = imread('lena.bmp'); input2 = double(input2(:,:,1));

%input1 = zeros(256,256);
%input1(82:174,82:174) = 1;

%input2 = zeros(256,256);
%input2(82:174,82:174) = 1;
%input1 = imrotate(input1,45,'bicubic','crop');
input2 = imrotate(input2,45,'bicubic','crop');

figure,imagesc(input1),title('Input 1'),colormap('gray')
figure,imagesc(input2),title('Input 2'),colormap('gray')

%input1 = input1 - mean(mean(input1)); input2 = input2 - mean(mean(input2));

if (strcmp(INTERPOLATION_TYPE,'Fourier'))   % For example, to transform a 256*256 image to a 128*128 image
    disp('Using FOURIER interpolation method')
    
    %input2_resized = interpft(interpft(input2,512,1),512,2);
    input2_fft = fftshift(fft2(input2));    % 1) make 2D-FFT of your image

%    input2_fft = fftshift(fft2(window2d(size(input2,1),size(input2,2),WINDOW_TYPE).*input2));   % take windowed FFT
    padded_input2_fft = zeros(1024,1024);     padded_input2_fft(384:(384+255),384:(384+255)) = window2d(size(input2_fft,1),size(input2_fft,2),WINDOW_TYPE).*input2_fft;
%    padded_input2_fft = zeros(1088,1088);     padded_input2_fft(416:(416+255),416:(416+255)) = window2d(size(input2_fft,1),size(input2_fft,2),WINDOW_TYPE).*input2_fft;
%padded_input2_fft = zeros(1152,1152);     padded_input2_fft(448:(448+255),448:(448+255)) = window2d(size(input2_fft,1),size(input2_fft,2),WINDOW_TYPE).*input2_fft;
%    padded_input2_fft = zeros(1280,1280);     padded_input2_fft(512:(512+255),512:(512+255)) = window2d(size(input2_fft,1),size(input2_fft,2),WINDOW_TYPE).*input2_fft;
%    padded_input2_fft = zeros(1344,1344);     padded_input2_fft(544:(544+255),544:(544+255)) = window2d(size(input2_fft,1),size(input2_fft,2),WINDOW_TYPE).*input2_fft;
%    padded_input2_fft = zeros(1408,1408);     padded_input2_fft(576:(576+255),576:(576+255)) = window2d(size(input2_fft,1),size(input2_fft,2),WINDOW_TYPE).*input2_fft;
%padded_input2_fft = zeros(1536,1536);     padded_input2_fft(640:(640+255),640:(640+255)) = window2d(size(input2_fft,1),size(input2_fft,2),WINDOW_TYPE).*input2_fft;

%    padded_input2_fft(128:383,128:383) = input2_fft;

    figure(2),imagesc(log10(abs(padded_input2_fft))),title('padded magnitude spectrum of input 2')

    input2_resized = ifft2(ifftshift(padded_input2_fft));
    
   % for i=4:4:size(input2_resized,1)  % 4) take every second point
   %     for j=4:4:size(input2_resized,2)    
   %         input2_downsampled(i/4,j/4) = input2_resized(i,j);
   %     end
   % end
%    input2_resized = input2_downsampled;
    
% crop a 256x256 section out of the resized image 
    sht = (size(input2_resized,1)-size(input1,1))/2;      swd = (size(input2_resized,2)-size(input1,2))/2;
    cropped_input2_resized = imcrop(input2_resized,[ceil(swd) ceil(sht) size(input1,2)-1 size(input1,1)-1]);

    figure(3),imagesc(abs(cropped_input2_resized)),title('Magnitude - Resized image 2 using Fourier Interpolation'),colormap('gray')
%    subplot(2,1,2),imagesc(angle(cropped_input2_resized)),title('Phase - Resized image 2 using Fourier Interpolation'),colormap('gray')    
    
%    input2_resized_fft = fftshift(fft2(cropped_input2_resized));
    input2_resized_fft = fftshift(fft2(window2d(size(cropped_input2_resized,1),size(cropped_input2_resized,2),WINDOW_TYPE).*cropped_input2_resized));   % take windowed FFT
    
    h = hipass_filter(size(input2_resized_fft,1),size(input2_resized_fft,2));
    filt_input2_resized_fft = h.*input2_resized_fft;  
    figure(4),imagesc(abs(filt_input2_resized_fft)),title('high-pass filtered magnitude spectrum of input 2 resized with WINDOWING...'),colorbar

    log_polar_input2_fft = imlogpolar(abs(filt_input2_resized_fft),256,256,'bicubic');
    
    figure(5),imagesc(log_polar_input2_fft),title('Log-polar version of figure 4')
    
    
    input1_fft = fftshift(fft2(window2d(size(input1,1),size(input1,2),WINDOW_TYPE).*input1));   % take windowed FFT
    h = hipass_filter(size(input1_fft,1),size(input1_fft,2));   
    filt_input1_fft = h.*input1_fft;  
    figure(6),imagesc(abs(filt_input1_fft)),title('high-pass filtered magnitude spectrum of input 1 with WINDOWING...'),colorbar
    log_polar_input1_fft = imlogpolar(abs(filt_input1_fft),256,256,'bicubic');
    figure(7),imagesc(log_polar_input1_fft),title('Log-polar version of figure 5')
    
    cps_rs = crosspowerspectrum(log_polar_input1_fft,log_polar_input2_fft);
    figure(8),imagesc(cps_rs),title('Phase Correlation'),colormap('gray')
    [i,j] = find(cps_rs == max(max(cps_rs)));
    disp(['Rotation = ',num2str((j-1)*(360/256))])
    disp(['Scale = ',num2str(rho(i))])
    
    
    %

    %input2_ifft = ifft2(input2_fft,512,512);    % 3) do 2D-IFFT after padding the necessary amount
    %for i=2:2:size(input2_ifft,1)   % 4) take every second point
    %    for j=2:2:size(input2_ifft,2)    
    %        input2_resized(i/2,j/2) = input2_ifft(i,j);
    %    end
    %end
%    input2 = input2_resized;   
elseif(strcmp(INTERPOLATION_TYPE,'Provided'))
    fft_input1 = fftshift(fft2(input1));
    fft_input2 = fftshift(fft2(input2));
    h = hipass_filter(size(fft_input1,1),size(fft_input1,2));   
    filt_input1_fft = h.*fft_input1;  
    h = hipass_filter(size(fft_input2,1),size(fft_input2,2));   
    filt_input2_fft = h.*fft_input2;  
    
    figure, imagesc(abs(filt_input1_fft)),title('Filtered magnitude spectrum of image1'),colorbar
    figure, imagesc(abs(filt_input2_fft)),title('Filtered magnitude spectrum of image2'),colorbar
    
    input2 = imresize(input2,4,'bicubic');
    fft_input2 = fftshift(fft2(input2));
    h = hipass_filter(size(fft_input2,1),size(fft_input2,2));   
    filt_input2_fft = h.*fft_input2;  
    figure,imagesc(input2),title('Resized image 2'),colormap('gray')
    figure, imagesc(abs(filt_input2_fft)),title('Filtered magnitude spectrum of image2 after resizing'),colorbar
    
    %disp('Using BILINEAR interpolation method')
    %if(scaleVal>1)
    %    input2 = imresize(input2,scaleVal,'bilinear');
    %end
end



% -------------------- thje Fourier interpolation technique as cut and pasted from fourier_mellin stuff
%                disp('Using Fourier Interpolation to generate resized image -> the pixel range for the scaled output is changed which is not good')
%                input2_fft = fftshift(fft2(rotsclIm));    % 1) make 2D-FFT of your image
%                newHt = scaleVal*size(rotsclIm,1)
%                newWd = scaleVal*size(rotsclIm,2)
%                padded_input2_fft = zeros(newHt,newWd);    % zero-pad the FFT to the necessary size
%                startHt = ceil((newHt-size(rotsclIm,1))/2);
%                startWd = ceil((newHt-size(rotsclIm,2))/2);
%                padded_input2_fft(startHt:(startHt+size(rotsclIm,1)-1),startWd:(startWd+size(rotsclIm,2)-1)) = window2d(size(input2_fft,1),size(input2_fft,2),'hann').*input2_fft;   % wndow the FFT
%                rotsclIm = (ifft2(ifftshift(padded_input2_fft)));   % inverse FFT and get rid of and hopefully negligible imaginary parts


