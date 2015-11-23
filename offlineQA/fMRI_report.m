% This function here is to calculate the tSNR, image SNR then generate a
% report showing these if needed. A work in progress ...

function [tSNR_ROI,iSNR]=fMRI_report(filenames,params,imgScale)

% Make a folder called QA_report, where the tSNR maps are calculated, and
% where the summary file will live once this is run.
if(~isdir('QA_report'));
    mkdir('QA_report');
end

fontScale = 20;
noise_calculation = 1;
roi_calculation = 1;
cmap = hot(255).';

% tSNR calculation and summary collections:

for nf=1:length(filenames)        
    % Create the tSNR maps
    tSNR(filenames{nf},'dynNOISEscan',params(nf).dynNOISEscan,'cropTimeSeries',params(nf).cropTimeSeries,'outputBaseName',['QA_report/' params(nf).outputBaseName]);    
    tSNRFnames{nf} = params(nf).outputBaseName;
    image_matrix = generateSliceSummary(['QA_report/' params(nf).outputBaseName '_tSNR'],params(nf).slices,[],fontScale,imgScale,cmap,params(nf).ROI_box);
    imwrite(image_matrix,['QA_report/' params(nf).outputBaseName '_tSNR_IMAGE.png'],'PNG')
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
    for nf=1:length(filenames)
        % First load image
        img = cbiReadNifti(['QA_report/' tSNRFnames{nf} '_tSNR']);
        slice_image = img(:,:,params(nf).ROI_box.slice,1);
        % Reorder, just so that we have a match of the ROIs with the image
        % (from rotation)
        slice_image = slice_image(:,end:-1:1).';
        image_cropped = slice_image(params(nf).ROI_box.y:params(nf).ROI_box.y+params(nf).ROI_box.height,params(nf).ROI_box.x:params(nf).ROI_box.x+params(nf).ROI_box.width);
        tSNR_ROI(nf) = mean(image_cropped(:));
    end
end

if(noise_calculation)
    for nf=1:length(filenames)
        nI = cbiReadNifti(['QA_report/' tSNRFnames{nf} '_tSNR_N_M_V']);
        noiseImage = nI(:,:,:,2);
        img = cbiReadNifti(filenames{nf});
        img_data = img(:,:,:,params(nf).cropTimeSeries(2));
        
        img_slice = img_data(:,:,params(nf).ROI_box.slice);
        img_slice = img_slice(:,end:-1:1).';               
        image_cropped = img_slice(params(nf).ROI_box.y:params(nf).ROI_box.y+params(nf).ROI_box.height,params(nf).ROI_box.x:params(nf).ROI_box.x+params(nf).ROI_box.width);

                
        noise_slice = noiseImage(:,:,params(nf).ROI_box.slice);
        noise_slice = noise_slice(:,end:-1:1).';        
        noise_cropped = noise_slice(params(nf).ROI_box.y:params(nf).ROI_box.y+params(nf).ROI_box.height,params(nf).ROI_box.x:params(nf).ROI_box.x+params(nf).ROI_box.width);

        
        iSNR(nf) = mean(image_cropped(:))/std(noise_cropped(:));
    end
end


end