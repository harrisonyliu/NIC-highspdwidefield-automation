function process4x(wormImBF,wormImFl,scaleFactor)
%% This will take a uint8 image of a field of view containing worms and return cropped images of the worm
% scale factor refers to how much the image should be downscaled to make
% the initial processing faster (e.g. 0.5 for making the image half size).
startTime = cputime;
bkgDisk = scaleFactor * 100;
closeDisk = scaleFactor * 20;
areaDisk = scaleFactor * 2000;

smallIm = imresize(wormImBF,scaleFactor);
mask = extractWorms(smallIm,bkgDisk,closeDisk,areaDisk);
cropped = isolateImages(wormImFl,mask,scaleFactor);
endTime = cputime;
endTime-startTime
