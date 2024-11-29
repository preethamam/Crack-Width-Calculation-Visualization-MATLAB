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
BWWF_crackWidthLine_background = 'white'; % Crack background % 'white' | 'black'
crackIndex = 50; % Single crack pixel index to display
crackLineMovie = 0; % Show crack lines movie

%% Image I/O
binaryCrack = imread(image);
binarySkeleton = bwmorph(binaryCrack,'thin',Inf);

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
