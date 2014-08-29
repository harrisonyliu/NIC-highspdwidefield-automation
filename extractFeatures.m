function res = extractFeatures(im, total_area)
% Features that are used: 1. % of fluorescent pixels that are in puncta, 2. % of worm
% that is fluorescent, 3. % of pixels that are fluorescent and above a
% threshold, 4. normalized variance of the image, 5. gradient magnitude of
% the image normalized by total fluorescent area.
res = zeros(1,5);
thresh = graythresh(im);
fl_area = pixAboveThresh(thresh);
res(1) = log(extractPuncta() / fl_area);
res(2) = fl_area / total_area;
res(3) = log(pixAboveThresh(2*thresh) / fl_area);
res(4) = imVar();
res(5) = log(normGradMag());

%% Start the feature extraction functions here:
    function [numPuncta,filtIm] = extractPuncta()
        %This will filter the image with a bandpass Gaussian filter to
        %extract puncta
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
        figure();imshowpair(im,filtIm,'montage');title('Original          Filtered');
%         figure();imagesc(highFilt);colormap gray;
%         figure();imagesc(lowFilt);colormap gray;
        numPuncta = sum(sum(filtIm));
    end

    function numPix = pixAboveThresh(threshold)
        %This will calculate the number of pixels above a threshold as determined
        %via Otsu's method.
        im_temp = im ./ max(max(im));
        numPix = numel(find(im_temp > threshold));
        im_temp(im_temp < threshold) = 0;
%         figure();imshowpair(im,im_temp,'montage');
    end

    function res = normGradMag()
        %This function will find the summed gradient magnitude of the entire
        %image divide it by the total fluorescent area.
        grad_temp = sum(sum(imgradient(im)));
        res = grad_temp / fl_area;
    end

    function res = imVar()
        %This function will return the variance of the image normalized by
        %the mean intensity of the image
        im_temp = reshape(im,1,numel(im));
        res = var(im_temp) / mean(im_temp);
    end
end