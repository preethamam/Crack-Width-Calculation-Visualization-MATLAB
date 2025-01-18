%% Figure(s) display
%--------------------------------------------------------------------------
% Display histogram
figure;
histObj = histogram(crackWidthscaled);
title ('Histogram of the crack thickness');
xlabel('Thickness');
ylabel('Count');
grid on

%--------------------------------------------------------------------------
% Display PDF
[f,xi] = ksdensity(crackWidthscaled,'NumPoints',100,...
                    'support','positive','Function','pdf');
figure
plot(xi,f);
axis tight
title ('PDF of the crack thickness');
xlabel('Thickness');
ylabel('Density');
grid on

%--------------------------------------------------------------------------
% Display CDF
figure
[h,stats] = cdfplot(crackWidthscaled);
axis tight
title ('CDF of the crack thickness');
xlabel('Thickness');
ylabel('Density');
grid on

%--------------------------------------------------------------------------
% Display crack centerline
% redCL = imoverlay(binaryCrack, binarySkeleton, [1 0 0]);
figure; 
imshow(binaryCrack);
hold on
plot(col,row,'.','Color',[1 0 0]);
title ('Crack centerline');
f1h = findobj(gcf,'type','axes');
hold off

%--------------------------------------------------------------------------
% Find distance map
xx = 1:size(binaryCrack,2);
yy = 1:size(binaryCrack,1);
[X,Y] = meshgrid(xx,yy);
crackDistmapValues = binaryCrack .* (X+Y);

% Distance map plot
grayCL = imoverlay(binaryCrack, binarySkeleton, [0.2 0.2 0.2]);
figure;
imagesc(crackDistmapValues); axis equal; axis tight; axis off;
hold on
plot(col,row,'.','Color',[0.5 0.5 0.5]);
myColorMap = jet(256);
myColorMap(1,:) = 0;
colormap(myColorMap); c1 = colorbar;
c1.Label.String = 'Crack Distance Measure';
title ('Crack pixels distance map');
hold off

%--------------------------------------------------------------------------
% Overlay normals to verify
figure,
imshow(binaryCrack);
hold on
plot(col,row,'.','Color',[0 1 0]);
h1 = quiver(col,row,Onc90(idx),-Onr90(idx),'color',[1 0 0]);
h2 = quiver(col,row,Onc270(idx), -Onr270(idx),'color',[0 0 1]);
h3 = quiver(col,row,OncOrient(idx),-OnrOrient(idx),'color',[0.1 0.1 0.1]);
set(h1,'MaxHeadSize',1,'AutoScaleFactor',0.25);
set(h2,'MaxHeadSize',1,'AutoScaleFactor',0.25);
set(h3,'MaxHeadSize',0.5,'AutoScaleFactor',0.025);
hold off
title ('Crack normals visualization');
f2h = findobj(gcf,'type','axes');
linkaxes([f1h,f2h],'xy')


%%
%--------------------------------------------------------------------------
% Plot the crack width factor
BWWidthFactor = zeros(size(binaryCrack));
for m = 1:length(bresenham_cell)
    xnew_array = bresenham_cell{m,1};
    ynew_array = bresenham_cell{m,2};
    for n = 1:numel(xnew_array)
        BWWidthFactor(ynew_array(n),xnew_array(n)) = crackWidthscaled(m);
    end
end


