function [normVar, ZOffset] = autoFocus(mmc,gui)
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
% gui.setRelativeStagePosition(50);
%Here we prepare the autofocus image acquisition parameters.
w = mmc.getImageWidth();
h = mmc.getImageHeight();
nImages = 11;
imstack = zeros(nImages, w*h);
%Now we acquire an image stack
cprintf('red','Autofocus: Acquiring images...');

%% New fast autofocus routine
mmc.startSequenceAcquisition(nImages, 0, false);
counter = 1;
while (mmc.isSequenceRunning() || mmc.getRemainingImageCount() > 0)
    if (mmc.getRemainingImageCount() > 0)
        temp = single(typecast(mmc.popNextImage(),'uint16'))';
        normVar(counter) = var(temp) / mean(temp);
        counter = counter + 1;
    end
end
cprintf('*red','Image acquisition done!\n')

%% End autofocus acquisition, begin analysis
%Now we pass the stack to find the optimal focus
cprintf('red','Autofocus: Calculating optimal focus...');
% optimalFocus = find(normVar == max(normVar));
% p = polyfit([1:nImages],normVar,3);
% %Now find the max of the function
% maxY = zeros(1,2);
% tempX = roots([3*p(1) 2*p(2) p(3)]);
% maxY(1) = p(1) * tempX(1)^3 + p(2) * tempX(1)^2 + p(3) * tempX(1) + p(4);
% maxY(2) = p(1) * tempX(2)^3 + p(2) * tempX(2)^2 + p(3) * tempX(2) + p(4);
maxObserved = max(normVar);
% maxIdx = find(maxY == max(maxY));
% maxX = tempX(maxIdx);
% y = p(1)*[1:nImages].^3 + p(2)*[1:nImages].^2 + p(3) * [1:nImages] + p(4);
% figure();plot(1:nImages,normVar,'b.');hold on;
% plot(1:nImages,y);
% title(['Focus curve fitting n = ' num2str(nImages)]);
% 
% %Determine if the fit or the observed maxima should be the one the stage
% %moves to.
% if maxObserved > maxY(maxIdx)
%     overallMax = find(normVar == maxObserved);
%     plot(overallMax,maxObserved,'r*');hold off;
% else
%     overallMax = maxX;
%     plot(maxX, maxY(maxIdx),'r*');hold off;
% end

%And now we return the piezo to its default and move the Ti Z drive to
%correct focus. We are now ready to repeat this for the next FOV.
mmc.setFocusDevice('TIZDrive');
overallMax = find(normVar == maxObserved);
% plot(overallMax,maxObserved,'r*');hold off;
move_Distance = (overallMax+1) * autoFocusStepSize - autoFocusHalfRange;
cprintf('red',['Moving ' num2str(move_Distance) ' relative to current position to focus\n'])
gui.setRelativeStagePosition(move_Distance);
ZOffset = move_Distance;

% mmc.snapImage();
% snapIm = reshape(typecast(mmc.getImage() ,'uint16'),w,h)';
% figure(2);imagesc(reshape(snapIm,w,h));colormap gray;axis image;axis off;

%% Troubleshooting section, comment out otherwise.
% And here we snap a picture and montage it to ensure we have focused
%
% w = mmc.getImageWidth();
% h = mmc.getImageHeight();
% bd = mmc.getImageBitDepth();
% if (bd>8)
%     imgType='uint16';
% else
%     imgType='uint8';
% end
% figure();imshowpair(imstack(:,:,1),imstack(:,:,optimalFocus),'montage');
% title(['First image in focal stack                                                Focused Image (Image ' ...
%     num2str(optimalFocus) ' of ' num2str(size(imstack,3)) ')']);
% figure();plot(f,1:nImages,sArr,'b.');hold on;
% plot([maxX maxX],[min(sArr) max(sArr)],'r-');
% title(['Focus curve fitting n = ' num2str(nImages)]);
