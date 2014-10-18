%This function calculates automatic a pseudo-flatfield image and deducts
%from the image, to subtract the background.
%The algorithm uses that implemented in imageJ
% Shraddha Shitut, SOCM Lab, IISER Pune
function [L] = preProIm_V5( I, varargin )
% clear all, close all
% path='E:\Shraddha\TempExpt_WT\images\K12_30';
% cd(path);
% imName = sprintf('K_2.5_05.tif');
% I = imread(imName);
%I = imadjust(I);
if nargin == 1
    %default value
    fltRad = 5;%gaussian filter radius
elseif nargin == 2
    fltRad = varargin{1};%the second argument
else
    'preProIm_V5: not all inputparams defined'
end
    
PSF = fspecial('gaussian',11,fltRad);
Blurred = imfilter(I,PSF,'conv');
V = .04;
BlurredNoisy = imnoise(Blurred,'gaussian',0,V);
NP = V*prod(size(I)); 
[reg1 LAGRA] = deconvreg(BlurredNoisy,PSF,NP);
G = imsubtract(I,reg1);
%G1 = imsubtract(I,Blurred);
%G1 = double(I)./double(reg1);
%H = wiener2(G,[5,5]);
L = imadjust(G);
% subplot(2,2,1),imshow(imadjust(I));
% subplot(2,2,2),imshow(imadjust(G));
% subplot(2,2,3),imshow(imadjust(G1));
% subplot(2,2,4),imshow(reg1);
