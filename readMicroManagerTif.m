function im_stack = readMicroManagerTif(filename,w,h,scale)

if nargin < 4
    scale = 1;
end

numIm = numel(imfinfo(filename));
im_stack = zeros(w*scale,h*scale,numIm);

for i = 1:numIm
    im_stack(:,:,i) = imresize(imread(filename,i),scale);
end