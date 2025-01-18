%//%************************************************************************%
%//%*                                                                      *%
%//%*                        Crack Width Package					       *%
%//%*                                                                      *%
%//%*             Name: Preetham Manjunatha    		                       *%
%//%*             Github link: https://github.com/preethamam               *%
%//%*             Date: 11/26/2024                                         *%
%//%************************************************************************%

clear; close all; clc;
Start = tic;

%% Inputs
%--------------------------------------------------------------------------
image = 'images/crack.bmp'; % image path/name
pixelScale = 1; % Unit scale of pixel in world units
movWindowSize = 3; % Moving window size
movWindowType = 'mean'; % 'mean': Moving mean | 'median': moving median
skelOrientBlockSize = 5; % Skeleton orientation block size
fileName2write = 'ZZZ_crackStatistics.txt'; % File to write output
crackWidthLineBackground = 'white'; % Crack background % 'white' | 'black'
crackIndex = 50; % Single crack pixel index to display
crackLineMovie = 0; % Show crack lines movie

% Image smoothing
boundary_smooth = 1; % 0 - none | 1 - morphClose | 2 - kernel
morphclose_disksize = 35; % Morphological disk size
windowSize = 25; % Kernel size

% Thining method
thinPruneMethod = 'alex';  % conventional | alex | voronoi | fast_marching
thinPruneThresh = 0.1;

%% Image I/O
binaryCrack = imread(image);

%% Folders I/O
addpath('crackprops', 'skeleton')

%% Image smoothing and skeletonizing/thining
switch boundary_smooth 
    case 1
        se = strel('disk', morphclose_disksize);
        binaryCrackSmoothed = imclose(binaryCrack,se);
    case 2
        kernel = ones(windowSize) / windowSize ^ 2;
        blurryImage = conv2(single(binaryCrack), kernel, 'same');
        binaryCrackSmoothed = blurryImage > 0.5; % Rethreshold
    otherwise
        binaryCrackSmoothed = Iground;
end

% Image size
[rows, columns, ~] = size(binaryCrackSmoothed);

% Skeleton prune threshold
skelPruneThresh = floor(max(rows,columns) * thinPruneThresh);

% Image branch/end points extraction
Ifilled = imfill(binaryCrackSmoothed,'holes');

switch thinPruneMethod
    case 'conventional'
        binarySkeleton = bwmorph(Ifilled,'thin',Inf);
    case 'alex'
        if ismac
            % Code to run on Mac platform
            BW3 = skeleton_mac(Ifilled) > skelPruneThresh;
        elseif isunix
            % Code to run on Linux platform
            BW3 = skeleton_unix(Ifilled) > skelPruneThresh;
        elseif ispc
            % Code to run on Windows platform
            BW3 = skeleton_win(Ifilled) > skelPruneThresh;
        else
            disp('Platform not supported')
        end
        
        binarySkeleton = bwmorph(BW3,'thin',Inf);
    case 'voronoi'
        [BW3, v, e] = voronoiSkel(Ifilled,'trim',5,'fast',1.23);
        binarySkeleton = bwmorph(BW3,'thin',Inf);          
    case 'fast_marching'
        % Crack centerline using the FMM
        S = skeletonFMM(Ifilled);

        % Poplutate the skeleton in binary image
        binarySkeleton = false(size(Ifilled));
        for j=1:length(S)
            L=S{j};
            x = round(L(:,1));
            y = round(L(:,2));
            for m = 1:numel(x)
                    binarySkeleton(x(m),y(m)) = 1;
            end
        end
end

%% Crack analysis
[bresenham_cell, row, col, idx, Orientations, Onormal90, Onormal270, OnrOrient, OncOrient, ...
    Onr90, Onc90, Onr270, Onc270, crackWidthscaled, crackLengthscaled, minCrackWidth, maxCrackWidth, ...
    averageCrackWidth, stdCrackWidth, RMSCrackWidth] = crackAnalysis(binaryCrack, binarySkeleton, skelOrientBlockSize, ...
                                                        pixelScale, movWindowSize, movWindowType);
%% Crack visualization
crackVisualize

%% Writing the output
writeOutput;

%% End
%--------------------------------------------------------------------------
Runtime = toc(Start);
