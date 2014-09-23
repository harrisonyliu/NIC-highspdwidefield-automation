function [xPositions yPositions] = createRoundGrid(mmc)
%% Petri Dish Scanning - this will create a raster scan pattern of a petri dish, simply give the function the center of the stage, the size of the petri dish, and how much trim you want at the edges

%% Input parameters
%Center of the dish at location [-12500, 8500] (units are in um)
homeX = -12500;
homeY = 8500;
w = mmc.getImageWidth();
h = mmc.getImageHeight();
% w = 2048;
% h = 2048;
%Petri dish dimensions, assume it's round, units in um
petriDiam = 50000;
%How many fields of view to trim around the borders of the petri dish to
%ensure that edge effects are not captured. MUST BE AN INTEGER AMOUNT!!!
trim_amount = 3;

%% Now to create the raster scan pattern, we assume home is at (0,0) for now
pixSize = mmc.getPixelSizeUm();
% pixSize = 1.6125;
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
[X Y] = meshgrid(rows,cols);
%We will proceed by analyzing each column of positions and asking whether
%those positions fall within the petri dish. We will save each set of
%columns under one entry in the cell "X_columns" and "Y_columns"
X_columns = cell(1,size(X,2));
Y_columns = cell(1,size(X,2));

for j = 1:size(X,2) 
    for i = 1:size(X,1)
        if sqrt((X(i,j))^2 + (Y(i,j))^2) > petriDiam/2 - trim_amount*sqrt(fovW^2 + fovH^2)
            X(i,j) = NaN;
            Y(i,j) = NaN;
        end
        tempX = X(:,j);
        X_columns{j} = tempX(isnan(tempX)==0)+homeX;
        tempY = Y(:,j);
        Y_columns{j} = tempY(isnan(tempY)==0)+homeY;
    end
end

%Find the total number of positions to scan through
numFOVs = 0;
for i = 1:numel(X_columns)
    numFOVs = numFOVs + numel(X_columns{i});
end

%Now to create the final list of positions to scan through
xPositions = zeros(numFOVs,1);
yPositions = zeros(numFOVs,1);
nonEmpty = find(~cellfun(@isempty,X_columns));
idx = 1;
xPositions(idx:idx + numel(X_columns{nonEmpty(1)})-1) = X_columns{nonEmpty(1)};
yPositions(idx:idx + numel(Y_columns{nonEmpty(1)})-1) = Y_columns{nonEmpty(1)};
idx = idx + numel(X_columns{nonEmpty(1)});

for i = 2:numel(nonEmpty)
    start_distance = (X_columns{nonEmpty(i)}(1) - xPositions(idx-1))^2 + ...
        (Y_columns{nonEmpty(i)}(1) - yPositions(idx-1))^2;
    end_distance =  (X_columns{nonEmpty(i)}(end) - xPositions(idx-1))^2 + ...
        (Y_columns{nonEmpty(i)}(end) - yPositions(idx-1))^2;
    if end_distance < start_distance
        X_columns{nonEmpty(i)} = flipud(X_columns{nonEmpty(i)});
        Y_columns{nonEmpty(i)} = flipud(Y_columns{nonEmpty(i)});
    end
    xPositions(idx:idx + numel(X_columns{nonEmpty(i)})-1) = X_columns{nonEmpty(i)};
    yPositions(idx:idx + numel(Y_columns{nonEmpty(i)})-1) = Y_columns{nonEmpty(i)};
    idx = idx + numel(X_columns{nonEmpty(i)});
end

save('50mm_plate_raster_scan_positions.mat','xPositions','yPositions');

%% Debugging section, comment out otherwise
figure();plot(X,Y,'b.');title('Round Grid Creation');
figure();plot(yPositions,xPositions,'b.');title('Raster Scan Animation');
hold on;
plot(homeY,homeX,'go');
for i = 1:numel(xPositions)
    plot(yPositions(i),xPositions(i),'r*');
    pause(1/30);
end