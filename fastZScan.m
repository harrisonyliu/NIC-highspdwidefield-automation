%Preload Z-stack on ASI stage by sending serial commands to load ring
%buffer.  "LD Z=nnn"
%Also send "RM Y=4 Z=0"
%Then "TTL X=1" will cause Z to move on every camera frame
%"TTL X=0" will turn off Z motion

nImages = 16;
cprintf('*black','Programming piezo stage...')
for i = 1:nImages
    currentZ = -850 + 100*i;
    command = ['LD Z=' num2str(currentZ)];
    cprintf('black',['Programming Z = ' num2str(currentZ) '...'])
    core.setSerialPortCommand('COM1', command, '\r');
    String answer = core.getSerialPortAnswer("Port", "\r")
end
cprintf('black','Setting stage to triggerable...')
core.setSerialPortCommand('COM1', 'TTL X=1', '\r');
String answer = core.getSerialPortAnswer("Port", "\r")
cprintf('black','Telling stage to move in Z...')
core.setSerialPortCommand('COM1', 'RM Y=4 Z=0', '\r');
String answer = core.getSerialPortAnswer("Port", "\r")
cprintf('*black','Done!\n')

%Pre-defining some variables for image acquisition
width = mmc.getImageWidth();
height = mmc.getImageHeight();
imArr = zeros(height*width, nImages);
sArr = zeros(nImages,1);
%Grab nImages images with the camera
tic
mmc.startSequenceAcquisition(nImages, 0, false);
counter = 1;
while (mmc.isSequenceRunning() || mmc.getRemainingImageCount() > 0)
    if (mmc.getRemainingImageCount() > 0)
        sArr(counter) = var(single(mmc.popNextImage()));
        imArr(:,:,i) = mmc.popNextImage();
        counter = counter + 1;
    end
end
toc

for i = 1:nImages
    currentZ = -85 + 10*i;
    figure();imagesc(imArr(:,:,i));colormap gray;axis image;axis off;
    title(['Image at Z-position: ' num2str(currentZ)]);
end
f = fit([1:nImages]',sArr','poly2');
%Now find the max of the function
maxX = -f.p2 - 2*f.p1;
figure();plot(f,1:nImages,sArr,'b.');hold on;
plot([maxX maxX],[min(sArr) max(sArr)],'r-');
title(['Focus curve fitting n = ' num2str(nImages)]);
