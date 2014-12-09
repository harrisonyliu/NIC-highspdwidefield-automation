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
    photoactivate(mmc,gui,pp,ROImgr,boundingboxes)
end

mmc.setShutterDevice('ScopeLED');
mmc.setExposure(30);
gui.enableLiveMode(1);