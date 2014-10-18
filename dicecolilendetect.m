%Chaitnaya Athale, Manasi Gangan, IISER Pune, 2014
%Hemangi Chaudhari, IISER Pune, 2012
%AIM : Dectection of rod shaped objects in a DIC image and their
%length measurement

%% USAGE
%USER INPUTS :
% 1. ipath  : Pathname of the image/s to be processed
% 2. Imagename : Name of the image (loops can be used to processmultiple files in one run
% 3. filename : Name of the output file
% 4. imname1 = Name of the output image with marked objects
% 5. diff_threshold : threshold for detection of the gradient ~12000 for 16-bit Tiff images
% 5. Scaling_factor  : scaling factor for the image : pixels to microns
% (from microscope)
% 7. size_threshold : threshold for object length in micrometers
% 8. Branching  : Branching = 1 for Including branched objects with pruning
%                 Branching = 0 for Exculding branched objects
%% Output
% 1. Lengths of objects in a text file called filename
% 2. Objects marked in a tiff  file called imname1
% 3. Cell length distibution in figure 3

clear all
close all
%% PARAMETERS
size_threshold = 1.5;
Scaling_factor  = 0.2200;%microns per pixel
Branching  = 1;
nbin= 15;%number of bins to plot the cell length freq.

%1)%%=======Path :
%Right now set up to choose the code folder..you can set by settign path directly as follows :
%path = "C:/blah  and comment out the next two lines
ipath = './'
%fullpath = mfilename('fullpath');
%[path,name,ext,ver] = fileparts(fullpath);
%cd(path);
%% ------USER INPUTS :

