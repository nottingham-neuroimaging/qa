function [tSNR_ROI,iSNR] = tSNR_report(scanParams,figHandle)

fontScale = 20;

data = guidata(figHandle);
imgScale = data.options.imgScale;
cmap = data.options.cmap;

% tSNR calculation and summary collections..

% Calculate and save the tSNR maps, only redo this if it is asked to. 
% Sometimes you don't want to recalculate the tSNR maps, just the 
% figures that show all the stuff in them, which is what the
% options structure is for.
% 
if(data.options.recalculateTSNR)
    for nf=1:length(scanParams)
        % Create the tSNR maps
            [outputFilenameTSNR] = tSNR(scanParams(nf).fileName,'dynNOISEscan',scanParams(nf).dynNOISEscan,...
                'cropTimeSeries',[scanParams(nf).volumeSelectFirst scanParams(nf).volumeSelect],...
                'outputBaseName',['QA_report/' scanParams(nf).outputBaseName],...
                'cropSlices', [scanParams(nf).sliceSelectFirst scanParams(nf).sliceSelectLast]);
            if isfield(scanParams,'polyROI')
                %if ~isempty(scanParams.polyROI)
                    %polyroitsnr = tSNR(scanParams.polyROI, 'outputBaseName',['QA_report/' scanParams(nf).outputBaseName]);
                    newtest = outputFilenameTSNR(:,:,scanParams.firstSlice:scanParams.lastSlice).*scanParams.polyROI;
                    L = newtest(newtest~=0 & newtest~=inf & ~isnan(newtest));
                    %             test = find(newtest);
                    %             test2=nanmean(newtest(test));
                    
                    %             tSNR_poly = mean(scanParams.polyROI)./std(scanParams.polyROI,1);
                    %             tSNR_poly = tSNR_poly(~isnan(tSNR_poly(:)) & ~isinf(tSNR_poly(:)));
                    fprintf('POLY_ROI_TSNR: %.4f\n', mean(L));
                %end
            end
    end
end

if ~isfield(scanParams, 'mask')
    %keyboard
    for ii = 1:length(scanParams)
        scanParams(ii).mask = 1; %by default do some masking, this is a fudge factor temporarily while I figure out why it won't ggrab field from GUI
    end
end
    
for nf=1:length(scanParams)
    tSNRFnames{nf} = scanParams(nf).outputBaseName;
    image_matrix = generateSliceSummary(['QA_report/' scanParams(nf).outputBaseName '_tSNR'],...
    [scanParams(nf).sliceSelectFirst:scanParams(nf).sliceSelectLast],[],fontScale,imgScale,cmap,scanParams(nf).ROI_box,scanParams(nf).orientation, scanParams(nf).mask);

    imwrite(image_matrix,['QA_report/' scanParams(nf).outputBaseName '_tSNR_IMAGE.png'],'PNG')    
end

% Now calculate the histograms and save them
%tmpSave = cell(length(scanParams),2);
% make space
myMean = zeros(length(scanParams),1);
myMedian = zeros(length(scanParams),1);

myfilename = cell(length(scanParams),1);
    
for nf=1:length(scanParams)
    data = cbiReadNifti(['QA_report/' scanParams(nf).outputBaseName '_tSNR']);
    data2 = data(~isnan(data(:)) & ~isinf(data(:)));
    figH = figure;
    set(figH,'PaperPosition',[0.25 0.25 15 8],'visible','off');
    histogram(data2(:),200);

    xlim([mean(data2)-2*std(data2(:)) mean(data2)+2*std(data2(:))])
    set(gca,'fontSize',20);
    xlabel('$tSNR$','fontSize',20,'Interpreter','LaTeX');    
    ylabel('$count$','fontSize',20,'Interpreter','LaTeX');    
    line([0 0],ylim,'Color','black');  %y-axis
    line(mean(data2)*[1 1],ylim,'Color','red','lineStyle','--');  %Mean 
    print(figH,['QA_report/' scanParams(nf).outputBaseName '_tSNR_HIST.png'],'-dpng');
    
    % mask values less than 5% of the mean (optional)
    % if you set it to 0, then you're including those values in the mean,
    % and hence the tSNR will drop. Need to remove them here, but set them
    % to zero in generateSliceSummary (line74), for visualization
    for ii = 1:length(scanParams)
        if scanParams(ii).mask == 1
            data2 = data2(data2>0.05*max(data2(:)));
        end
    end
    
    %fprintf('Max TSNR: %.4f\n', max(data2))
    fprintf('Median TSNR: %.4f\n', median(data2))
    fprintf('Mean TSNR: %.4f\n', mean(data2))
    
    % save out to csv file
    
    %T(nf,1) = table(mean(data2));
    %T(nf,2) = table(extractfield(scanParams(nf),'fileName'));
    
    % fill up separately here
    myMean(nf,1) = mean(data2);
    myMedian(nf,1) = median(data2);
    %myfilename(nf,1) = extractfield(scanParams(nf),'fileName');    
    
    % remove dependency on extractfield
    myfilename{nf,1} = scanParams(nf).fileName;    
    %themeans(nf) = mean(data2);
    %clear data data2;
