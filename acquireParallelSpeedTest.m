w = mmc.getImageWidth();
h = mmc.getImageHeight();
mmc.set

%Acquire the image and save it to a file
cprintf('blue','Imaging: Acquiring images by loading acquisition');
tic
gui.loadAcquisition('C:\Users\nicuser\Desktop\cy3-BF-Acq-Parallel');
acqName = gui.runAcquisition();
imgCache = gui.getAcquisitionImageCache(acqName);
numSlices = gui.getAcquisitionSettings.channels.size;
imstack = zeros(w,h,numSlices);

% Retrieve a "tagged image" from the cache:
for i = 0:numSlices-1
    ti = imgCache.getImage(i,0,0,0);
    % ti = imgCache.getImage(chanIdx, sliceIdx, frameIdx, posIdx);
    % (Indices count from zero.)
    pixelType = ti.tags.get('PixelType');
    if strcmp(pixelType, 'GRAY16')
        matlabType = 'uint16';
    else
        matlabType = 'uint8';
    end
    img = typecast(ti.pix, matlabType);   % pixels must be interpreted as unsigned integers
    img = reshape(img, [w, h]); % image should be interpreted as a 2D array
    imstack(:,:,i+1) = transpose(double(img));  % make column-major order for MATLAB
end
toc

cprintf('red','Imaging: Acquiring images by direct Matlab control');
tic
%Take a brightfield image
mmc.setShutterDevice('ScopeLED');
mmc.setExposure(15);
mmc.snapImage();
BF_temp = mmc.getImage();

%Take a fluorescence image
mmc.setShutterDevice('ESIOShutter');
mmc.setExposure(100);
mmc.snapImage();
FL_temp = mmc.getImage();

BF = reshape(typecast(BF_temp ,'uint16'),w,h)';
FL = reshape(typecast(FL_temp ,'uint16'),w,h)';
toc
figure();imshowpair(BF,FL,'montage');colormap gray;axis image;axis off;
