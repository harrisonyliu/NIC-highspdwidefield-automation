function [featVec, cropped] = process6x(wormImBF,wormImFl,scaleFactor)
%% This will take a uint8 image of a field of view containing worms and return cropped images of the worm
% scale factor refers to how much the image should be downscaled to make
% the initial processing faster (e.g. 0.5 for making the image half size).
bkgDisk = scaleFactor * 100;
closeDisk = scaleFactor * 24;
areaDisk = scaleFactor * 2000;

%% Here we extract fluorescence images of each worm separately. Each cell of cropped will contain exactly one worm picture.
smallIm = imresize(wormImBF,scaleFactor);
[cropped, CC] = extractWorms(smallIm,wormImFl,bkgDisk,closeDisk,areaDisk,scaleFactor);
% [cropped, CC] = isolateImages(wormImFl,mask,scaleFactor);
areas = regionprops(CC,'Area');

%% Now we send those images to be processed and have features extracted from them.
featVec = zeros(numel(cropped),5);
if numel(cropped) > 0
    for i = 1:numel(cropped)
        temp = extractFeatures(cropped{i},areas(i).Area);
        featVec(i,:) = temp;
    end
end
