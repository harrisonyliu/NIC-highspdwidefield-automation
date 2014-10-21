for i = 2:2:numel(xPositions)
    if isnan(stageZ(yPositions(i),xPositions(i))) == 0
        right = bleh(yPositions(i),xPositions(i)+1);
        left = bleh(yPositions(i),xPositions(i)-1);
        up = bleh(yPositions(i)+1,xPositions(i));
        down = bleh(yPositions(i)-1,xPositions(i));
        neighbors = [right, left, up, down];
        neighbors(neighbors == 0) = [];
        neighbors(isnan(neighbors)) = [];
        bleh(yPositions(i),xPositions(i)) = mean(neighbors);
    end
end