%2)%%=======Loop 1 : Organism names : as per image names
for Temperature = 2 : 2
    if Temperature == 1
        temp = '37';
    elseif Temperature ==2
        temp = '22';
    end
    %2.5)%%=======Loop 3 : replicate
    for rep = 0 : 0
        %3)%%=======Loop 2 : time
        for time = 0 : 0

            %4)%%=======Loop 3 : image number
            for image_no = 0 : 0

                %5)%%======= Construction of the image name
                if image_no < 10
                    Imagename = sprintf('Dic_%s_t%02d_r%02d_n%02d.tif',temp,time,rep,image_no) %CHANGE 1
                else
                    Imagename = sprintf('Dic_%s_t%02d_r%02d_n%02d.tif',temp,time,rep,image_no)%CHANGE 2
                end
                filename =  sprintf('%s_t%02d_r%02d_n%02d_out.txt',temp,time,rep,image_no);%CHANGE 3
                imname1 =  sprintf('%s_t%02d_r%02d_n%02d_unmarked.tif',temp,rep,time,image_no);%CHANGE 4
                %Imagename = sprintf('SS_old.tif');
                imname1= [ipath, imname1];
                fid = fopen([ipath,Imagename],'r'); % incase images get over ; the code breaks and moves to next value in the outer loop
                if fid == -1
                    break;
                end

                %5----------
                %% Clearing variables
                %clear P;clear Q; clear K; clear L; clear BWnobord; close all;
                Baclenum = []; BacLength = [];
                %cd(pathname);
                I = imread([ipath, Imagename]);
                % DISPLAY THE ORIGINAL IMAGE
                figure(1), imshow(imadjust(I)), hold on;
                L = preProIm_V5( I, 2 );
                %H = imadd(I,100);
                %G1 = preProIm (I);
                %K = histeq(I); % enhances the contrast of images by transforming the values in an intensity image
                %K = imadjust(H);
                %L1 = wiener2(L,[5,5]); %Performs two-dimensional adaptive noise-removal filtering
                %%-----------Neighborhood processing   : diff between a pixel's
                %%intensity (#) and 3by3 pixels (@s) next to it is calculated.
                %          #@@@
                %           @@@
                %           @@@
                %         # is made 0; if the diff is abv the threshold; else it is made 255;
                %L = G;
                [ a  b ] = size (L);
                X = L;

                figure(2),imshow(X);
                for j = 1 : a-3
                    % gradient detection in the first direction
                    for  i = 1 : b-3

                        Neighbor_mean = mean(mean( X( j : j+2,i+1 : i+3)));
                        Pixel_mean = X(j,i);
                        Diff(j,i) = abs(Pixel_mean - Neighbor_mean);

                    end
                end
                Rdiff = reshape(Diff,1,(a-3)*(b-3));
                [n,x]=imhist(uint8(Rdiff));
                diff_threshold=(range(Rdiff))/3;
                %figure(7), image(Diff)
                for j = 1 : a-3    % gradient detection in the first direction
                    for  i = 1 : b-3

                        if Diff(j,i) > diff_threshold
                            X1(j,i) = 0;
                        else
                            X1(j,i) = 1;
                        end
                    end
                end


                for  i = 1 : b-3  % gradient detection in the second direction
                    for j = 1 : a-3
                        Pixel_mean = X(j,i);
                        Neighbor_mean2 = mean(mean( X( j+1 : j+3,i : i+2)));
                        Diff2(j,i) = abs(Pixel_mean - Neighbor_mean2);

                    end
                end
                Rdiff2 = reshape(Diff2,1,(a-3)*(b-3));
                [n2,x2]=imhist(uint8(Rdiff2));
                diff_threshold2=(range(Rdiff2))/3;

                for  i = 1 : b-3  % gradient detection in the second direction

                    for j = 1 : a-3
                        if Diff2(j,i)  > diff_threshold2

                            X2(j,i) = 0;
                        else
                            X2(j,i) = 1;
                        end
                    end
                end

                % Cleaning operations
                X1 = bwmorph(X1,'clean');
                X2 = bwmorph(X2,'clean');
                Image_neigh = (X1.*X2); %combining the two gradients
                Image = bwmorph(Image_neigh,'majority');
                Image_neigh = bwmorph(Image,'clean');
                %figure(1),imshow(Image_neigh)
                BWnobord = imclearborder(~Image_neigh, 4); % Image inversion and removal of border objects

                BWskel = bwmorph(BWnobord,'thin',Inf); % thinning to generate skeletons
                C = ~BWskel * 1;
                C = uint16(C);
                [a b ]= size(C);
                I2 = imcrop(I,[1 1 (b-1) (a-1)]);
                %Segout = I2.*C;
                BWoutline = bwperim(~BWskel); % Detection of skeletons as seperate objects
                %Segout = I;
                %Segout(BWoutline) = 255;
                %figure(1), imshow(imadjust(Segout));
                %imwrite(Segout, 'DH5_2hr_37_DIC_001_vert.png');
                [B,L] = bwboundaries(BWskel,'noholes');
                %imshow(label2rgb(L, @jet, [.5 .5 .5]));
                %figure(4), imshow(K), hold on;

                for k = 1 : length(B)
                    boundary = B{k};
                    stats = regionprops(L,'Area','PixelList','Centroid', 'Image');
                    Skel_image = double(stats(k).Image);
                    area = stats(k).Area;
                    centroid = stats(k).Centroid;
                    Bacpixels =stats(k).PixelList;

                    if Branching  ==1  % prune branched objects and include them in the lengths counted
                        if size(Bacpixels,1) > 1
                            Bacpixels = Branch_pruning(Bacpixels);  % Branch pruning function
                            BacLength(k,1) = length(Bacpixels);
                        else
                            BacLength(k,1) = 0;
                        end
                    else
                        %--checking if 8 neighborhood has only two pixels so as to remove branched objects
                        Neigh_mask=ones(3); Neigh_mask(2,2)=0; % Count neighbors, not self
                        neigh = conv2(Skel_image,Neigh_mask,'same');% counts no. of neighbors around every  pixel
                        Result_neigh=neigh.*Skel_image; % gives values only for skeleton pixels
                        if isempty(find(Result_neigh >2))== true
                            BacLength(k,1) = length(Bacpixels);
                        else
                            BacLength(k,1) = 0;
                        end
                    end
                    if Scaling_factor * (BacLength(k,1))> size_threshold
                        figure(1), hold on, plot(Bacpixels(:,1),Bacpixels(:,2),'-y','LineWidth',2) ;
                    end
                end
                j=1;
                for i = 1 : length(BacLength)
                    BacLength(i,2) = Scaling_factor * (BacLength(i,1)); %%scale factor for the image is Scaling_factor um per pixel
                    if Scaling_factor * (BacLength(i,1))> size_threshold %%assuming that no bacs that have a length less than 1 micrometer. ref : PMCID: PMC222250, PMC294186
                        Baclenum (j,1) = Scaling_factor * (BacLength(i,1));

                        j=j+1;
                    end
                end

                %nbin=max(Baclenum);
                [n, xout]= hist(Baclenum, nbin);
                dlmwrite([ipath,filename], Baclenum,'-append','delimiter','\t');
                figure(1), print ('-dtiff' , imname1);
                %display and write the img file of the histogram
                figure(5), bar(xout,n), title('Cell length distibution'),...
                    xlabel('Cell length ({\mu}m)'),ylabel('Freq.');
                print ('-dpng' ,[imname1, 'hist.png'] );
            end
        end
    end
end
