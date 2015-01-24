function [cropped, CC] = extractWorms(im,FL,scaleFactor)
%This function will take brightfield image and fluorescence image of a worm
%and return a cell, each element of which contains the cropped fluorescence
%image of one of the identified worms

% scale factor refers to how much the image should be downscaled to make
% the initial processing faster (e.g. 0.5 for making the image half size).
bkgDisk = scaleFactor * 100;
closeDisk = scaleFactor * 24;
areaDisk = scaleFactor * 9000;
% areaDisk = scaleFactor * 2000;

%First we need to invert the image so the "signal"/worms are bright on a
%black background
disp('Processing: Extracting worm images...');
img = imcomplement(imresize(im,scaleFactor));
%Now remove any background in the image
bkg = imopen(img,strel('disk',bkgDisk));
flatIm = img - bkg;

%Threshold the worms using Otsu's method.
thresh = graythresh(flatIm);
flatIm = flatIm./max(max(flatIm));
binary = false(size(flatIm));
binary(flatIm >= thresh) = true;

%Now close the image to remove any "holes" in the worms.
closedImg = imclose(binary,strel('disk',closeDisk));
% %Then open the image to remove as much "noise" as possible.
openImg = imerode(closedImg,strel('disk',20));
% figure();imshowpair(closedImg,openImg,'montage');colormap gray;
% title('Closed                                                       Open');

%Then remove all the noise using an area open
wormImageFinal = bwareaopen(closedImg,areaDisk);

%Now we want to extract the image of each worm individually
[cropped, CC] = isolateImages();

%% Function that will extract individual worm images
    function [cropped, CC] = isolateImages()
        
        CC = bwconncomp(wormImageFinal);
        boundingboxes = regionprops(CC,'BoundingBox');
        cropped = cell(1,numel(boundingboxes));
        
        disp('Processing: Cropping individual worms...');
        for i=1:numel(boundingboxes)
            temp = false(size(FL)*scaleFactor);
            temp(CC.PixelIdxList{i}) = true;
            %     figure(); imagesc(temp);title('image mask');
            maskedIm = imresize(temp,1/scaleFactor) .* double(FL);
            %     figure(); imagesc(maskedIm); title('masked image');
            coord = boundingboxes(i).BoundingBox .* 1/scaleFactor;
            x1 = max(coord(1),1);
            x2 = min(coord(1) + coord(3), size(maskedIm,2));
            y1 = max(coord(2),1);
            y2 = min(coord(2) + coord(4), size(maskedIm,1));
            cropped{i} = maskedIm(y1:y2,x1:x2);
        end
    end

%% Debugging area, shows processing step by step
% figure();imshowpair(img,flatIm,'montage');title('Background Subtraction');
% figure();imshowpair(flatIm,binary,'montage');colormap gray;title('Thresholded');
% figure();imshowpair(binary,closedImg,'montage');colormap gray;
% title('Thresholded                                                Closed');
% CC = bwconncomp(wormImageFinal);
% labeled = labelmatrix(CC);
% RGB_label = label2rgb(labeled,@jet,'k','shuffle');
% figure(4);imshowpair(imresize(im,scaleFactor),RGB_label,'montage');title('Worm Identification');
end