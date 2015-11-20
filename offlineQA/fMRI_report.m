% This function here is to calculate the tSNR, image SNR then generate a
% report showing these if needed. A work in progress ...

function fMRI_report(filenames,params,imgScale)

% Make a folder called QA_report, where the tSNR maps are calculated, and
% where the summary file will live once this is run.
if(~isdir('QA_report'));
    mkdir('QA_report');
end

fontScale = 20;

for nf=1:length(filenames)
    % Create the tSNR maps
    tSNR(filenames{nf},'dynNOISEscan',params(nf).dynNOISEscan,'cropTimeSeries',params(nf).cropTimeSeries,'outputBaseName',['QA_report/' params(nf).outputBaseName]);    
    image_matrix = generateSliceSummary(['QA_report/' params(nf).outputBaseName '_tSNR'],params(nf).slices,[],fontScale,imgScale);
    imwrite(image_matrix,['QA_report/' params(nf).outputBaseName '_tSNR_IMAGE.png'],'PNG')
end


cmap = hot(255).';
% Save the colorbar that is the same for all the scans.
hh = ones(1,size(cmap.',1),3);
hh(1,:,:) = cmap.';

figH = figure('visible','off');
h = imagesc(linspace(0,imgScale,size(cmap,2)),0,hh);
set(figH,'PaperPosition',[0.25 0.25 6 1]);
set(gca,'YTick',[],'fontSize',20);
print(figH,['QA_report/cbar.png'],'-dpng');



end