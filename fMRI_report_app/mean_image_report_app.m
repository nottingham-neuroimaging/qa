function mean_image_report_app(app,scanParams)

% Function to create the mean image;
%data = guidata(figHandle);
fontScale = 20;
cmap = gray(255).';
%imgScale = data.options.imgScaleMean;
if isempty(app.MeanColorbarmaxEditField.Value)
    imgScale = [];
else
    imgScale = str2double(app.MeanColorbarmaxEditField.Value);
end
%imgScale = [];

% Mean map, creating the images..
for nf=1:length(scanParams)
    % Create mean image maps
%     image_matrix = generateSliceSummary(['QA_report/' scanParams(nf).outputBaseName '_Mean'],scanParams(nf).slices,[],fontScale,imgScale,cmap,[]);
    image_matrix = generateSliceSummary_app(['QA_report/' scanParams(nf).outputBaseName '_Mean'],[scanParams(nf).sliceSelectFirst:scanParams(nf).sliceSelectLast],[],fontScale,imgScale,cmap,[],scanParams(nf).orientation);
    % Note: ROIs were taken out from these mean maps, because they are not used for the mean images (maybe add)
    imwrite(image_matrix,['QA_report/' scanParams(nf).outputBaseName '_Mean_IMAGE.png'],'PNG')
end

