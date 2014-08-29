function frameNum = getFocus(imgStack)
% This function receives an x by y by n image stack and will return the
% frame number with the best focus as determined by the highest normalized variance
imLinearElements = numel(imgStack(:,:,1));
numIm = size(imgStack,3);
normVar = zeros(1,numIm);

for i = 1:numIm
    temp = reshape(imgStack(:,:,i),1,imLinearElements);
    normVar(i) = var(temp)/mean(temp);
end

frameNum = find(normVar == max(normVar));