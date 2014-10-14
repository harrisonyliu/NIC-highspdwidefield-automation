%Preload Z-stack on ASI stage by sending serial commands to load ring
%buffer.  "LD Z=nnn"
%Also send "RM Y=4 Z=0"
%Then "TTL X=1" will cause Z to move on every camera frame
%"TTL X=0" will turn off Z motion




nImages = 16;
width = mmc.getImageWidth();
height = mmc.getImageHeight();
imArr = zeros(height*width, nImages);
sArr = zeros(16,1);
%Grab 16 images with the camera
tic
mmc.startSequenceAcquisition(16, 0, false);
counter = 1;
while (mmc.isSequenceRunning() || mmc.getRemainingImageCount() > 0)
    if (mmc.getRemainingImageCount() > 0)
        sArr(counter) = var(single(mmc.popNextImage()));
        mmc.popNextImage();
        counter = counter + 1;
    end
end
toc
