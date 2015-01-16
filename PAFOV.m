mmc.setProperty('Zyla', 'Binning', '1x1')
mmc.setProperty('ScopeLED','ActiveColor','Red');
mmc.setProperty('ScopeLED','IntensityRed',1);
mmc.setProperty('Zyla', 'AcquisitionWindow','2048x2048');
mmc.setFocusDevice('TIZDrive');
counter = 1; %This keeps track of what FOV we are currently in
temp = 0;
gui.enableLiveMode(1);%Initialize the live window and ROI manager for tracking photoactivation.
% ROImgr.runCommand('Show All');
gui.enableLiveMode(0);

gui.enableLiveMode(0);
cprintf('*blue','Acquiring parallel images...\n')
imstack = acquireParallelFast(mmc,gui,drkfield,correction_Im,correction_Im_FL);

%Here are plots to show the latest captured image
axes(status_Plot(4));imagesc(imresize(imstack(:,:,1),0.25));colormap gray;
title(['Scan Position ' num2str(counter) ' BF']);axis image;axis off;
axes(status_Plot(5));imagesc(imresize(imstack(:,:,2),0.25));colormap gray;
title(['Scan Position ' num2str(counter) ' FL']);axis image;axis off;

%Now show the worms that are extracted
cprintf('black','Analyzing images...\n');
[cropped, CC] = extractWorms(imstack(:,:,1),imstack(:,:,2),0.5);

%Here are plots to show the worms identified in the last image
labeled = labelmatrix(CC);
RGB_label = label2rgb(labeled,@jet,'k','shuffle');
axes(status_Plot(6));imshow(imresize(RGB_label,4));axis image;axis off;
title(['Scan Position ' num2str(i) ' ID worms']);axis image;

boundingboxes = regionprops(CC,'BoundingBox');
if numel(boundingboxes) > 0
    photoactivate(mmc,gui,pp,boundingboxes)
end

gui.enableLiveMode(1);
mmc.setShutterDevice('ScopeLED');
mmc.setExposure(30);