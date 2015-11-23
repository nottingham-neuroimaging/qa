function [image_matrix] = generateSliceSummary(filename,sliceChoice,zoomedSize,fontScale,imgScale,cmap,ROI_box)
% Function here to generate summary images, saves them as pngs for everyone
% to see.
% usage:

% out = createSummaryImages(filenames,imageType,saveFolder,sliceChoice)
%       filenames   = list of filenames to load, must be in NIFTI-PAIR format
%       imageType   = list of strings that label each image
%       saveFolder  = where to save the images
%       sliceChoice = slices that I want to display out in a png

if(nargin<2)
    sliceChoice = 1:2;
end

if(nargin<3)
    zoomedSize = [];
end

if(nargin<4)
    fontScale = 20;
end

if(nargin<5)
    imgScale = [];
end

if(nargin<6)
    cmap = hot(255).';
end

if(nargin<7)
    ROI_box = [];
end

data = cbiReadNifti(filename);
data = mean(data,4);

%     figure;
for sc=1:length(sliceChoice),
    dat = data(:,:,sliceChoice(sc)).';
    if(~isempty(imgScale))
        if(imgScale>0)
            dat2 = (dat/imgScale);
        else
            dat2 = (dat/max(dat(:)));
        end                
    else
        dat2 = (dat/max(dat(:)));
    end
    
    
    dat2 = uint8(reshape((meshData2Colors(dat2(:),cmap,[0 1])).'*255,[size(dat) 3]));
%     keyboard
    
    % Here is for zooming in.
    if(~isempty(zoomedSize))
        dat2 = dat2(zoomedSize(1,1):zoomedSize(1,2),zoomedSize(2,1):zoomedSize(2,2),:);
    end
    dat2 = dat2(end:-1:1,:,:);
    
    dat2 = insertText(dat2,[1,1],['slice_' num2str(sliceChoice(sc))],'BoxColor',[0 0 255],'TextColor',[255 255 255],'FontSize',fontScale);
    
    if(~isempty(ROI_box) && ismember(sc,ROI_box.slice))
        dat2=insertShape(dat2,'Rectangle',[ROI_box.x ROI_box.y ROI_box.width ROI_box.height],'Color',[0 0 255]);
    end
    dats{sc} = dat2;
end

% Always make sure this is eight
no_columns = 8;

if(length(sliceChoice)<=no_columns)
    image_matrix = cell2mat(dats);
elseif(length(sliceChoice)>no_columns)
    
    no_rows = ceil(length(sliceChoice)/no_columns);
    totalImages = no_rows*no_columns;
    newMatrix = cell(no_rows,no_columns);
    newMatrix(1:length(sliceChoice)) = dats;
    
    % Need to do this faster perhaps..
    for j=length(sliceChoice)+1:totalImages,
        newMatrix{j} = uint8(zeros(size(dats{1})));
    end
    image_matrix = cell2mat(newMatrix(reshape(1:totalImages,no_columns,no_rows).'));
else
    disp('error!, somebthing went wrong');
    keyboard;
    return
end


