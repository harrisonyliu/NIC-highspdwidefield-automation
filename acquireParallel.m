function imstack = acquireParallel(mmc,gui)
%This function will take a full resolution image of the current FOV. It
%will take one BF and one fluorescence image and save the images.
w = mmc.getImageWidth();
h = mmc.getImageHeight();

%Acquire the image and save it to a file
cprintf('blue','Imaging: Acquiring images');
gui.loadAcquisition('C:\Users\nicuser\Desktop\cy3-BF-Acq-Parallel');
acqName = gui.runAcquisition();
cprintf('blue','Imaging: Images acquired, reading into Matlab...\n');
imgCache = gui.getAcquisitionImageCache(acqName);
numSlices = gui.getAcquisitionSettings.channels.size;
imstack = zeros(w,h,numSlices);

% Retrieve a "tagged image" from the cache:
for i = 0:numSlices-1
    ti = imgCache.getImage(i,0,0,0);
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
    imstack(:,:,i+1) = transpose(img);  % make column-major order for MATLAB
%     figure();imagesc(transpose(img));colormap gray;
end