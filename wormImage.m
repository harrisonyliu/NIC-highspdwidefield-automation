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
% mmc.snapImage();
% img = reshape(typecast(mmc.getImage() ,imgType),w,h)';

%% Initiate default scope parameters
mmc.setFocusDevice('ZStage'); %Piezo
%Here we prepare the autofocus image acquisition parameters. We set binning
%to 4, prepare the exposure and set up the Cy3-BF imaging filters and LEDs
mmc.setProperty('Zyla', 'Binning', '1x1')
mmc.setProperty('ScopeLED','ActiveColor','Red');
mmc.setProperty('ScopeLED','IntensityRed',2);
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

%% Generate a list of positions on the plate to image
% [xPositions, yPositions] = createRoundGrid(mmc);
% load('test_plate_raster_scan_positions.mat','xPositions','yPositions');
load('50mm_plate_raster_scan_positions_spiral.mat');
tot_Positions = numel(xPositions);
worm_Ims = cell(0);
worm_FOVNum = [];
figure(1);status_Plot = tight_subplot(2,3,[.05 .01],[.01 .05],[.01 .01]);
set(figure(1),'WindowStyle','docked');

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
    %First we wish to see if there is a worm in the FOV that we can focus
    %on. We snap a fluorescence image and see if a worm exists.
    mmc.setProperty('Zyla','Exposure',150);
    mmc.setProperty('Core','Shutter','ESIOShutter');
    mmc.snapImage();
    w = mmc.getImageWidth();
    h = mmc.getImageHeight();
    snapIm = reshape(typecast(mmc.getImage() ,imgType),w,h)';
    axes(status_Plot(1));imagesc(snapIm);colormap gray; axis image;axis off;
    title(['Scan Position ' num2str(i) ' Autofocus Snap']);
    thresh = 60;
    %We take the variance normalized by the median (background) to see if a
    %worm exists
    temp = double(reshape(snapIm,1,numel(snapIm)));
    snapIm_Val = var(temp) / median(temp);
    if snapIm_Val > thresh
        %A worm exists so we now autofocus
        [normVar, focusSuccess_Bool] = autoFocus(mmc,gui,0.25,correction_Im);
        axes(status_Plot(3));plot(normVar,'b--');
        title(['Scan Position ' num2str(i) ' Focus Curve']);
        %Tell the program to snap an image if a worm exists in the FOV AND
        %the autofocus algorithm was successful.
        if focusSuccess_Bool == 1
            wormBool = 1;
        else
            wormBool = 0;
        end
    else
        %No worm so we quit the program early and move on
        cprintf('*red','Autofocus: No worms detected, moving to next FOV\n')
        wormBool = 0;
    end
    
    %% Now snap a BF followed by a fluorescence image
    if wormBool == 1
        cprintf('*blue','Acquiring parallel images...\n')
        imstack = acquireParallel(mmc,gui,drkfield,correction_Im,correction_Im_FL);
        gui.closeAllAcquisitions();
        
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
        
        %         %Now we send the worm images to have their features extracted
        %         res = zeros(numel(worm_Ims),5);
        %         for i = 1:numel(worm_Ims)
        %             res(i,:) = extractFeatures(wormIms{i},regionprops(CC,'Area'));
        %         end
        %
        %         %And classify the worms based on the extracted features
        %
        %         %And finally we photoactivate the worms we wish to keep
        
    end
    
    %         Once we have analyzed the worm images we no longer need them so we
    %         wipe the images from memory
    worm_Ims = cell(0);
    worm_FOVNum = [];
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