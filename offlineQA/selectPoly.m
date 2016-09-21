function [polymask, firstSlice, lastSlice] = selectPoly(volume)
%selectPoly - follows selectCropRegion function, but implements a polygon,
%rather than a rectangle



if isempty(volume)
  mrWarnDlg('(selectPoly) The source volume is empty');
  return
end

dims=size(volume); 
[dump,sliceDim]=min(dims); %choose the slice dimension to the be smallest one

nImages = size(volume,sliceDim);
switch sliceDim
  case 1
    aSize = [size(volume,2) size(volume,3)];
  case 2
    aSize = [size(volume,1) size(volume,3)];
  case 3
    aSize = [size(volume,1) size(volume,2)];
end

%get the screen size of the default monitor
screenSize = getMonitorPositions;
screenSize = screenSize(1,3:4);
hFigure = figure('MenuBar', 'none');

OK = 0;    % Flag to accept chosen crop
while ~OK
    clf
    %optimize number of columns and rows based on screen dimensions and images dimensions
    [m,n]=getArrayDimensions(nImages,screenSize(2)/aSize(1)*aSize(2)/screenSize(1));
    %optimize figure proportions for subplot
    figureDims = get(hFigure,'position');
    figureDims(3)=figureDims(4)*n/m*aSize(2)/aSize(1);
    set(hFigure,'position',figureDims);
    for row = 1:m
      for col = 1:n
        sliceNum = (row-1)*n+col;
        if sliceNum<=nImages
          h(sliceNum) =  subplot('position',getSubplotPosition(col,row,ones(1,n),ones(1,m),0.02,0.02));
          switch sliceDim
            case 1
              thisSlice = squeeze(volume(sliceNum,:,:));
            case 2
              thisSlice = squeeze(volume(:,sliceNum,:));
            case 3
              thisSlice = volume(:, :, sliceNum);
          end
          imagesc(thisSlice, 'Tag', sprintf(' %d', sliceNum));
          colormap(gray)
          axis off
          axis equal
        end
      end
    end
    brighten(0.6);

    set(hFigure,'name','Click on the first slice.')
    sliceNum = 0;
    while sliceNum == 0
        waitforbuttonpress
        tag = get(gco, 'Tag');
        if ~isempty(tag)
            sliceNum = str2num(tag);
        end
    end
    firstSlice = sliceNum;
    hFirst = text(aSize(2)/2,aSize(1)/2,{'First','slice'},'parent',h(firstSlice),'HorizontalAlignment','center','color','g','fontweight','bold');
    
    set(hFigure,'name','Click on the last slice.')
    sliceNum = 0;
    while sliceNum == 0
        waitforbuttonpress
        tag = get(gco, 'Tag');
        if ~isempty(tag)
            sliceNum = str2num(tag);
        end
    end
    if sliceNum > firstSlice
        lastSlice = sliceNum;
        text(aSize(2)/2,aSize(1)/2,{'Last','slice'},'parent',h(lastSlice),'HorizontalAlignment','center','color','g','fontweight','bold');
    else
        lastSlice = firstSlice;
        firstSlice = sliceNum;
        set(hFirst,'string',{'Last','slice'});
        text(aSize(2)/2,aSize(1)/2,{'First','slice'},'parent',h(firstSlice),'HorizontalAlignment','center','color','g','fontweight','bold');
    end

%     set(hFigure,'name','Click on an image to crop.')
%     sliceNum = 0;
%     while sliceNum == 0
%         waitforbuttonpress
%         tag = get(gco, 'Tag');
%         if ~isempty(tag)
%             sliceNum = str2num(tag);
%         end
%     end

clf
switch sliceDim
      case 1
        thisSlice = squeeze(volume(firstSlice,:,:));
      case 2
        thisSlice = squeeze(volume(:,firstSlice,:));
      case 3
        thisSlice = volume(:, :, firstSlice);
end

for i = firstSlice:lastSlice
    thisSlice = volume(:,:,i);
    imagesc(thisSlice);
    colormap(gray)
    brighten(0.6);
    axis off
    axis equal
    set(hFigure, 'name', 'Crop the image.')
    h = roipoly;
    for j = 1:(lastSlice-firstSlice)+1
        polymask(:,:,j) = thisSlice.*h;
    end
    
    %poly{i} = getPosition(h);
end

%bb = regionprops(poly, 'BoundingBox');

    switch questdlg('Does this look OK?', 'Confirm crop');
        case 'Cancel'
            % Cancel
            poly = volume;
            close(hFigure);
            disp('Crop aborted');
            return
        case 'Yes'
            % Okay
            OK = 1;
        case 'No'
            % No
            disp('Repeating crop');
    end
end

close(hFigure)%if ~OK

    








