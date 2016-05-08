function mean_image_report(scanParams)

% Function to create the mean image;

fontScale = 20;
cmap = gray(255).';
imgScale = [];

% Mean map, creating the images..

for nf=1:length(scanParams)
    % Create the tSNR maps    
    image_matrix = generateSliceSummary(['QA_report/' scanParams(nf).outputBaseName '_Mean'],scanParams(nf).slices,[],fontScale,imgScale,cmap,scanParams(nf).ROI_box);
    imwrite(image_matrix,['QA_report/' scanParams(nf).outputBaseName '_Mean_IMAGE.png'],'PNG')
end

