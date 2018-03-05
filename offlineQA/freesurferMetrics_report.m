function freesurferMetrics_report(figHandle)

	data = guidata(figHandle)
	scanParams = data.scanParams;
	subjects_dir = data.subjects_dir;

	% A parameter that needs to be inputted really in the GUI				
	% data.freesurfersubject = 'memb_1';
	% keyboard

	% if(data.options.recaulculateTSNR)
    	for nf=1:length(scanParams)
    		output = [pwd '/QA_report/' data.scanParams(nf).outputBaseName '_surface'];
    		fname_tSNR = [pwd '/QA_report/' data.scanParams(nf).outputBaseName '_tSNR.nii.gz'];
    		fname_tSeries = data.scanParams(nf).fileName;
    		subject = data.freesurfersubject;
    		[tSNR tSeries tSNRWM] = freesurferMetrics(fname_tSNR,fname_tSeries,subject,output,subjects_dir);

    		tSNR_across_scans{nf}.parcelrh = tSNR.parcelrh;
    		tSNR_across_scans{nf}.parcellh = tSNR.parcellh;
    		tSNR_across_scans{nf}.WM = tSNRWM;

    		tSeries_across_scans{nf} = [tSeries.parcellh;tSeries.parcelrh];
    		scanNames{nf} = scanParams(nf).fileName;
    	end
	% end

	left_bar = [];
	right_bar = [];
	left_wm = [];
	right_wm = [];
	for nf=1:length(scanParams)
		left_bar = [left_bar tSNR_across_scans{nf}.parcellh];
		right_bar = [right_bar tSNR_across_scans{nf}.parcelrh];
		left_wm = [left_wm tSNR_across_scans{nf}.WM.left];
		right_wm = [right_wm tSNR_across_scans{nf}.WM.right];
	end
	% next thing after this is to generate PNGs etc
	
	figH = figure('color','white','visible','off');
	barh([1:35],left_bar);
	set(gca,'YTickLabel',tSNR.struct_names_lh(2:end),'YTick',[1:length(tSNR.struct_names_lh(2:end))]);
	xlabel('tSNR');
	ylabel('Regions')
	legend(scanNames,'Location','SouthOutside','Interpreter','none');
	title(['LH ' data.freesurfersubject],'Interpreter','none')
	set(gca,'fontSize',18)
	set(figH,'PaperPosition',[0.25 0.25 30 50],'units','character');	
	print(figH,['QA_report/tSNR_bar_left.png'],'-dpng');
	close(figH);

	figH = figure('color','white','visible','off');
	barh([1:35],right_bar);
	set(gca,'YTickLabel',tSNR.struct_names_rh(2:end),'YTick',[1:length(tSNR.struct_names_rh(2:end))]);
	xlabel('tSNR');
	ylabel('Regions')
	legend(scanNames,'Location','SouthOutside','Interpreter','none');
	title(['RH ' data.freesurfersubject],'Interpreter','none');
	set(gca,'fontSize',18)
	set(figH,'PaperPosition',[0.25 0.25 30 50],'units','character');	
	print(figH,['QA_report/tSNR_bar_right.png'],'-dpng');
	close(figH);

	% now get it ordred and look at WM as well.
