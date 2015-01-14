function res = wormFeatureProcessing(im_in_cells)
%This function will take in a 1xn cell in which each entry is an image of
%one worm and extract features from it
numFeats = 5;
res = zeros(numel(im_in_cells),numFeats);

for i = 1:numel(im_in_cells)
    temp = im_in_cells{i};
    im_normalized = temp ./ max(max(temp));
    area = numel(find(im_normalized)); %Area of worm = all nonzero elements
    res(i,:) = extractFeatures(im_normalized,area);
end