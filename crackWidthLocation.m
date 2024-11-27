function mycell = crackWidthLocation( x,y,angle,BW )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    
% Variables initialization
lineLength = 1;
yzeroflag = 0; xzeroflag = 0;
ymaxflag  = 0; xmaxflag = 0;

% Loop through pixels
while(1)
    if ~(angle == 180 || angle == 360)
        xnew_width1 = floor(x + lineLength * -cosd(angle));
        ynew_width1 = floor(y + lineLength * sind(angle));
    else
        if (angle == 180)
            xnew_width1 = x - lineLength;
            ynew_width1 = y;
        elseif (angle == 360)
            xnew_width1 = x + lineLength;
            ynew_width1 = y;
        end
    end

    % Image size limit conditions check
    if(ynew_width1 == 0 || ynew_width1 < 0)
        ynew_width1 = 1;
        yzeroflag = 1;
    end
    if(xnew_width1 == 0 || xnew_width1 < 0)
        xnew_width1 = 1;
        xzeroflag = 1;
    end
    if(ynew_width1 > size(BW,1))
        ynew_width1 = size(BW,1);
        ymaxflag = 1;
    end
    if(xnew_width1 > size(BW,2))
        xnew_width1 = size(BW,2);
        xmaxflag = 1;
    end

    % Store location values
    xnew_array(lineLength) = xnew_width1;
    ynew_array(lineLength) = ynew_width1;

    % Break statement
    if(BW(ynew_width1,xnew_width1) == 0 || ...
            yzeroflag == 1 || xzeroflag ==1 ||...
            ymaxflag  == 1 || xmaxflag == 1 || ...
            lineLength > max(size(BW)))
        break;
    end

    % Line increment
    lineLength = lineLength + 1;
end
    
% Store location as cell array
mycell{1,1} = xnew_array;
mycell{2,1} = ynew_array;
end

