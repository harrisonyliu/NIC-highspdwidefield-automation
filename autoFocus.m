function [normVar, ZOffset] = autoFocus(mmc,gui,correction_Im_small)
% Autofocusing script. Pass it the micromanager core object and the gui
% object and this function will automatically take a 150um z-stack around
% the current plane of focus (75um below, 75um above, 10um steps) using the
% piezo stage. It will then calculate the optimal focal plane using the
% normalized variance method, and focus at the optimal location using the
% Z-stage (piezo stage reset to zero). Scale can resize the image for
% faster processing, 0.5 for half sized image.

%% Variables that may need to be changed with different settings
%This assumes a stack 75um above/below with 10um steps. Change if needed
autoFocusStepSize = 15; %Amount piezo will step to autofocus, units in um
autoFocusHalfRange = 75; %E.g. autofocus will scan 75um above and below the current focal plane for a total range of 150um and a half range of 75um

%% Focusing script
%Need to move up a little at first to get an optimized focus curve (BF
%autofocus tends to be about 50um higher than the fluorescence autofocus,
%we use BF to focus since it is about an order of magnitude faster)
%Here we prepare the autofocus image acquisition parameters.
w = mmc.getImageWidth();
h = mmc.getImageHeight();
nImages = 11;

cprintf('black','Initializing plate mapping autofocus, programming stage...\n')
mmc.setSerialPortCommand('COM1', 'TTL X=1', char(13));
% answer = mmc.getSerialPortAnswer('COM1', char(10))
cprintf('black','Telling stage to move in Z...\n')
mmc.setSerialPortCommand('COM1', 'RM Y=4 Z=0', char(13));
% answer = mmc.getSerialPortAnswer('COM1', char(10))
cprintf('*black','Programming piezo stage...\n')
%Now we tell the stage what z-positions to visit
for i = 1:nImages
    currentZ = -900 + 150*i;
    command = ['LD Z=' num2str(currentZ)];
%     cprintf('blue',['Programming Z = ' num2str(currentZ) '...\n'])
    mmc.setSerialPortCommand('COM1', command, char(13))
    %     answer = mmc.getSerialPortAnswer('COM1', char(10))
end
cprintf('*black','Done!\n')
imstack = zeros(nImages, w*h);
normVar = zeros(1,nImages);
%Now we acquire an image stack
cprintf('red','Autofocus: Acquiring images...');

%% New fast autofocus routine
mmc.startSequenceAcquisition(nImages, 0, false);
counter = 1;
while (mmc.isSequenceRunning() || mmc.getRemainingImageCount() > 0)
    if (mmc.getRemainingImageCount() > 0)
        temp = single(typecast(mmc.popNextImage(),'uint16'))' ./ correction_Im_small;
        normVar(counter) = var(temp) / mean(temp);
        counter = counter + 1;
%         snapIm = reshape(temp,w,h)';
%         figure();imagesc(snapIm);colormap gray; axis image;
    end
end
cprintf('*red','Image acquisition done!\n')

%% End autofocus acquisition, begin analysis
%Now we pass the stack to find the optimal focus
cprintf('red','Autofocus: Calculating optimal focus...');
optimalFocus = find(normVar == max(normVar));
maxObserved = max(normVar);

%% Optional polyfitting
% p = polyfit(-75:15:75,normVar,3);
% %Now find the max of the function
% maxY = zeros(1,2);
% tempX = roots([3*p(1) 2*p(2) p(3)]);
% maxY(1) = p(1) * tempX(1)^3 + p(2) * tempX(1)^2 + p(3) * tempX(1) + p(4);
% maxY(2) = p(1) * tempX(2)^3 + p(2) * tempX(2)^2 + p(3) * tempX(2) + p(4);
% maxIdx = find(maxY == max(maxY));
% maxX = tempX(maxIdx);
% y = p(1)*[-75:15:75].^3 + p(2)*[-75:15:75].^2 + p(3) * [-75:15:75] + p(4);
% figure();plot(-75:15:75,normVar,'b.');hold on;
% plot(-75:15:75,y);
% title(['Focus curve fitting n = ' num2str(nImages)]);

%% Back to autofocus
%And now we return the piezo to its default and move the Ti Z drive to
%correct focus. We are now ready to repeat this for the next FOV.
mmc.setFocusDevice('TIZDrive');
overallMax = find(normVar == maxObserved);
% plot((overallMax-1) * autoFocusStepSize - autoFocusHalfRange,maxObserved,'r*');hold off;
move_Distance = (overallMax-1) * autoFocusStepSize - autoFocusHalfRange;
cprintf('red',['Moving ' num2str(move_Distance) ' relative to current position to focus\n'])
gui.setRelativeStagePosition(move_Distance);
ZOffset = move_Distance;

cprintf('*black','Removing stage programming...')
mmc.setSerialPortCommand('COM1', 'RM X=0', char(13));
% answer = mmc.getSerialPortAnswer('COM1', char(10))
cprintf('*black','Done!\n')

% mmc.snapImage();
% w = mmc.getImageWidth();
% h = mmc.getImageHeight();
% snapIm = reshape(typecast(mmc.getImage() ,'uint16'),w,h)';
% figure();imagesc(snapIm);colormap gray;axis image;axis off;

%% Troubleshooting section, comment out otherwise.
% figure();plot(f,1:nImages,sArr,'b.');hold on;
% plot([maxX maxX],[min(sArr) max(sArr)],'r-');
% title(['Focus curve fitting n = ' num2str(nImages)]);
