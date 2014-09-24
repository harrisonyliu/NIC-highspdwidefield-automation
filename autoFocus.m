function [normVar, focusSuccess_Bool] = autoFocus(mmc,gui,scale,correction_Im)
% Autofocusing script. Pass it the micromanager core object and the gui
% object and this function will automatically take a 150um z-stack around
% the current plane of focus (75um below, 75um above, 10um steps) using the
% piezo stage. It will then calculate the optimal focal plane using the
% normalized variance method, and focus at the optimal location using the
% Z-stage (piezo stage reset to zero). Scale can resize the image for
% faster processing, 0.5 for half sized image.

%% Variables that may need to be changed with different settings
%This assumes a stack 75um above/below with 10um steps. Change if needed
autoFocusStepSize = 10; %Amount piezo will step to autofocus, units in um
autoFocusHalfRange = 75; %E.g. autofocus will scan 75um above and below the current focal plane for a total range of 150um and a half range of 75um

%% Focusing script
%Need to move up a little at first to get an optimized focus curve (BF
%autofocus tends to be about 50um higher than the fluorescence autofocus,
%we use BF to focus since it is about an order of magnitude faster)
gui.setRelativeStagePosition(30);
mmc.setFocusDevice('ZStage'); %Piezo
%Here we prepare the autofocus image acquisition parameters.
w = mmc.getImageWidth();
h = mmc.getImageHeight();
%Now we acquire an image stack
cprintf('red','Autofocus: Acquiring images...');
gui.loadAcquisition('C:\Users\nicuser\Desktop\cy3-BF-Acq');
% Run the MDA and get the "acquisition" name:
acqName = gui.runAcquisition();
% Get the "cache", which is the image storage (works with either images
% acquired to RAM or to disk):
cprintf('red','Images acquired, reading into Matlab...\n');
imgCache = gui.getAcquisitionImageCache(acqName);
numSlices = gui.getAcquisitionSettings.slices.size;
imstack = zeros(w*scale,h*scale,numSlices);

% Retrieve a "tagged image" from the cache:
for i = 0:numSlices-1
    ti = imgCache.getImage(0,i,0,0);
    % ti = imgCache.getImage(chanIdx, sliceIdx, frameIdx, posIdx);
    % (Indices count from zero.)
    
    % Get the necessary info for conversion from the image tags:
    %     width = ti.tags.get('Width');
    %     height = ti.tags.get('Height');
    pixelType = ti.tags.get('PixelType');
    if strcmp(pixelType, 'GRAY16')
        matlabType = 'uint16';
    else
        matlabType = 'uint8';
    end
    img = typecast(ti.pix, matlabType);   % pixels must be interpreted as unsigned integers
    img = reshape(img, [w, h]); % image should be interpreted as a 2D array
    imstack(:,:,i+1) = imresize(transpose(double(img)./correction_Im),scale);  % make column-major order for MATLAB
end

%Now we pass the stack to find the optimal focus
cprintf('red','Autofocus: Calculating optimal focus...');
[optimalFocus, maxVal] = getFocus();
%To make sure we are actually focusing on something we set a threshold for
%the normalized variance, just in case some fluorescent dust out of focus
%triggers the autofocus routine.
thresh = 0;
maxVal
if maxVal > thresh
    %And now we return the piezo to its default and move the Ti Z drive to
    %correct focus. We are now ready to repeat this for the next FOV.
    gui.setStagePosition(0);
    mmc.setFocusDevice('TIZDrive');
    move_Distance = (optimalFocus-1) * autoFocusStepSize - autoFocusHalfRange - 50;
    cprintf('red',['Moving ' num2str(move_Distance) ' relative to current position to focus\n'])
    gui.setRelativeStagePosition(move_Distance);
    focusSuccess_Bool = 1;
else
    cprintf('red',['Unable to determine correct focus...canceling image acquisition\n'])
    focusSuccess_Bool = 0;
end

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

%% Get focus function
    function [frameNum, maxVal] = getFocus()
        % This function receives an x by y by n image stack and will return the
        % frame number with the best focus as determined by the highest normalized variance
        imLinearElements = numel(imstack(:,:,1));
        numIm = size(imstack,3);
        normVar = zeros(1,numIm);
        
        for i = 1:numIm
            temp = reshape(imstack(:,:,i),1,imLinearElements);
            normVar(i) = var(temp) / mean(temp);
        end
        
        maxVal = max(normVar);
        frameNum = find(normVar == maxVal);
        %         figure();plot(normVar,'b*--');
        %         title('Normalized Variance Focus Curve');
    end

end