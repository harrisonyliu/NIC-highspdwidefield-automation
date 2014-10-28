function imstack = acquireParallel(mmc,gui,drkfield,correction_Im,correction_Im_FL)
%This function will take a full resolution image of the current FOV. It
%will take one BF and one fluorescence image and save the images.
w = mmc.getImageWidth();
h = mmc.getImageHeight();

%Acquire the image and save it to a file
cprintf('blue','Imaging: Acquiring images...');

%Take a brightfield image
mmc.setShutterDevice('ScopeLED');
mmc.setExposure(30);
mmc.snapImage();
BF_temp = mmc.getImage();

%Take a fluorescence image
mmc.setShutterDevice('Spectra');
mmc.setExposure(100);
mmc.snapImage();
FL_temp = mmc.getImage();

%Prepare images for further analysis
BF = single(reshape(typecast(BF_temp ,'uint16'),w,h)');
FL = single(reshape(typecast(FL_temp ,'uint16'),w,h)');

%Do some flatfield correction
BF = (BF - drkfield) ./ correction_Im;
FL = (FL - drkfield) ./ correction_Im_FL;

%Now return the result
imstack = zeros(w,h,2);
imstack(:,:,1) = BF;
imstack(:,:,2) = FL;