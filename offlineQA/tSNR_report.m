function [tSNR_ROI,iSNR] = tSNR_report(scanParams)

fontScale = 20;
noise_calculation = 0;
roi_calculation = 0;
cmap = hot(255).';
imgScale = 50;

% tSNR calculation and summary collections:

for nf=1:length(scanParams)
    % Create the tSNR maps
    tSNR(scanParams(nf).fileName,'dynNOISEscan',scanParams(nf).dynNOISEscan,'cropTimeSeries',[1 scanParams(nf).volumeSelect],'outputBaseName',['QA_report/' scanParams(nf).outputBaseName]);
    tSNRFnames{nf} = scanParams(nf).outputBaseName;
    image_matrix = generateSliceSummary(['QA_report/' scanParams(nf).outputBaseName '_tSNR'],scanParams(nf).slices,[],fontScale,imgScale,cmap,scanParams(nf).ROI_box);
    imwrite(image_matrix,['QA_report/' scanParams(nf).outputBaseName '_tSNR_IMAGE.png'],'PNG')
end



% Make a colorbar

% Save the colorbar that is the same for all the scans.
hh = ones(1,size(cmap.',1),3);
hh(1,:,:) = cmap.';

figH = figure('visible','off');
h = imagesc(linspace(0,imgScale,size(cmap,2)),0,hh);
set(figH,'PaperPosition',[0.25 0.25 6 1]);
set(gca,'YTick',[],'fontSize',20);
print(figH,['QA_report/cbar.png'],'-dpng');

% Another function now to look at specific ROIs and noise calculations
if(roi_calculation)
    for nf=1:length(scanParams)
        % First load image
        img = cbiReadNifti(['QA_report/' tSNRFnames{nf} '_tSNR']);
        slice_image = img(:,:,scanParams(nf).ROI_box.slice,1);
        % Reorder, just so that we have a match of the ROIs with the image
        % (from rotation)
        slice_image = slice_image(:,end:-1:1).';
        image_cropped = slice_image(scanParams(nf).ROI_box.y:scanParams(nf).ROI_box.y+scanParams(nf).ROI_box.height,scanParams(nf).ROI_box.x:scanParams(nf).ROI_box.x+scanParams(nf).ROI_box.width);
        tSNR_ROI(nf) = mean(image_cropped(:));
    end
else
    tSNR_ROI = [];
end

if(noise_calculation)
    for nf=1:length(scanParams)
        nI = cbiReadNifti(['QA_report/' tSNRFnames{nf} '_tSNR_N_M_V']);
        noiseImage = nI(:,:,:,2);
        img = cbiReadNifti(scanParams(nf).fileName);
        img_data = img(:,:,:,scanParams(nf).cropTimeSeries(2));
        
        img_slice = img_data(:,:,scanParams(nf).ROI_box.slice);
        img_slice = img_slice(:,end:-1:1).';
        image_cropped = img_slice(scanParams(nf).ROI_box.y:scanParams(nf).ROI_box.y+scanParams(nf).ROI_box.height,scanParams(nf).ROI_box.x:scanParams(nf).ROI_box.x+scanParams(nf).ROI_box.width);
        
        
        noise_slice = noiseImage(:,:,scanParams(nf).ROI_box.slice);
        noise_slice = noise_slice(:,end:-1:1).';
        noise_cropped = noise_slice(scanParams(nf).ROI_box.y:scanParams(nf).ROI_box.y+scanParams(nf).ROI_box.height,scanParams(nf).ROI_box.x:scanParams(nf).ROI_box.x+scanParams(nf).ROI_box.width);
        
        
        iSNR(nf) = mean(image_cropped(:))/std(noise_cropped(:));
    end
else
    iSNR = [];
end


end