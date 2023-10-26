% Code to remove the outer bright skull from a CT cross sectional image.
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 20;

%===========================================================================================================
% Get the name of the image the user wants to use.
% baseFileName = 'skull_stripping_demo_image.dcm';
baseFileName = 'skull_stripping_demo_image.png';
% Get the full filename, with path prepended.
folder = pwd
fullFileName = fullfile(folder, baseFileName)

% Check if the file exists.
if ~exist(fullFileName, 'file')
	% The file doesn't exist -- didn't find it there in that folder.  
	% Check the entire search path (other folders) for the file by stripping off the folder.
	fullFileNameOnSearchPath = baseFileName; % No path this time.
	if ~exist(fullFileNameOnSearchPath, 'file')
		% Still didn't find it.  Alert user.
		errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end

%===========================================================================================================
% Read in a demo image.
% grayImage = dicomread(fullFileName);
grayImage = imread(fullFileName);
% Get the dimensions of the image.  
% numberOfColorBands should be = 1.
[rows, columns, numberOfColorChannels] = size(grayImage);
if numberOfColorChannels > 1
	% It's not really gray scale like we expected - it's color.
	% Convert it to gray scale by taking only the green channel.
	grayImage = grayImage(:, :, 2); % Take green channel.
end
% Display the image.
subplot(2, 3, 1);
imshow(grayImage, []);
axis on;
caption = sprintf('Original Grayscale Image\n%s', baseFileName);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;
hp = impixelinfo();
% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off') 

% Make the pixel info status line be at the top left of the figure.
hp.Units = 'Normalized';
hp.Position = [0.01, 0.97, 0.08, 0.05];

%===========================================================================================================
% Display the histogram so we can see what gray level we need to threshold it at.
subplot(2, 3, 2:3);
% For this image, there is a huge number of black pixels with gray level less than about 11,
% and that makes a huge spike at the first bin.  Ignore those pixels so we can get a histogram of just non-zero pixels.
% histObject = histogram(grayImage(grayImage >= 11))
[pixelCounts, grayLevels] = imhist(grayImage(grayImage >= 11), 65536);
faceColor = [0, 60, 190]/255; % Our custom color - a bluish color.
bar(grayLevels, pixelCounts, 'BarWidth', 1, 'FaceColor', faceColor);
% Find the last gray level and set up the x axis to be that range.
lastGL = find(pixelCounts>0, 1, 'last');
xlim([0, lastGL]);
grid on;
% Set up tick marks every 50 gray levels.
ax = gca;
ax.XTick = 0 : 50 : lastGL;
title('Histogram of Non-Black Pixels', 'FontSize', fontSize, 'Interpreter', 'None', 'Color', faceColor);
xlabel('Gray Level', 'FontSize', fontSize);
ylabel('Pixel Counts', 'FontSize', fontSize);

%===========================================================================================================
% Threshold the image to make a binary image.
thresholdValue = 260;
binaryImage = grayImage > thresholdValue;
% Display the image.
subplot(2, 3, 4);
imshow(binaryImage, []);
axis on;
caption = sprintf('Initial Binary Image\nThresholded at %d Gray Levels', thresholdValue);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');

%===========================================================================================================
% Extract the outer blob, which is the skull.  
% The outermost blob will have a label number of 1.
labeledImage = bwlabel(binaryImage);		% Assign label ID numbers to all blobs.
binaryImage = ismember(labeledImage, 1);	% Use ismember() to extract blob #1.
% Thicken it a little with imdilate().
binaryImage = imdilate(binaryImage, true(5));

% Display the final binary image.
subplot(2, 3, 5);
imshow(binaryImage, []);
axis on;
caption = sprintf('Final Binary Image\nof Skull Alone');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');

%===========================================================================================================
% Mask out the skull from the original gray scale image.
skullFreeImage = grayImage; % Initialize
skullFreeImage(binaryImage) = 0; % Mask out.
% Display the image.
subplot(2, 3, 6);
imshow(skullFreeImage, []);
axis on;
caption = sprintf('Gray Scale Image\nwith Skull Stripped Away');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');

%===========================================================================================================
% Give user a chance to see the results on this figure, then offer to continue and find the tumor.
promptMessage = sprintf('Do you want to continue and find the tumor,\nor Quit?');
titleBarCaption = 'Continue?';
buttonText = questdlg(promptMessage, titleBarCaption, 'Continue', 'Quit', 'Continue');
if strcmpi(buttonText, 'Quit')
	return;
end

%===========================================================================================================
% Now threshold to find the tumor
thresholdValue = 270;
binaryImage = skullFreeImage > thresholdValue;
% Display the image.
hFig2 = figure();
subplot(2, 2, 1);
imshow(binaryImage, []);
axis on;
caption = sprintf('Initial Binary Image\nThresholded at %d Gray Levels', thresholdValue);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');

% Set up figure properties:
% Enlarge figure.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.25 0.15 .5 0.7]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off') 
drawnow;

%===========================================================================================================
% Assume the tumor is the largest blob, so extract it
binaryTumorImage = bwareafilt(binaryImage, 1);
% Display the image.
subplot(2, 2, 2);
imshow(binaryTumorImage, []);
axis on;
caption = sprintf('Tumor Alone');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');

%===========================================================================================================
% Find tumor boundaries.
% bwboundaries() returns a cell array, where each cell contains the row/column coordinates for an object in the image.
% Plot the borders of the tumor over the original grayscale image using the coordinates returned by bwboundaries.
subplot(2, 2, 3);
imshow(grayImage, []);
axis on;
caption = sprintf('Tumor\nOutlined in red in the overlay'); 
title(caption, 'FontSize', fontSize, 'Color', 'r'); 
axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
hold on;
boundaries = bwboundaries(binaryTumorImage);
numberOfBoundaries = size(boundaries, 1);
for k = 1 : numberOfBoundaries
	thisBoundary = boundaries{k};
	% Note: since array is row, column not x,y to get the x you need to use the second column of thisBoundary.
	plot(thisBoundary(:,2), thisBoundary(:,1), 'r', 'LineWidth', 2);
end
hold off;

%===========================================================================================================
% Now indicate the tumor a different way, with a red tinted overlay instead of outlines.
subplot(2, 2, 4);
imshow(grayImage, []);
caption = sprintf('Tumor\nSolid & tinted red in overlay'); 
title(caption, 'FontSize', fontSize, 'Color', 'r'); 
axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
hold on;
% Display the tumor in the same axes.
% Make a truecolor all-red RGB image.  Red plane has the tumor and the green and blue planes are black.
redOverlay = cat(3, ones(size(binaryTumorImage)), zeros(size(binaryTumorImage)), zeros(size(binaryTumorImage)));
hRedImage = imshow(redOverlay); % Save the handle; we'll need it later.
hold off;
axis on;
% Now the tumor image "covers up" the gray scale image.
% We need to set the transparency of the red overlay image to be 30% opaque (70% transparent).
alpha_data = 0.3 * double(binaryTumorImage);
set(hRedImage, 'AlphaData', alpha_data);




