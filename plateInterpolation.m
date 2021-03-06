%Radial average from each point

%% Input parameters
%Center of the dish at location [-12500, 8500] (units are in um)
homeX = 9800;
homeY = -3800;
% w = mmc.getImageWidth();
% h = mmc.getImageHeight();

w = 2048;
h = 2048;
%Petri dish dimensions, assume it's round, units in um
petriDiam = 50000;
%How many fields of view to trim around the borders of the petri dish to
%ensure that edge effects are not captured. MUST BE AN INTEGER AMOUNT!!!
trim_amount = 2;

%% Now to create the raster scan pattern, we assume home is at (0,0) for now
% pixSize = mmc.getPixelSizeUm();
pixSize = 1.6125;
fovW = pixSize * w;
fovH = pixSize * h;
%Find out how many fields of view in the x direction
numFovW = floor(petriDiam / fovW);
numFovH = floor(petriDiam / fovH);
%We now create a square grid centered at (0,0), taking into account how
%many fields of view we have to work with.
if rem(numFovW,2) == 0
    left = (numFovW/2-0.5)*fovW;
else
    left = floor(numFovW/2)*fovW;
end
if rem(numFovH,2) == 0
    bottom = (numFovH/2-0.5)*fovH;
else
    bottom = floor(numFovH/2)*fovH;
end
cols = -left:fovW:left;
rows = -bottom:fovW:bottom;
%Now calculate the x and y positions of the resultant (square) grid
[X, Y] = meshgrid(rows,cols);
%We will proceed by analyzing each column of positions and asking whether
%those positions fall within the petri dish. We will save each set of
%columns under one entry in the cell "X_columns" and "Y_columns"
petri_Radius = petriDiam/2 - trim_amount*sqrt(fovW^2 + fovH^2);

for j = 1:size(X,2)
    for i = 1:size(X,1)
        if sqrt((X(i,j))^2 + (Y(i,j))^2) > petri_Radius
            X(i,j) = NaN;
            Y(i,j) = NaN;
        end
        %         tempX = X(:,j);
        %         X_columns{j} = tempX(isnan(tempX)==0)+homeX;
        %         tempY = Y(:,j);
        %         Y_columns{j} = tempY(isnan(tempY)==0)+homeY;
    end
end
%Move everything from being centered at (0,0) to centered at (homeX, homeY)
X = X + homeX;
Y = Y + homeY;

%Find the total number of positions to scan through
numFOVs = numel(X) - sum(sum(isnan(X)));
load('Zpositions50mmplate.mat');
[xPositions, yPositions, M] = createRoundGridSpiral();

%% Creating heat maps for verification and debugging

%% Create interpolated grid from plate mapping data
%Assume that the recorded z-positions are in an array called fastPlateZ
%which is approximately half the size of xPositions
interpolatedZ = nan(size(xPositions));
fastPlateZ = ZOffset(1:2:end);
interpolatedZ(1:2:end) = fastPlateZ;
trimmedX = xPositions(1:2:end);
trimmedY = yPositions(1:2:end);

for i = 1:numel(interpolatedZ)
    if isnan(interpolatedZ(i)) == 1
        deltaX = xPositions(i) - trimmedX;
        deltaY = yPositions(i) - trimmedY;
        distanceArr = 1./(deltaX.^2 + deltaY.^2);
        interpolatedZ(i) = sum((distanceArr) .* fastPlateZ') / sum(distanceArr);
    end
end

Z = nan(size(X));
centerX = round(size(X,2)/2);
centerY = round(size(Y,1)/2);
% figure();hold on;
% [testX, testY] = meshgrid([4:12],[4:12]);
% plot(testX,testY,'b.');
testMap = nan(size(X));
distanceArr = distanceArr./max(distanceArr);
ROI = 1;

for i = 1:numel(distanceArr)
    xCoord = find(X(centerX,:) == trimmedX(i));
    yCoord = find(Y(:,centerY) == trimmedY(i));
    testMap(yCoord,xCoord) = distanceArr(i);
    if i == ROI
        ROIx = xCoord;
        ROIy = yCoord;
    end
%     plot(yCoord,xCoord,'r*');
end

% hmo = HeatMap(testMap);plot(hmo);hold on;plot(ROIy,ROIx,'bo')
