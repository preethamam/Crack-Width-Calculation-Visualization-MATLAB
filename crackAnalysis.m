function [bresenham_cell, row, col, idx, Orientations, Onormal90, Onormal270, OnrOrient, OncOrient, ...
    Onr90, Onc90, Onr270, Onc270, crackWidthscaled, crackLengthscaled, minCrackWidth, maxCrackWidth, ...
    averageCrackWidth, stdCrackWidth, RMSCrackWidth] = crackAnalysis(binaryCrack, binarySkeleton,skelOrientBlockSize, ...
    pixelScale, movWindowSize)


    % Calculate skeleton orientations
    Orientations = skeletonOrientation(binarySkeleton,skelOrientBlockSize); %5x5 box
    Onormal90 = binarySkeleton .* (Orientations + 90); %easier to view normals
    Onormal270 = binarySkeleton .*(Orientations + 270); %easier to view normals
    OnrOrient = sind(Orientations);
    OncOrient = cosd(Orientations);
    Onr90 = sind(Onormal90);   %vv
    Onc90 = cosd(Onormal90);   %uu
    Onr270 = sind(Onormal270);   %vv
    Onc270 = cosd(Onormal270);   %uu
    [row,col] = find(binarySkeleton);   %row/cols
    idx = find(binarySkeleton);     %Linear indices into Onr/Onc
    
    %% Crack width extraction
    %--------------------------------------------------------------------------
    angle_1 = Onormal90(idx);
    angle_2 = Onormal270(idx);
    mycell = cell(2,numel(row));
    XYBresenham = zeros(numel(angle_1),4);
    
    for i=1:numel(row)
        mycell{1,i} = crackWidthLocation(col(i),row(i),angle_1(i),binaryCrack);
        mycell{2,i} = crackWidthLocation(col(i),row(i),angle_2(i),binaryCrack);
        XYBresenham(i,:) = [mycell{1,i}{1,1}(end), mycell{1, i}{2, 1}(end),...
                            mycell{2,i}{1,1}(end), mycell{2, i}{2, 1}(end)];
    end
    
    %% Find the crackline coordinates
    % cell, array initialization
    bresenham_cell = cell(length(XYBresenham),2);
    crackWidth_kernel = zeros(length(XYBresenham),1);
    crackWidth_bresenham = zeros(length(XYBresenham),1);
    
    for i=1:length(XYBresenham)
        [x_bresenham, y_bresenham] = bresenham(XYBresenham(i,1), XYBresenham(i,2),...
                XYBresenham(i,3), XYBresenham(i,4));
        bresenham_cell{i,1} = x_bresenham;
        bresenham_cell{i,2} = y_bresenham;
        crackWidth_bresenham(i) = numel(x_bresenham);
    end
    
    
    %% Write output
    % Crackwidth scaled
    crackWidthscaled  = crackWidth_bresenham * pixelScale;
    crackLengthscaled = numel(idx) * pixelScale;
    
    % Moving window avaerage
    crackWidthscaled = movmean(crackWidthscaled, movWindowSize);
    
    % Statistics of crackwidth
    minCrackWidth = min(crackWidthscaled);
    maxCrackWidth = max(crackWidthscaled);
    averageCrackWidth = mean(crackWidthscaled);
    stdCrackWidth = std(crackWidthscaled);
    RMSCrackWidth = rms(crackWidthscaled);

end