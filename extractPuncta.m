function [numPuncta,filtIm] = extractPuncta(im)

high = fspecial('Gaussian',5,1);
low = fspecial('Gaussian',13,2);

%Highpass filter: will smooth the image a little to remove pixel noise,
%puncta are not affected much
%Lowpass filter: will smooth the image even more to remove low frequency
%noise
highFilt = conv2(im,high,'same');
lowFilt = conv2(im,low,'same');
filtIm = highFilt - lowFilt;
filtIm(filtIm < 0) = 0;
% figure();imshowpair(im,filtIm,'montage');title('Original          Filtered');
numPuncta = sum(sum(filtIm));