% 	keyboard
    [~,sortInds] = sort(sum(left_bar,2));
    figH = figure('color','white','Visible','off');
    plot(1:35,left_bar(sortInds(end:-1:1),:),'.-','MarkerSize',10);
    title(['LH ' data.freesurfersubject],'Interpreter','none');
    legend(scanNames,'Location','SouthOutside','Interpreter','none');
    set(gca,'XTickLabel',tSNR.struct_names_lh(sortInds(end:-1:1)+1),'XTick',[1:length(tSNR.struct_names_lh(2:end))],'XTickLabelRotation',45,'fontSize',14);
	set(figH,'PaperPosition',[0.25 0.25 50 30],'units','character');	
	print(figH,['QA_report/tSNR_line_left.png'],'-dpng');
    close(figH);
    
    figH = figure('color','white','visible','off');
    [~,sortInds] = sort(sum(right_bar,2));
    plot(1:35,right_bar(sortInds(end:-1:1),:),'.-','MarkerSize',10);
    legend(scanNames,'Location','SouthOutside','Interpreter','none');
    title(['RH ' data.freesurfersubject],'Interpreter','none');
    set(gca,'XTickLabel',tSNR.struct_names_rh(sortInds(end:-1:1)+1),'XTick',[1:length(tSNR.struct_names_rh(2:end))],'XTickLabelRotation',45,'fontSize',14);
	set(figH,'PaperPosition',[0.25 0.25 50 30],'units','character');	
	print(figH,['QA_report/tSNR_line_right.png'],'-dpng');
    close(figH);

    
    % keyboard
    figH = figure('color','white','visible','off');
    bar([left_wm;right_wm])
    legend(scanNames,'Location','SouthOutside','Interpreter','none');
    title(['WM tSNR ' data.freesurfersubject],'Interpreter','none');
    set(gca,'XTickLabel',{'LH','RH'},'XTick',[1 2],'fontSize',14);
	set(figH,'PaperPosition',[0.25 0.25 20 15],'units','character');	
	print(figH,['QA_report/tSNR_wm.png'],'-dpng');
    close(figH);
    
	for nf=1:length(scanParams)	
		% Make a 3-way plot here
		figH = figure('color','white','visible','off');
		corrs = corr(zscore(tSeries_across_scans{nf}.'));

		subplot(3,1,1)
		imagesc(zscore(tSeries_across_scans{nf}.').');
		xlabel('Volumes')
		ylabel('Regions')		
		colorbar
		set(gca,'fontSize',18)
		h = title([data.freesurfersubject ' ' scanNames{nf}]);
		set(h,'Interpreter','none');
		subplot(3,1,3)		
		bins = linspace(-0.5,1,100);
		hist(corrs(:),bins);
		xlabel('Corr');ylabel('count');
		set(gca,'fontSize',18)
		subplot(3,1,2)
		imagesc(corrs);caxis([-0.5 1]);axis image;axis off;colorbar
		set(gca,'fontSize',18)
		set(figH,'PaperPosition',[0.25 0.25 20 40],'units','character');	
		output_png = [pwd '/QA_report/' data.scanParams(nf).outputBaseName '_connectivity.png'];
		print(figH,output_png,'-dpng');
		close(figH);

	end


	% Now make the figures for each view for the tSNR on a surface.
	for nf=1:length(scanParams)	
		% Set up the surfaces, with the overlays
		fname_tSNR = [pwd '/QA_report/' data.scanParams(nf).outputBaseName '_surface.tSNR'];
		[figH,camH] = displayOverlaysOnSurface(fname_tSNR,data.freesurfersubject,subjects_dir,data.options.cmap,[0 data.options.imgScale]);

		% Now save the different orientations, just doing inferoir and superior -- you can add some later if so desired
		% right view
		view([90 0]);
		set(camH,'Position',[1.1945e+03 0 0]);
		% Save a temporary figure
		savePng(figH,['QA_report/temp']);
		rightImg = imread(['QA_report/temp.png']);

		% left view
		view([-90 0]);
		set(camH,'Position',[-1.1945e+03 0 0]);
		% Save a temporary figure
		savePng(figH,['QA_report/temp']);
		leftImg = imread(['QA_report/temp.png']);


		% Superior view
		view([0 90]);
		set(camH,'Position',[0 0 1.1945e+03]); 		
		% Save a temporary figure
		savePng(figH,['QA_report/temp']);
		superiorImg = imread(['QA_report/temp.png']);

		% Inferior view
		view([0 -90]);
		set(camH,'Position',[0 0 -1.1945e+03]); 				
		% Save a temporary figure
		savePng(figH,['QA_report/temp']);
		inferiorImg = imread(['QA_report/temp.png']);

		combinedImage = [leftImg,rightImg,superiorImg,inferiorImg];
		summaryImage = [pwd '/QA_report/' data.scanParams(nf).outputBaseName '_tSNR_summarySurface.png'];
		imwrite(combinedImage,summaryImage);
		disp(['Saving surface images.... ' num2str(100*nf/length(scanParams)) '% done...']);
	end

	
end



% A subfunction to save the images as a PNG
function savePng(figH,fname,parameters)

if(nargin<3)
    width = 10;height = 10;
else
    width = parameters(1);
    height = parameters(2);
end

set(figH,'PaperPosition',[0.25 0.25 width height],'InvertHardCopy','off');
set(figH,'Color',[0 0 0]);
print(figH,[fname '.png'],'-dpng','-opengl');
end