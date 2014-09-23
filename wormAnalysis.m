close all

%% Reading in images for analysis
root = 'E:\goodworms';
w = 2048;
h = 2048;
D = dir(root);
imstack = cell(1,numel(D)-2);
for i = 3:numel(D)
    fname = fullfile(root, D(i).name);
    imstack{i-2} = readMicroManagerTif(fname,w,h);
    %     figure();imagesc(imstack{i-2}(:,:,2));axis image;axis off;colormap gray;
end

%% Now extracting worms
worms = cell(0);
for i = 1:numel(imstack)
    BF = imstack{i}(:,:,1);
    FL = imstack{i}(:,:,2);
    [cropped, CC] = extractWorms(BF,FL,0.5);
    worms = [worms cropped];
    labeled = labelmatrix(CC);
    RGB_label = label2rgb(labeled,@jet,'k','shuffle');
    figure();imshowpair(imresize(imstack{i}(:,:,2),0.5),RGB_label,'montage');axis image;axis off;colormap gray;
    title('Worms segmentation, image scale 50%');
    if i == 4
        figure();title('Cropped worm images');
        for j = 1:numel(cropped)
            subplot(2,3,j);imagesc(cropped{j});colormap gray; axis image;axis off;
        end
    end
end

% %And now display the cropped worms
% for i = 1:numel(worms)
%     figure();imagesc(worms{i});colormap gray; axis image;axis off;
% end