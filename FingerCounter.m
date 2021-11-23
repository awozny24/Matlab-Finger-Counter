%% Alexander Wozny and Jonathan Wozny
% This is the code for our final project simulation
% Takes in image or video --> finds the hand using YCbCr color space -->
% converts to a binary image --> uses blob analysis to find the centroid of
% the object (hand) --> turns a radius around the centroid to 0 value
% pixels --> counts the number of areas left (fingers)

close all; clear all; clc

scale = 0.2;    % for scaling down the image
radFrac = 0.95; % 0.95 works best tho 

% create video file reader for input
vidReader = VideoReader('HandVid.MOV');
vidPlayer = vision.DeployableVideoPlayer;

% while the video is playing
while(hasFrame(vidReader))
% read each frame
Ioriginal = readFrame(vidReader);  % hand image raw data
IoriginalSmall = imresize(Ioriginal,scale);  % shrink to decrease resolution
                                             % arm hair in pictures gave
                                             % more trouble

% convert hand images to grayscale
%grayHand = rgb2gray(IoriginalSmall);  

    % Convert the image from RGB to YCbCr color space
    img_ycbcr = rgb2ycbcr(IoriginalSmall);
    Cb = img_ycbcr(:,:,2); % extract blue values
    Cr = img_ycbcr(:,:,3); % extract red values
    
    % initialize binary image
    BW = zeros(size(Cr,1), size(Cr,2));

    % find values of Cr within range
    % range found from online: 67<=Cb<=137: works for Train2
    % range for Train1: 80<=Cb<=120
    for i = 1:size(Cr,1)
        for j = 1:size(Cr,2)
            if ((Cb(i,j) >= 80) && (Cb(i,j) <=120))
                Cb(i,j) = 1; % acceptable value
            else
                Cb(i,j) = 0; % not acceptable value
            end
        end
    end

    % find values of Cr within range
    % range found from online: 133<=Cr<=173: works for Train2
    % range for Train1: 145<=Cr<=165
    for i = 1:size(Cr,1)
        for j = 1:size(Cr,2)
            if ((Cr(i,j) >= 145) && (Cr(i,j) <=165))
                Cr(i,j) =1; % acceptable value
            else
                Cr(i,j) = 0; % not acceptable value
            end
        end
    end

    % make into binary image at indices within these values as object
    for i = 1:size(Cr,1)
        for j = 1:size(Cr,2)
            if ((Cr(i,j) == 1) && (Cb(i,j) == 1))
                BW(i,j) = 1; % white object pixel
            else
                BW(i,j) = 0; % black pixel
            end
        end
    end

% convert hand images to binary 
%BW = imbinarize(grayHand);  % hand is white and background is black
BW = bwareaopen(BW,25);     % get rid of small random pixels that have less that a 25 pixel connection
BW = imfill(BW,'holes');    % fill holes in hand

% find centroid of the hand in the image
cent = regionprops(BW,'centroid'); 
centroids = cat(1, cent.Centroid);  % concatenate

% number of rows and columns of pixels in binary image
[row col] = size(BW);

% checks the number of centroids in the image
[rowCent colCent] = size(centroids);

% if there are more than 1 centroids in the image:  
if (rowCent > 1)
    % find the distance from each centroid to the center of the image
    for centThing = 1:rowCent
        centerX = round(col/2); centerY = round(row/2);
        xdistCent = abs(centroids(1,1)) - centerX;
        ydistCent = abs(centroids(1,2)) - centerY;
        distCent(centThing) = sqrt((xdistCent^2) + (ydistCent^2));
    end
    % used to be find the closest centroid to the center
    % for video, find image closest to the vertical central axis
    [M I] = min(distCent);
%     centroidsUse = centroids(I,:);
    
else
%     centroidsUse = centroids;
end


AxisLengths = regionprops(BW, 'MajorAxisLength', 'MinorAxisLength');
diameter = mean([AxisLengths.MajorAxisLength, AxisLengths.MinorAxisLength], 2);
radii = diameter/2;

% turns the palm of the hand to opposite binary color (deletes it) with in
% a circle of a calculated radius
for i = 1:row
    for j = 1:col
        xdist = abs(j - centroids(:,1));    % x distance to centroid
        ydist = abs(i - centroids(:,2));    % y distance to centroid
        distance = sqrt( (xdist.^2) + (ydist.^2) ); 
        distance = min(distance);
        if ( (BW(i,j) == 1) && (distance < (radii*radFrac)) )
            BW(i,j) = 0;
        end
    end
end

% eliminate random pixels
BW = bwareaopen(BW, 50);    % clean up the image more just in case 

% find new centroids in the image
centFing = regionprops(BW,'centroid'); %,'MajorAxisLength', 'MinorAxisLength');
centroidsFing = cat(1, centFing.Centroid);
numCentroidsFing = length(centroidsFing);

% find minimum and maximum axis lengths of the objects in the image
AxisLengths = regionprops(BW, 'MajorAxisLength', 'MinorAxisLength');
minAxisLength = cat(1, AxisLengths.MinorAxisLength);

% removes centroids from count if additional very small objects are present
extraCentFing = 0;
for mint = 1:length(minAxisLength)
    if (minAxisLength(mint,1) < 8)
        extraCentFing = extraCentFing + 1; 
    end
end

% reminder: rowCent is the number of extra centroids in addition 
% to the fingers (this includes random objects as well as the
% forearm/wrist
% find the number of fingers and subtracts extra centroids from the 
% image in the count
fingerNum = numCentroidsFing - rowCent - extraCentFing;

% constrain finger count
if (fingerNum > 5)
    fingerNum = 5;
elseif (fingerNum <0)
    fingerNum = 0;
end

%imshow(BW);   % Use to show black and white of what computer sees
Text = insertText(Ioriginal, [0,0], sprintf('Number of Fingers: %d', fingerNum), 'FontSize', 60);   % text on video
step(vidPlayer, Text);  % display video

 

end
