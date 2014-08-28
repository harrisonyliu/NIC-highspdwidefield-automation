function A = readMicroscopeImg(filename)

fname = filename;
info = imfinfo(fname);
info.Colormap = [];
num_images = numel(info);
A = zeros(info(1).Height,info(1).Width,num_images);
for k = 1:num_images
    A(:,:,k) = imread(fname, k,'Info',info);
end