switch crackWidthLineBackground
    case 'black'
        % Black background with black crack width region
        figure;
        hold on
        h2 = imagesc(flipud(BWWidthFactor)); axis equal; axis tight; axis off;
        set( h2, 'AlphaData', 1);
        myColorMap = jet(256);
        myColorMap(1,:) = 0;
        colormap (myColorMap); 
        c2 = colorbar;
        c2.Label.String = 'Crack Width';
        title ('Crack width variation visualization');
        hold off

    case 'white'
        % Black background with white crack width region
        BW4_dupliate = binaryCrack;
        BWWidthFactor = BWWidthFactor .* (BWWidthFactor>0);

        % set the colormap to be always black and jet
        cmap = [0,0,0;jet(255)];

        % Normalize from nxm matrix to nxmx3 rgb values
        Norm_BWWF = BWWidthFactor;
        Norm_BWWF = round(((Norm_BWWF-min(Norm_BWWF(:))) / (max(Norm_BWWF(:))-min(Norm_BWWF(:))))*(length(cmap)-1)+1);
        imgsc_im = reshape(cmap(Norm_BWWF(:),:),[size(Norm_BWWF),3]);

        % Get the mask for all pixels that are in a but are zero in b
        MaskBW = repmat( (BW4_dupliate > 0 & BWWidthFactor == 0),[1 1 3]);
        imgsc_im(MaskBW) = 1; % assign this pixels with rgb = white
        
        % Plot imagesc 
        figure;
        imagesc(imgsc_im); axis equal; axis tight; axis off;
        colormap(jet); 
        c2 = colorbar;
        c2.Label.String = 'Crack Width';
        caxis([min(min(BWWidthFactor)) max(max(BWWidthFactor))])
        title ('Crack width variation visualization');
end

%%
%--------------------------------------------------------------------------
% Plot the crack width factor center line
BWWidthFactorCL = binarySkeleton .* BWWidthFactor;
figure;
imagesc(BWWidthFactorCL); axis equal; axis tight; axis off;
myColorMap = jet(256);
myColorMap(1,:) = 0;
colormap(myColorMap); c3 = colorbar;
c3.Label.String = 'Crack Width';
title ('Crack width variation visualization along center line');

%--------------------------------------------------------------------------
% Plot the crack center line tangential and normal orientations angles
CLOTangential = binarySkeleton .* abs(Orientations);
CLOnormal      = Onormal90;
figure;
subplot(2,1,1)
imagesc(CLOTangential); axis equal; axis tight; axis off;
myColorMap = jet(256);
myColorMap(1,:) = 0;
colormap(myColorMap); c4 = colorbar;
c4.Label.String = 'Tangential Angle (^{\circ})';
title ('Crack tangential angle variation visualization along center line');

subplot(2,1,2)
imagesc(CLOnormal); axis equal; axis tight; axis off;
myColorMap = jet(256);
myColorMap(1,:) = 0;
colormap(myColorMap); c5 = colorbar;
c5.Label.String = 'Normal Angle (^{\circ})';
title ('Crack normal angle variation visualization along center line');

%--------------------------------------------------------------------------
% Single crack width visualization
crackCL = imoverlay(binaryCrack,binarySkeleton,[1 0 0]);
singlecrackWidth = false(size(binaryCrack));
for i = crackIndex
        x_bresenham = bresenham_cell{i,1};
        y_bresenham = bresenham_cell{i,2};
        for j = 1:numel(x_bresenham)
            singlecrackWidth(y_bresenham(j), x_bresenham(j)) = 1;
        end
end
crackWidthStrand = imoverlay(crackCL, singlecrackWidth,[0 0 1]);
figure,
imshow(crackWidthStrand);
title ('Rasterization visualization of a single crack width');

%--------------------------------------------------------------------------
% Plot the crack boundaries
boundaries = bwboundaries(binaryCrack);

figure;
imshow(binaryCrack)
hold on
for k=1:length(boundaries)
   b = boundaries{k};
   plot(b(:,2),b(:,1),"g",LineWidth=1);
end
hold off
title ('Crack boundaries');

%--------------------------------------------------------------------------
% Plot the crack lines movie
greenCL = imoverlay(binaryCrack, binarySkeleton, [0 1 0]);
if(crackLineMovie)
    figure; %#ok<UNRCH>
    imshow(greenCL);
    hold on
    for m = 1:length(bresenham_cell)
        xnew_array = bresenham_cell{m,1};
        ynew_array = bresenham_cell{m,2};

        % Plotting
        plot(xnew_array,ynew_array)
        drawnow;
    end
    title ('Crack width lines movie');
    hold off
end
%--------------------------------------------------------------------------