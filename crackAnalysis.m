function [bresenham_cell, row, col, idx, Orientations, Onormal90, Onormal270, OnrOrient, OncOrient, ...
    Onr90, Onc90, Onr270, Onc270, crackWidthscaled, crackLengthscaled, minCrackWidth, maxCrackWidth, ...
    averageCrackWidth, stdCrackWidth, RMSCrackWidth] = crackAnalysis(binaryCrack, binarySkeleton, skelOrientBlockSize, ...
    pixelScale, movWindowSize, movWindowType)
% CRACKANALYSIS Analyzes crack geometry in a binary image.
%
% Inputs:
%   binaryCrack          - Binary image where cracks are foreground (1) and background is 0.
%   binarySkeleton       - Binary image of skeletonized cracks (one-pixel-wide representation).
%   skelOrientBlockSize  - Block size for local orientation computation (e.g., 5 for a 5x5 neighborhood).
%   pixelScale           - Scaling factor to convert pixel measurements to real-world units (e.g., mm/pixel).
%   movWindowSize        - Window size for moving average filter applied to crack width.
%
% Outputs:
%   bresenham_cell       - Cell array with Bresenham line coordinates (x and y) for crack width calculation.
%   row                  - Row indices of skeleton points in the binarySkeleton image.
%   col                  - Column indices of skeleton points in the binarySkeleton image.
%   idx                  - Linear indices of skeleton points in the binarySkeleton image.
%   Orientations         - Matrix of local orientations (in degrees) for the skeletonized cracks.
%   Onormal90            - Orientations rotated by 90 degrees, scaled by binarySkeleton for easier visualization.
%   Onormal270           - Orientations rotated by 270 degrees, scaled by binarySkeleton for easier visualization.
%   OnrOrient            - Sine values of the skeleton orientations.
%   OncOrient            - Cosine values of the skeleton orientations.
%   Onr90                - Sine values of orientations rotated by 90 degrees.
%   Onc90                - Cosine values of orientations rotated by 90 degrees.
%   Onr270               - Sine values of orientations rotated by 270 degrees.
%   Onc270               - Cosine values of orientations rotated by 270 degrees.
%   crackWidthscaled     - Vector of crack widths at skeleton points, scaled to real-world units.
%   crackLengthscaled    - Total length of the crack, scaled to real-world units.
%   minCrackWidth        - Minimum measured crack width, scaled to real-world units.
%   maxCrackWidth        - Maximum measured crack width, scaled to real-world units.
%   averageCrackWidth    - Average crack width, scaled to real-world units.
%   stdCrackWidth        - Standard deviation of the crack widths, scaled to real-world units.
%   RMSCrackWidth        - Root mean square (RMS) of crack widths, scaled to real-world units.
%
% This function computes crack width and length, extracts skeleton orientations,
% and provides statistical analysis of crack geometry.


    % Calculate skeleton orientations
    Orientations = skeletonOrientation(binarySkeleton, skelOrientBlockSize); % Calculate orientations in a block size
    Onormal90 = binarySkeleton .* (Orientations + 90); % Orientations rotated by 90 degrees for visualization
    Onormal270 = binarySkeleton .* (Orientations + 270); % Orientations rotated by 270 degrees for visualization
    OnrOrient = sind(Orientations); % Sine of skeleton orientations
    OncOrient = cosd(Orientations); % Cosine of skeleton orientations
    Onr90 = sind(Onormal90); % Sine of orientations rotated by 90 degrees
    Onc90 = cosd(Onormal90); % Cosine of orientations rotated by 90 degrees
    Onr270 = sind(Onormal270); % Sine of orientations rotated by 270 degrees
    Onc270 = cosd(Onormal270); % Cosine of orientations rotated by 270 degrees
    [row, col] = find(binarySkeleton); % Get row and column indices of skeleton pixels
    idx = find(binarySkeleton); % Get linear indices of skeleton pixels

    %% Crack width extraction
    %----------------------------------------------------------------------
    % Initialize variables for crack width analysis
    angle_1 = Onormal90(idx); % Extract angles rotated by 90 degrees
    angle_2 = Onormal270(idx); % Extract angles rotated by 270 degrees
    mycell = cell(2, numel(row)); % Cell to store crack width locations
    XYBresenham = zeros(numel(angle_1), 4); % Array to store Bresenham line coordinates

    % Loop through each skeleton pixel to determine crack width locations
    for i = 1:numel(row)
        % Get crack width points along the 90-degree orientation
        mycell{1, i} = crackWidthLocation(col(i), row(i), angle_1(i), binaryCrack);
        % Get crack width points along the 270-degree orientation
        mycell{2, i} = crackWidthLocation(col(i), row(i), angle_2(i), binaryCrack);
        % Store endpoints for Bresenham line drawing
        XYBresenham(i, :) = [mycell{1, i}{1, 1}(end), mycell{1, i}{2, 1}(end), ...
                             mycell{2, i}{1, 1}(end), mycell{2, i}{2, 1}(end)];
    end

    %% Find the crackline coordinates
    % Initialize cell and arrays to store Bresenham line coordinates and crack widths
    bresenham_cell = cell(length(XYBresenham), 2); % Cell to store Bresenham lines
    crackWidth_kernel = zeros(length(XYBresenham), 1); % Array to store crack width (not used further)
    crackWidth_bresenham = zeros(length(XYBresenham), 1); % Array to store crack width based on Bresenham lines

    % Loop through each line to calculate Bresenham line coordinates
    for i = 1:length(XYBresenham)
        % Compute Bresenham line coordinates
        [x_bresenham, y_bresenham] = bresenham(XYBresenham(i, 1), XYBresenham(i, 2), ...
                                               XYBresenham(i, 3), XYBresenham(i, 4));
        % Store Bresenham line coordinates in the cell
        bresenham_cell{i, 1} = x_bresenham;
        bresenham_cell{i, 2} = y_bresenham;
        % Compute crack width as the number of points on the Bresenham line
        crackWidth_bresenham(i) = numel(x_bresenham);
    end

    %% Write output
    % Crack width and length scaled by pixel size
    crackWidthscaled = crackWidth_bresenham * pixelScale; % Scale crack widths to real-world units
    crackLengthscaled = numel(idx) * pixelScale; % Scale crack length to real-world units

    % Smooth crack width using a moving average
    if strcmp(movWindowType,'mean')
        crackWidthscaled = movmean(crackWidthscaled, movWindowSize); % Apply moving window averaging
    else
        crackWidthscaled = movmedian(crackWidthscaled, movWindowSize); % Apply moving window averaging
    end

    % Calculate statistics of crack width
    minCrackWidth = min(crackWidthscaled); % Minimum crack width
    maxCrackWidth = max(crackWidthscaled); % Maximum crack width
    averageCrackWidth = mean(crackWidthscaled); % Average crack width
    stdCrackWidth = std(crackWidthscaled); % Standard deviation of crack width
    RMSCrackWidth = rms(crackWidthscaled); % Root mean square of crack width

end
