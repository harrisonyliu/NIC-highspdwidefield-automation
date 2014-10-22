function [xPositions, yPositions, rows, cols, stageZ, M] = createRoundGridSpiral()
%% Petri Dish Scanning - this will create a raster scan pattern of a petri dish, simply give the function the center of the stage, the size of the petri dish, and how much trim you want at the edges
%For conventions sake all coordinates are listed here in Cartesian
%coordinates (X,Y) rather than Matlab coordinates (Y,X)

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
stageX = X; stageY = Y;
%Move everything from being centered at (0,0) to centered at (homeX, homeY)
stageX = stageX + homeX; stageY = stageY + homeY;rows = rows + homeY;cols = cols + homeX;
%We will proceed by analyzing each column of positions and asking whether
%those positions fall within the petri dish. We will save each set of
%columns under one entry in the cell "X_columns" and "Y_columns"
petri_Radius = petriDiam/2 - trim_amount*sqrt(fovW^2 + fovH^2);

for j = 1:size(X,2)
    for i = 1:size(X,1)
        if sqrt((X(i,j))^2 + (Y(i,j))^2) > petri_Radius
            stageX(i,j) = NaN;
            stageY(i,j) = NaN;
        end
    end
end

%Find the total number of positions to scan through
numFOVs = numel(X) - sum(sum(isnan(stageX)));

%Now to create the final list of positions to scan through
xPositions = zeros(size(X,1),1);
yPositions = zeros(size(Y,1),1);
currentXidx = round(size(X,2)/2);
currentYidx = round(size(Y,1)/2);
xPositions(1) = currentXidx;;
yPositions(1) = currentYidx;
direction = 'up';
dir_Array = [{'up'}, {'left'}, {'down'}, {'right'}];
directionIdx = 0; %Check how many times directions have changed. After changing direction twice, have to travel one additional FOV in the next direction
numSteps = 1; %For the directon we are traveling, how many FOVs to travel
idx = 1; %Keeps track which position to add next to x and yPositions
FOVidx = 1;

%Change direction twice, then add one more element to the number of steps
%going in one direction and repeat until all FOVs are traveled.
while FOVidx < numel(X);
    if directionIdx < 2
        directionIdx = directionIdx + 1;
        [xPositions, yPositions, idx] = travelCurrentDirection(direction,...
            numSteps,xPositions,yPositions,idx);
        %Now change direction
        next_Direction = find(strcmp(direction,dir_Array) == 1) + 1;
        if next_Direction == 5
            direction = 'up';
        else
            direction = dir_Array(next_Direction);
        end
    else
        directionIdx = 0;
        numSteps = numSteps + 1;
    end
end

%zPositions will keep track of the ZOffset for each location on the plate
stageZ = stageX;
stageZ(find(stageX > 0)) = 0; stageZ(find(stageX < 0)) = 0;
save('50mm_plate_raster_scan_positions_4x_spiral.mat','xPositions','yPositions','rows','cols', 'stageZ','stageX','stageY');

%% Debugging section, comment out otherwise
% figure();plot(stageY,stageX,'b.');title('Round Grid Creation');
figure();plot(stageY,stageX,'b.');title('Spiral Scan Animation');
hold on;
plot(homeY,homeX,'go');
title(['Spiral Plate Scan: ' num2str(numFOVs) ' FOVs']);
vidObj = VideoWriter('GridScanAnimation.avi');
vidObj.FrameRate = 15;
open(vidObj);
for i = 1:numel(xPositions)
    if isnan(stageX(yPositions(i),xPositions(i))) == 0
        plot(rows(yPositions(i)),cols(xPositions(i)),'r*');
        M(i) = getframe;
        pause(1/30);
    end
end
% writeVideo(vidObj,M);


%% Functions used to create grid

    function [xPositions, yPositions,idx] = travelCurrentDirection(direction,numSteps,xPositions,yPositions,idx)
        numSteps = min(numSteps,size(X,1)-1);
        for k = 1:numSteps
            if strcmp(direction,'up') == 1
                currentYidx = currentYidx + 1;
                idx = idx + 1;
            elseif strcmp(direction,'left') == 1
                currentXidx = currentXidx - 1;
                idx = idx + 1;
            elseif strcmp(direction,'down') == 1
                currentYidx = currentYidx - 1;
                idx = idx + 1;
            elseif strcmp(direction,'right') == 1
                currentXidx = currentXidx + 1;
                idx = idx + 1;
            end
            xPositions(idx) = currentXidx;
            yPositions(idx) = currentYidx;
            FOVidx = FOVidx + 1;
        end
    end
end