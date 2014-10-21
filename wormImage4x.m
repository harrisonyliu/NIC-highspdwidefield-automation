%% Automated worm imaging
% Harrison Liu and Kurt Thorn
% Automatically image a petri dish, acquire images of C. elegans

%% Initialize Micro-manager
if ~exist('gui', 'var')
    cd 'c:/program files/Micro-Manager-1.4.18'
    import org.micromanager.MMStudioMainFrame;
    import ij.ImageJ;
    ij.ImageJ;
    gui = MMStudioMainFrame(false);
    gui.show();
    uiwait(msgbox('Press when Micro-Manager finishes loading'));
    mmc = gui.getCore;
    acq = gui.getAcquisitionEngine;
    cd 'C:\Users\nicuser\Documents\MATLAB\NIC-highspdwidefield-automation'
end

%%Define acquisition grid (only need to do first time)
%%Manually focus on first point
%%Loop over acquisition grid:
%%Snap image
%%Check for worms
%%No: got to next point
%%Yes: Autofocus, acquire image
%%Check stack for desired phenotype
%%No: Go to next point
%%Yes: Generate ROI
%%Photoactivate Worm
%%Go to next point
close all
if gui.isLiveModeOn() == 1
    gui.enableLiveMode(false);
end
fileDir = 'D:\temp';
% snap an image using the current acquisition settings
w = mmc.getImageWidth();
h = mmc.getImageHeight();
bd = mmc.getImageBitDepth();
if (bd>8)
    imgType='uint16';
else
    imgType='uint8';
end

%% Initiate default scope parameters
mmc.setFocusDevice('ZStage'); %Piezo
%Here we prepare the autofocus image acquisition parameters. We set binning
%to 4, prepare the exposure and set up the Cy3-BF imaging filters and LEDs
mmc.setProperty('Zyla', 'Binning', '1x1')
mmc.setProperty('ScopeLED','ActiveColor','Red');
mmc.setProperty('ScopeLED','IntensityRed',2);
mmc.setProperty('Zyla', 'AcquisitionWindow','2048x2048');
mmc.setProperty('Zyla','Exposure',15);
mmc.setProperty('TIFilterBlock2','Label','1-SEDAT');
mmc.setProperty('Wheel-A','Label','607/36');
mmc.setProperty('ESIOSwitch','Label','Cy3');
mmc.setProperty('Core','Shutter','ScopeLED');
w = mmc.getImageWidth();
h = mmc.getImageHeight();

%Here we read in correction images for fluorescence and brightfield
correction_Im = readMicroManagerTif('C:\MMConfigs\Correction Images\2048 x 2048\4x\BF-Cy3_plate_4x.tif',w,h);
correction_Im = correction_Im ./ max(max(correction_Im)); %Normalization step
drkfield = readMicroManagerTif('C:\MMConfigs\Correction Images\2048 x 2048\Darkfield.tif',w,h);
correction_Im_FL = readMicroManagerTif('C:\MMConfigs\Correction Images\2048 x 2048\4x\Cy3.tif',w,h);
correction_Im_FL = correction_Im_FL ./ max(max(correction_Im_FL)); %Normalization step
% svmModel = load('wormSVMModel.mat');

%% Generate a list of positions on the plate to image
load('50mm_plate_raster_scan_positions_4x_spiral.mat');
%X,Y are the index locations of the plate grid
%stageX, stageY are the coordinates of the position in stage units
%stageZ is the zoffset of the particular plate location relative to the
%first FOV
tot_Positions = numel(xPositions);
ZOffset = zeros(1,numel(xPositions));
worm_Ims = cell(0);
worm_FOVNum = [];
figure(1);status_Plot = tight_subplot(2,3,[.05 .01],[.01 .05],[.01 .01]);
set(figure(1),'WindowStyle','docked');
screenTime = zeros(1,numel(xPositions));

