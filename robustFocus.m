function robustFocus(mmc,gui,scale,correction_Im)
tic
mmc.setFocusDevice('TIZDrive');
roughStepSize = 100;
roughHalfRange = 250;
fineStepSize = 10;
fineHalfRange = 75;

%% Focusing script
%Here we prepare the autofocus image acquisition parameters.
w = mmc.getImageWidth();
h = mmc.getImageHeight();
%Now we acquire an image stack
cprintf('red','Autofocus: Acquiring images...');
gui.loadAcquisition('C:\Users\nicuser\Desktop\roughFocus');
% Run the MDA and get the "acquisition" name:
acqName = gui.runAcquisition();
% Get the "cache", which is the image storage (works with either images
% acquired to RAM or to disk):
cprintf('red','Images acquired, reading into Matlab...\n');
imgCache = gui.getAcquisitionImageCache(acqName);
numSlices = gui.getAcquisitionSettings.slices.size;
imstack = zeros(w*scale,h*scale,numSlices);
readAcq();

%Get best position of rough focus
[optimalFocus, maxVal] = getFocus();
move_Distance = (optimalFocus-1) * roughStepSize - roughHalfRange;
gui.setRelativeStagePosition(move_Distance);

%% Fine focus
mmc.setFocusDevice('ZStage'); %Piezo
cprintf('red','Autofocus: Acquiring images...');
gui.loadAcquisition('C:\Users\nicuser\Desktop\fineFocus');
% Run the MDA and get the "acquisition" name:
acqName = gui.runAcquisition();
% Get the "cache", which is the image storage (works with either images
% acquired to RAM or to disk):
cprintf('red','Images acquired, reading into Matlab...\n');
imgCache = gui.getAcquisitionImageCache(acqName);
numSlices = gui.getAcquisitionSettings.slices.size;
imstack = zeros(w*scale,h*scale,numSlices);
readAcq();

%Get best position of rough focus
[optimalFocus, maxVal] = getFocus();
move_Distance = (optimalFocus-1) * fineStepSize - fineHalfRange;
mmc.setFocusDevice('TIZDrive');
gui.setRelativeStagePosition(move_Distance);
toc

%% Functions
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

    function readAcq()
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
    end
end