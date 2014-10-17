%Preload Z-stack on ASI stage by sending serial commands to load ring
%buffer.  'LD Z=nnn'
%Also send 'RM Y=4 Z=0'
%Then 'TTL X=1' will cause Z to move on every camera frame
%'TTL X=0' will turn off Z motion


%% Programming stage positions and behavior
nImages = 11;
cprintf('black','Setting stage to triggerable...\n')
mmc.setSerialPortCommand('COM1', 'TTL X=1', char(13));
answer = mmc.getSerialPortAnswer('COM1', char(10))
cprintf('black','Telling stage to move in Z...\n')
mmc.setSerialPortCommand('COM1', 'RM Y=4 Z=0', char(13));
answer = mmc.getSerialPortAnswer('COM1', char(10))
cprintf('*black','Programming piezo stage...\n')

%Now we tell the stage what z-positions to visit
for i = 1:nImages
    currentZ = -900 + 150*i;
    command = ['LD Z=' num2str(currentZ)];
    cprintf('blue',['Programming Z = ' num2str(currentZ) '...\n'])
    mmc.setSerialPortCommand('COM1', command, char(13))
%     answer = mmc.getSerialPortAnswer('COM1', char(10))
end
cprintf('*black','Done!\n')

%% Preparing for image acquisition
%Pre-defining some variables for image acquisition
width = mmc.getImageWidth();
height = mmc.getImageHeight();
imArr = zeros(height,width, nImages);
sArr = zeros(nImages,1);
%Grab nImages images with the camera
cprintf('*red','Starting image acquisition...\n')
tic
mmc.startSequenceAcquisition(nImages, 0, false);
counter = 1;
while (mmc.isSequenceRunning() || mmc.getRemainingImageCount() > 0)
    if (mmc.getRemainingImageCount() > 0)
        temp_Im = single(typecast(mmc.popNextImage(),'uint16'));
        sArr(counter) = var(temp_Im) / mean(temp_Im);
%         imArr(:,:,counter) = reshape(temp_Im,height,width);
        counter = counter + 1;
    end
end
cprintf('*red','Image acquisition done!\n')
toc

%% Debugging section
%Check to make sure the images were acquired correctly (moving in z)
% for i = 1:nImages
%     currentZ = -85 + 10*i;
%     figure();imagesc(imArr(:,:,i));colormap gray;axis image;axis off;
%     title(['Image at Z-position: ' num2str(currentZ)]);
% end

%Now try to find the position of best focus by fitting a curve and
%calculating the position of the maximum.
p = polyfit([1:nImages],sArr',3)
%Now find the max of the function
maxY = zeros(1,2);
tempX = roots([3*p(1) 2*p(2) p(3)])
maxY(1) = p(1) * tempX(1)^3 + p(2) * tempX(1)^2 + p(3) * tempX(1) + p(4);
maxY(2) = p(1) * tempX(2)^3 + p(2) * tempX(2)^2 + p(3) * tempX(2) + p(4);
maxIdx = find(maxY == max(maxY));
maxX = tempX(maxIdx);
y = p(1)*[1:nImages].^3 + p(2)*[1:nImages].^2 + p(3) * [1:nImages] + p(4);
figure();plot(1:nImages,sArr,'b.');hold on;
plot(maxX, maxY(maxIdx),'r*');
plot(1:nImages,y);
title(['Focus curve fitting n = ' num2str(nImages)]);

mmc.setSerialPortCommand('COM1', 'RM X=0', char(13));
answer = mmc.getSerialPortAnswer('COM1', char(10))