end

% make table outside of loop, prevents warning message
T = table(myMean,myMedian, myfilename);
% save out to csvfile
writetable(T,'mean_tSNR_data.csv')

%fprintf('Grand mean: %.4f\n', mean(themeans));
clear data data2
% Make a colorbar ... save the colorbar that is the same for all the scans.
hh = ones(1,size(cmap.',1),3);
hh(1,:,:) = cmap.';

figH = figure('visible','off');
h = imagesc(linspace(0,imgScale,size(cmap,2)),0,hh);
% keyboard
set(figH,'PaperPosition',[0.25 0.25 8 1.8]);
set(gca,'YTick',[],'fontSize',16);
print(figH,['QA_report/cbar.png'],'-dpng');

% Another function now to look at specific ROIs and noise calculations
tSNR_ROI = nan(length(scanParams),1);
for nf=1:length(scanParams)
  if ~isempty(scanParams(nf).ROI_box)
    % First load image
    img = cbiReadNifti(['QA_report/' tSNRFnames{nf} '_tSNR']);
    slice_image = img(:,:,scanParams(nf).ROI_box.slice,1);
    % Reorder, just so that we have a match of the ROIs with the image
    % (from rotation)
    slice_image = permute(slice_image(:,end:-1:1,:),[2 1 3]);    
    image_cropped = slice_image(scanParams(nf).ROI_box.y:scanParams(nf).ROI_box.y+scanParams(nf).ROI_box.height,scanParams(nf).ROI_box.x:scanParams(nf).ROI_box.x+scanParams(nf).ROI_box.width,:);
    tSNR_ROI(nf) = nanmean(image_cropped(:));
  end
  
  if ~isnan(tSNR_ROI)
      fprintf('tSNR_ROI = %.4f\n', nanmean(tSNR_ROI))
  end
 
end

iSNR = nan(length(scanParams),1);
for nf=1:length(scanParams)
  if ~isempty(scanParams(nf).ROI_box) && scanParams(nf).dynNOISEscan
    nI = cbiReadNifti(['QA_report/' tSNRFnames{nf} '_tSNR_N_M_V']);
    noiseImage = nI(:,:,:,2);
    img = cbiReadNifti(scanParams(nf).fileName);
    img_data = img(:,:,:,scanParams(nf).volumeSelect);

    img_slice = img_data(:,:,scanParams(nf).ROI_box.slice);
    img_slice = permute(img_slice(:,end:-1:1,:),[2 1 3]);
    image_cropped = img_slice(scanParams(nf).ROI_box.y:scanParams(nf).ROI_box.y+scanParams(nf).ROI_box.height,scanParams(nf).ROI_box.x:scanParams(nf).ROI_box.x+scanParams(nf).ROI_box.width,:);


    noise_slice = noiseImage(:,:,scanParams(nf).ROI_box.slice);
    noise_slice = permute(noise_slice(:,end:-1:1,:),[2 1 3]);
    noise_cropped = noise_slice(scanParams(nf).ROI_box.y:scanParams(nf).ROI_box.y+scanParams(nf).ROI_box.height,scanParams(nf).ROI_box.x:scanParams(nf).ROI_box.x+scanParams(nf).ROI_box.width,:);


    iSNR(nf) = mean(image_cropped(:))/std(noise_cropped(:));
  end
end


end