time = [];
area = [];
for i = 8:15
    fname_BF = ['30-Oct-2014_BF_' num2str(i) '.png'];
    dname_BF = 'F:\2014.10.30 Worm Imaging\lipl4\BF';
    fname_FL = ['30-Oct-2014_FL_' num2str(i) '.png'];
    dname_FL = 'F:\2014.10.30 Worm Imaging\lipl4\FL';
    
    full_BF = fullfile(dname_BF,fname_BF);
    full_FL = fullfile(dname_FL,fname_FL);
    BF = imread(full_BF);
    FL = imread(full_FL);
    
    tic
    [cropped, CC] = extractWorms(BF,FL,0.5);
    props = regionprops(CC,'Area');
    temp = [props.Area];
    area = [area, temp];
    time(end+1) = toc;
    labeled = labelmatrix(CC);
    RGB_label = label2rgb(labeled,@jet,'k','shuffle');
    figure();imshow(imresize(RGB_label,4));axis image;axis off;
    title(['Scan Position ' num2str(i) ' ID worms']);
    figure();imagesc(BF);colormap gray;axis image;
end