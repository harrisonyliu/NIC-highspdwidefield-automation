function worms = wormFileProcessing(root)
%Give this function the root directory of the worm images you wish to
%analyze and it will automatically load the images, crop out the worms and
%return the result. It will also open up a GUI to browse through the worm
%images and allow images to be removed/added.

%% Reading in images for analysis
%To use this simply change the root directory to the folder that contains
%the images taken by micromanager. This assumes you used the "save as image
%stack" option and that each FOV is contained within its own folder
% root = 'E:\Harrison';
root = 'D:\2014.10.03 Worm Imaging\lipl4\First 30';
w = 2048;
h = 2048;
D = dir(root);
numIm = numel(D) - 2;
imstack = cell(1,numIm);
for i = 3:numel(D)
    cprintf('*black',['Reading image ' num2str(i-2) ' of ' num2str(numIm) '\n'])
    fname_temp = fullfile(root, D(i).name);
    imname = dir(fname_temp);
    fname = fullfile(fname_temp,imname(3).name);
    imstack{i-2} = readMicroManagerTif(fname,w,h);
%     figure();imagesc(imstack{i-2}(:,:,2));axis image;axis off;colormap gray;
end
cprintf('*red','Done loading images!\n')

%% Now extracting worms
worms = cell(0);
for i = 1:numel(imstack)
    BF = imstack{i}(:,:,1);
    FL = imstack{i}(:,:,2);
    cprintf('*black',['Image ' num2str(i) ' of ' num2str(numel(imstack)) '\n'])
    [cropped, CC] = extractWorms(BF,FL,0.5);
    worms = [worms cropped];
%     labeled = labelmatrix(CC);
%     RGB_label = label2rgb(labeled,@jet,'k','shuffle');
%     figure();imshowpair(imresize(imstack{i}(:,:,2),0.5),RGB_label,'montage');axis image;axis off;colormap gray;
%     title('Worms segmentation, image scale 50%');
end
cprintf('*red','Done extracting worms!\n')

%And now display the cropped worms
wormImageBrowser(worms);