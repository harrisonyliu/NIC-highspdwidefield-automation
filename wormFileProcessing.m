close all

%% Reading in images for analysis
root = 'E:\Harrison';
w = 2048;
h = 2048;
D = dir(root);
imstack = cell(1,numel(D)-2);
for i = 3:numel(D)
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