%% Autofocus plate mapping
%Begin by autofocusing at every other field of view and saving the results
%in a plate map (stageZ is NaN outside of the plate, 0 where nothing has
%been measured, all other values are measured Z offsets
for i = 2:2:numel(xPositions)
    if isnan(stageZ(yPositions(i),xPositions(i))) == 0
        gui.setXYStagePosition(rows(yPositions(i)),cols(xPositions(i)));
        axes(status_Plot(2));plot(xPositions,yPositions,'b.',xPositions(i),yPositions(i),'r*');
        title(['Current Scan Position ' num2str(i) ' of ' num2str(tot_Positions)]);axis image;axis off;
        cprintf('*red','Autofocusing...\n')
        [normVar, ZOffset] = autoFocus(mmc,gui);
        if i == 2
            stageZ(yPositions(i),xPositions(i)) = ZOffset;
            temp = ZOffset;
        else
            stageZ(yPositions(i),xPositions(i)) = ZOffset + temp;
            temp = stageZ(yPositions(i),xPositions(i));
        end
        axes(status_Plot(3));plot(normVar,'b.');
        title(['Scan Position ' num2str(i) ' Focus Curve']);
    end
end
%And we subtract off the first position to put all distances relative to it
stageZ = stageZ - stageZ(yPositions(1),xPositions(1));

%Now that we have measured the Z offset for half the fields of view, we
%interpolate the rest of the FOVs to get a focus map for the entire plate
for i = 1:2:numel(xPositions)
    if isnan(stageZ(yPositions(i),xPositions(i))) == 0
        right = stageZ(yPositions(i),xPositions(i+1));
        left = stageZ(yPositions(i),xPositions(i-1));
        up = stageZ(yPositions(i+1),xPositions(i));
        down = stageZ(yPositions(i-1),xPositions(i));
        neighbors = [right, left, up, down];
        neighbors(neighbors == 0) = [];
        neighbors(isnan(neighbors)) = [];
        stageZ(yPositions(i),xPositions(i)) = mean(neighbors);
    end
end

        %% BEGINNING OF SCREENING
%Begin by moving to a new position and running through the script
for i = 1:numel(xPositions)
    %Loop through each of the image positions, focus, and snap an image
    disp(['Moving to position ' num2str(i) ' of ' num2str(tot_Positions)])
    gui.setXYStagePosition(xPositions(i),yPositions(i));
    axes(status_Plot(2));plot(xPositions,yPositions,'b.',xPositions(i),yPositions(i),'r*');
    title(['Current Scan Position ' num2str(i) ' of ' num2str(tot_Positions)]);axis image;axis off;
    %             mmc.snapImage();
    %             w = mmc.getImageWidth();
    %             h = mmc.getImageHeight();
    %             img = reshape(typecast(mmc.getImage() ,imgType),w,h)';
    %             figure();imagesc(img);colormap gray;axis off;axis image;
    
    %% Autofocus at the current FOV
    cprintf('*red','Autofocusing...\n')
    [normVar, ZOffset(i)] = autoFocus(mmc,gui);
    axes(status_Plot(3));plot(normVar,'b.');
    title(['Scan Position ' num2str(i) ' Focus Curve']);
    %     w = mmc.getImageWidth();
    %     h = mmc.getImageHeight();
    %     snapIm = reshape(typecast(mmc.getImage() ,imgType),w,h)';
    %     axes(status_Plot(1));imagesc(snapIm);colormap gray; axis image;axis off;
    %     title(['Scan Position ' num2str(i) ' Autofocus Snap']);
    
    %% Now snap a BF followed by a fluorescence image
    %First set acquisition parameters to make sure the images come out
    %correctly
    mmc.setProperty('Zyla', 'Binning', '1x1')
    mmc.setProperty('ScopeLED','ActiveColor','Red');
    mmc.setProperty('ScopeLED','IntensityRed',1);
    mmc.setProperty('Zyla', 'AcquisitionWindow','2048x2048');

    cprintf('*blue','Acquiring parallel images...\n')
    imstack = acquireParallelFast(mmc,gui,drkfield,correction_Im,correction_Im_FL);
%     gui.closeAllAcquisitions();
    
    %Here are plots to show the latest captured image
    axes(status_Plot(4));imagesc(imresize(imstack(:,:,1),0.25));colormap gray;
    title(['Scan Position ' num2str(i) ' BF']);axis image;axis off;
    axes(status_Plot(5));imagesc(imresize(imstack(:,:,2),0.25));colormap gray;
    title(['Scan Position ' num2str(i) ' FL']);axis image;axis off;
    
    %Now show the worms that are extracted
    cprintf('black','Analyzing images...\n');
    [cropped, CC] = extractWorms(imstack(:,:,1),imstack(:,:,2),0.5);
    %         worm_Ims = [worm_Ims cropped];
    %         worm_FOVNum = [worm_FOVNum ones(1,numel(cropped))*i];
    
    %Here are plots to show the worms identified in the last image
    labeled = labelmatrix(CC);
    RGB_label = label2rgb(labeled,@jet,'k','shuffle');
    axes(status_Plot(6));imshow(imresize(RGB_label,4));axis image;axis off;
    title(['Scan Position ' num2str(i) ' ID worms']);axis image;
    
    %Now we send the worm images to have their features extracted
    %         res = zeros(numel(cropped),5);
    %         for i = 1:numel(cropped)
    %             res(i,:) = extractFeatures(cropped{i},regionprops(CC,'Area'));
    %         end
    %         res
    
    %And classify the worms based on the extracted features
    %         class = svmClassify(svmModel, res);
    
    %And finally we photoactivate the worms we wish to keep
    %         for i = 1:numel(class)
    %             if class(i) == 1
    %                 photoactivate()
    %             end
    %         end
    
%     Once we have analyzed the worm images we no longer need them so we
%     wipe the images from memory
%     worm_Ims = cell(0);
%     worm_FOVNum = [];
end
% for i = 1:numel(worm_Ims)
%     figure();imagesc(worm_Ims{i});colormap gray;
%     title(['Worm ' num2str(i) ' in FOV number ' num2str(worm_FOVNum(i))]);
% end

%% Some debugging code
% gui.enableLiveMode(0);
% w = mmc.getImageWidth();
% h = mmc.getImageHeight();
% bd = mmc.getImageBitDepth();
% if (bd>8)
%     imgType='uint16';
% else
%     imgType='uint8';
% end
% mmc.snapImage();
% img = double(reshape(typecast(mmc.getImage() ,imgType),w,h)');
% img = (img - drkfield) ./ correction_Im_FL;
% figure();imagesc(img);colormap gray;axis image;axis off;
% temp = reshape(img,1,numel(img));
% var_Blank = [var_Blank var(temp)]
% med_Blank = [med_Blank median(temp)]
% gui.enableLiveMode(1);